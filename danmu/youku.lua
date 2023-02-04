info = {
    ["name"] = "优酷",
    ["id"] = "Kikyou.d.youku",
    ["desc"] = "优酷弹幕脚本",
    ["version"] = "0.1",
    ["min_kiko"] = "0.9.2"
}

supportedURLsRe = {
    "(https?://)?v.youku.com/v_show/id_(.+)\\.html\\??(.*)?"
}

sampleSupporedURLs = {
    "https://v.youku.com/v_show/id_XNTkxMjQxNzM4MA==.html"
}

settings = {
    ["skip_ad_time"]={
        ["title"]="跳过广告时长(s)",
        ["desc"]="跳过广告时长(s)，弹幕播放时间会减去这个时长",
        ["default"]="0"
    },
    ["user_agent"]={
        ["title"]="UA",
        ["desc"]="User Agent",
        ["default"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) Gecko/20100101 Firefox/108.0"
    }
}

function string.split(str, sep)
    local pStart = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local pEnd = string.find(str, sep, pStart)
        if pEnd == pStart then
            pStart = pEnd + string.len(sep)
        else
            if not pEnd then
                nSplitArray[nSplitIndex] = string.sub(str, pStart, string.len(str))
                break
            end
            nSplitArray[nSplitIndex] = string.sub(str, pStart, pEnd - 1)
            pStart = pEnd + string.len(sep)
            nSplitIndex = nSplitIndex + 1
        end
    end
    return nSplitArray
end
function escape(str)
   str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
      function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "+")
   return str
end
function get_cookies(cookie_str)
    local cookies = {}
    if cookie_str == nil then return cookies end
    local cookie_rows = string.split(cookie_str, '\n')
    for _, cookie_row in ipairs(cookie_rows) do
        local cookie_items = string.split(cookie_row, ';')
        if #cookie_items > 0 then
            local kvs = string.split(cookie_items[1], '=')
            if #kvs > 1 then
                cookies[kvs[1]] = kvs[2]
            end
        end
    end
    return cookies
end
function get_video_info(vid)
    local info_url = string.format("https://openapi.youku.com/v2/videos/show.json?client_id=53e6cc67237fc59a&package=com.huawei.hwvplayer.youku&ext=show&video_id=%s", vid)
    local err, reply = kiko.httpget(info_url, {}, {["User-Agent"] = settings["user_agent"]})
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply["content"])
    if err ~= nil then error(err) end
    if obj["duration"] == nil then error("未找到视频时长") end
    local duration = tonumber(obj["duration"])
    local title = obj["title"]
    if title == nil then title = "unknown" end
    return title, duration
