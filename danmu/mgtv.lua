info = {
    ["name"] = "芒果TV",
    ["id"] = "Kikyou.d.mgtv",
    ["desc"] = "芒果TV弹幕脚本",
    ["version"] = "0.2.1",
    ["min_kiko"] = "2.1.0",
    ["label_color"] = "0xFF5F00",
    ["icon"] = [[<svg t="1777793094642" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="14732" width="64" height="64"><path d="M1009.3 716.1V408.4c0-28-17.8-53.4-45.8-63.6l-101.7-28-147.5 302.6S561.8 235.5 561.8 232.9l-160.2-43.2c-7.6-2.5-15.3-2.5-22.9-2.5-45.8 0-78.8 35.6-78.8 78.8v457.6c0 40.7 33.1 73.7 73.7 73.7h7.6l63.6-5.1h-5.1V311.8L627.9 772l139.8-12.7 180.5-353.4v256.8c0 91.5-68.6 167.8-162.7 180.5L333 883.9h-10.2c-76.3 0-137.3-61-137.3-134.8V283.8c0-50.9-2.5-96.6 33.1-139.8 28-35.6 73.7-53.4 117-53.4 15.3 0 30.5 2.5 45.8 7.6l521.2 144.9h7.6c15.3 0 28-12.7 28-28 0-12.7-7.6-22.9-20.3-25.4L358.4 37.2c-28-10.2-58.5-15.3-89-15.3C129.6 22 17.7 131.3 17.7 266v523.8c0 124.6 104.2 226.3 231.4 226.3h20.3l506-48.3c134.7-12.8 233.9-122.1 233.9-251.7z m0 0" fill="#F06000" p-id="14733"></path></svg>]],
}

supportedURLsRe = {
    "(https?://)?www.mgtv.com/b/(\\d+)/(\\d+)\\.html\\??(.*)?"
}

sampleSupporedURLs = {
    "https://www.mgtv.com/b/330234/7149408.html"
}

settings = {
    ["user_agent"]={
        ["title"]="UA",
        ["desc"]="User Agent",
        ["default"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) Gecko/20100101 Firefox/108.0"
    }
}

math.randomseed(os.time())

function uuid()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return (string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end))
end

function get_tk2(did)
    local pno = "1030"
    local ts = tostring(os.time())
    local text = string.format("did=%s|pno=%s|ver=0.3.0301|clit=%s", did, pno, ts)
    local _, tk2 = kiko.base64(text, "to")
    tk2 = string.gsub(tk2, "[+/=]", {["+"]="_", ["/"]="~", ["="]="-"})
    tk2 = string.reverse(tk2)
    return tk2
end

function get_video_info(vid)
    local did = uuid()
    local queries = {
        ["did"] = did,
        ["suuid"] = uuid(),
        ["cxid"] = "",
        ["tk2"] = get_tk2(did),
        ["video_id"] = vid,
        ["type"] = "pch5",
        ["_support"] = "10000000",
        ["auth_mode"] = "1",
        ["callback"] = ""
    }
    local err, reply = kiko.httpget("https://pcweb.api.mgtv.com/player/video", queries, {["User-Agent"] = settings["user_agent"]})
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply["content"])
    if err ~= nil then error(err) end
    local info_obj = obj["data"]["info"]

    if info_obj["duration"] == nil then error("未找到视频时长") end
    local duration = tonumber(info_obj["duration"])
    local title = info_obj["title"] .. " " .. info_obj["series"]
    if title == nil then title = "unknown" end
    return title, duration, info_obj["collection_id"], vid
end

function download_seg(cid, vid, seg, danmuList)
    local queries = {
        ["version"] = "2.0.0",
        ["vid"] = vid,
        ["abroad"] = "0",
        ["pid"] = "",
        ["os"] = "",
        ["uuid"] = "",
        ["deviceid"] = "",
        ["cid"] = cid,
        ["ticket"] = "",
        ["time"] = "0",
        ["mac"] = "",
        ["platform"] = "0",
        ["callback"] = "",
        ["time"] = tostring(seg * 60 * 1000)
    }
    local err, reply = kiko.httpget("https://galaxy.bz.mgtv.com/rdbarrage", queries, {["User-Agent"] = settings["user_agent"]})
    if err ~= nil then
        kiko.log(string.format("vid: %s, seg: %d, error: %s", vid, seg, err))
        return danmuList
    end
    local err, obj = kiko.json2table(reply["content"])
    if err ~= nil then
        kiko.log(string.format("dm content error, vid: %s, seg: %d, error: %s", vid, seg, err))
        return danmuList
    end
    if obj["data"] == nil then return danmuList end
    if obj["data"]["items"] == nil then return danmuList end
    for _, dm in ipairs(obj["data"]["items"]) do
        if dm["time"] ~= nil then 
            table.insert(danmuList, {
                ["text"]=dm["content"],
                ["time"]=dm["time"],
                ["sender"]="[MGTV]" .. math.floor(dm["uid"])
            })
        end
    end
    return danmuList
end

function urlinfo(url)
    local reg = kiko.regex("[\\s\\S]+?mgtv.com/b/(\\d+)/(\\d+)\\.html")
    local _, _, cid, vid = reg:find(url)
    
    if vid == nil then error("不支持的URL") end
    local title, duration, cid, vid = get_video_info(vid)
    if title == nil then title = "unknown" end
    
    local data = { ["cid"] = cid, ["vid"] = vid, ["duration"] = duration }
    local _, data_str = kiko.table2json(data, "compact")

    local results = {}
    table.insert(results, {
        ["title"] = title,
        ["duration"] = duration,
        ["srcid"] = vid,
        ["data"] = data_str,
        ["url"] = url
    })
    return results
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    local segs = math.floor(source_obj["duration"] / 60)
    local danmuList = {}
    for i = 0,segs do 
        download_seg(source_obj["cid"], source_obj["vid"], i, danmuList)
    end
    return nil, danmuList
end