end
function download_seg(cna, vid, seg, danmuList)
    local msg = {
        ["ctime"] = tostring(os.time() * 1000),
        ["ctype"] = 10004,
        ["cver"] = "v1.0",
        ["guid"] = cna,
        ["mat"] = seg,
        ["mcount"] = 1,
        ["pid"] = 0,
        ["sver"] = "3.1.0",
        ["type"] = 1,
        ["vid"] = vid
    }
    local err, msg_json = kiko.table2json(msg, "compact")
    local err, msg_b64 = kiko.base64(msg_json, "to")
    msg["msg"] = msg_b64
    local err, sign = kiko.hashdata(msg_b64 .. "MkmC9SoIw6xCkSKHhJ7b5D2r51kBiREr", false)
    msg["sign"] = sign
    local err, reply = kiko.httpget("https://acs.youku.com/h5/mtop.com.youku.aplatform.weakget/1.0/?jsv=2.5.1&appKey=24679788", {}, {["User-Agent"] = settings["user_agent"]})
    if err ~= nil then
        kiko.log(string.format("vid: %s, seg: %d, http error: %s", vid, seg, err))
        return danmuList
    end
    local cookies = get_cookies(reply["headers"]["Set-Cookie"])
    if cookies["_m_h5_tk_enc"] == nil or cookies["_m_h5_tk"] == nil then 
        kiko.log(string.format("vid: %s, seg: %d, error: Cookie not found, %s", vid, seg, err))
        return danmuList
    end
    local cookie_header = ""
    for k, v in pairs(cookies) do
        local c = string.format("%s=%s", k, v)
        if #cookie_header == 0 then
            cookie_header = c
        else
            cookie_header = cookie_header .. ";" .. c
        end
    end
    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Cookie"] = cookie_header,
        ["Referer"] = "https://v.youku.com",
        ["User-Agent"] = settings["user_agent"]
    }
    local err, data = kiko.table2json(msg, "compact")
    local t = tostring(os.time() * 1000) 
    local t_sing_hash_data = string.sub(cookies["_m_h5_tk"], 1, 32) .. "&" .. t .. "&" .. "24679788" .. "&" .. data
    local err, t_sign = kiko.hashdata(t_sing_hash_data, false)
    local params = {
        ["jsv"] = "2.5.6",
        ["appKey"] = "24679788",
        ["t"] = t,
        ["sign"] = t_sign,
        ["api"] = "mopen.youku.danmu.list",
        ["v"] = "1.0",
        ["type"] = "originaljson",
        ["dataType"] = "jsonp",
        ["timeout"] = "20000",
        ["jsonpIncPrefix"] = "utility"
    }
    local err, reply = kiko.httppost("https://acs.youku.com/h5/mopen.youku.danmu.list/1.0/", "data=" .. escape(data), headers, params)
    if err ~= nil then
        kiko.log(string.format("vid: %s, seg: %d, error: %s", vid, seg, err))
        return danmuList
    end
    local err, obj = kiko.json2table(reply["content"])
    if err ~= nil then
        kiko.log(string.format("dm content error, vid: %s, seg: %d, error: %s", vid, seg, err))
        return danmuList
    end
    local err, dobj = kiko.json2table(obj["data"]["result"])
    if err ~= nil then
        kiko.log(string.format("dmobj error, vid: %s, seg: %d, error: %s", vid, seg, err))
        return danmuList
    end
    local skip_time = tonumber(settings["skip_ad_time"]) * 1000
    for _, dm in ipairs(dobj["data"]["result"]) do
        local color = 0xffffff
        local size = 0
        local err, pobj = kiko.json2table(dm["propertis"])
        if err==nil then
            if pobj["color"] ~= nil then
                color = tonumber(pobj["color"])
            end
            if tonumber(pobj["size"]) > 2 then
                size = 2
            end
        end    
        table.insert(danmuList, {
            ["text"]=dm["content"],
            ["time"]=dm["playat"]-skip_time,
            ["date"]=tostring(math.floor(dm["createtime"] / 1000)),
            ["color"]=color,
            ["fontsize"]=size,
            ["sender"]="[Youku]" .. dm["uid2"]
        })
    end
    return danmuList
end

function urlinfo(url)
    local reg = kiko.regex("[\\s\\S]+?youku.com/v_show/id_(.+?)\\.html")
    local _, _, vid = reg:find(url)
    
    if vid == nil then error("不支持的URL") end
    local title, duration = get_video_info(vid)
    if title == nil then title = "unknown" end
    
    local data = { ["vid"] = vid, ["duration"] = duration }
    local _, data_str = kiko.table2json(data, "compact")

    local results = {}
    table.insert(results, {
        ["title"] = title,
        ["duration"] = duration,
        ["data"] = data_str
    })
    return results
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    local err, reply = kiko.httpget("https://log.mmstat.com/eg.js", {}, {["User-Agent"] = settings["user_agent"], ["Accept-Encoding"] = "gzip, deflate", ["Accept"] = "*/*", ["Connection"] = "keep-alive"})
    local cookies = get_cookies(reply["headers"]["Set-Cookie"])
    if cookies["cna"] == nil then error("get cna cookie failed") end

    local segs = math.floor(source_obj["duration"] / 60) + 1
    local danmuList = {}
    for i = 1,segs do 
        download_seg(cookies["cna"], source_obj["vid"], i, danmuList)
    end
    return nil, danmuList
end
