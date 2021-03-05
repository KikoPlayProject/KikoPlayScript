info = {
    ["name"] = "Bilibili",
    ["id"] = "Kikyou.d.Bilibili",
	["desc"] = "Bilibili弹幕脚本",
	["version"] = "0.1"
}

supportedURLsRe = {
    "(https?://)?www\\.bilibili\\.com/video/av[0-9]+/?",
    "(https?://)?www\\.bilibili\\.com/video/BV[\\dA-Za-z]+/?",
    "av[0-9]+",
    "BV[\\dA-Za-z]+",
    "(https?://)?www\\.bilibili\\.com/bangumi/media/md[0-9]+/?"
}

sampleSupporedURLs = {
    "https://www.bilibili.com/video/av1728704",
    "https://www.bilibili.com/video/BV11x411P7TB",
    "av24213033",
    "BV11x411P7TB",
    "https://www.bilibili.com/bangumi/media/md28221404"
}

function str2time(time_str)
    local pos = 0
    for i = 1,#time_str do
        local ch = string.sub(time_str, i, i)
        if ch == ':'  then
            pos = i
            break
        end
    end
    if pos == 0 then
        return tonumber(time_str) or 0
    else
        local minute = tonumber(string.sub(time_str, 1, pos-1)) or 0
        local second = tonumber(string.sub(time_str, pos+1)) or 0
        return minute*60+second
    end
end

function search(keyword)
    local query = {
        ["keyword"]=keyword
    }
    local header = {
        ["Accept"]="application/json"
    }
    local err, reply = kiko.httpget("https://api.bilibili.com/x/web-interface/search/all", query, header)
    if err ~= nil then  error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local ret = obj["data"]["result"]
    if ret == nil then
        return {}
    end
    local bangumiResult, ftResult, videoResult = ret["media_bangumi"], ret["media_ft"], ret["video"]
    local results = {}
    if bangumiResult and ftResult then
        local bgmResult = table.move(ftResult, 1, #ftResult, #bangumiResult+1, bangumiResult)
        for _, sobj in ipairs(bgmResult) do
            local data = {
                ["media_id"] = string.format("%d", sobj["media_id"]),
                ["stype"] = "collection"
            }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = string.gsub(sobj["title"], "<([^<>]*)em([^<>]*)>", ""),
                ["desc"] = sobj["desc"],
                ["data"] = data_str
            })
        end
    end
    if videoResult then
        for _, sobj in ipairs(videoResult) do
            local data = {
                ["aid"] = string.format("%d", sobj["id"]),
                ["bvid"] = sobj["bvid"],
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = string.gsub(sobj["title"], "<([^<>]*)em([^<>]*)>", ""),
                ["desc"] = sobj["description"],
                ["duration"] = str2time(sobj["duration"]),
                ["data"] = data_str
            })
        end
    end
    return results
end

function epinfo(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    if source_obj["stype"]=="collection" then
        local query = { ["media_id"] = source_obj["media_id"] }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("https://bangumi.bilibili.com/view/web_api/season", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local results = {}
        for _, bobj in ipairs(obj["result"]["episodes"]) do
            local index = bobj["index"]
            local title = bobj["index_title"]
            local data = {
                ["aid"] = string.format("%d", bobj["aid"]),
                ["cid"] = string.format("%d", bobj["cid"]),
                ["bvid"] = bobj["bvid"],
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data)
            local fTitle = string.format("%s-%s", index, title)
            if title == nil or #title == 0 then
                fTitle = index
            end
            table.insert(results, {
                ["title"] = fTitle,
                ["duration"] = bobj["duration"]/1000,
                ["data"] = data_str
            })
        end
        return results
    elseif source_obj["stype"]=="video" then
        local query = { ["appkey"] = "8e9fc618fbd41e28", ["id"] = source_obj["aid"] }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("https://api.bilibili.com/view", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end

        local results = {}
        if obj["pages"] == 1 then
            local data = {
                ["aid"] = source_obj["aid"],
                ["cid"] = string.format("%d", obj["cid"]),
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = obj["title"],
                ["duration"] = source["duration"] or 0,
                ["data"] = data_str
            })
        else
            local header = { ["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" }
            local err, reply = kiko.httpget(string.format("https://www.bilibili.com/video/av%s", source_obj["aid"]), {}, header)
            if err ~= nil then error(err) end
            local content = reply["content"]
            local _, _, json_data = string.find(content, "\"videoData\":(.*),\"upData\"")
            if json_data ~= nil then 
                local err, json_obj = kiko.json2table(json_data)
                if err ~= nil then error(err) end
                for _, bobj in ipairs(json_obj["pages"]) do
                    local data = {
                        ["aid"] = source_obj["aid"],
                        ["cid"] = string.format("%d", bobj["cid"]),
                        ["stype"] = "video"
                    }
                    local _, data_str = kiko.table2json(data)
                    table.insert(results, {
                        ["title"] = bobj["part"],
                        ["duration"] = bobj["duration"],
                        ["data"] = data_str
                    })
                end
            else
                local _, _, json_data = string.find(content, "\"epList\":(.*),\"newestEp\"")
                if json_data ~= nil then
                    local err, json_obj = kiko.json2table(json_data)
                    if err ~= nil then error(err) end
                    for _, bobj in ipairs(json_obj["pages"]) do
                        local data = {
                            ["aid"] = source_obj["aid"],
                            ["cid"] = string.format("%d", bobj["cid"]),
                            ["bvid"] = bobj["bvid"],
                            ["stype"] = "video"
                        }
                        local _, data_str = kiko.table2json(data)
                        table.insert(results, {
                            ["title"] = bobj["index_title"],
                            ["data"] = data_str
                        })
                    end
                end
            end
        end
        return results
    else
        return {}
    end
end

function urlinfo(url)
    local pattens = {
        ["https?://www%.bilibili%.com/video/av[0-9]+/?"]="av",
        ["www%.bilibili%.com/video/av[0-9]+/?"]="av",
        ["https?://www%.bilibili%.com/video/BV[%dA-Za-z]+/?"]="bv",
        ["www%.bilibili%.com/video/BV[%dA-Za-z]+/?"]="bv",
        ["av%d+"]="av",
        ["BV[%dA-Za-z]+"]="bv",
        ["https?://www%.bilibili%.com/bangumi/media/md[0-9]+/?"]="bgm",
        ["www%.bilibili%.com/bangumi/media/md[0-9]+/?"]="bgm"
    }
    local matched = nil
    for pv, k in pairs(pattens) do
        s, e = string.find(url, pv)
        if s then
            if e - s + 1 == #url then
                matched = k
                break
            end
        end
    end
    if matched == nil then error("不支持的URL") end
    if matched == "av" then
        local _, _, aid = string.find(url, "av(%d+)")
        return epinfo({
            ["data"] = string.format("{\"aid\":\"%s\", \"stype\": \"video\"}", aid)
        })
    elseif matched == "bgm" then
        local _, _, bgmid = string.find(url, "md(%d+)")
        return epinfo({
            ["data"] = string.format("{\"media_id\":\"%s\", \"stype\": \"collection\"}", bgmid)
        })
    elseif matched == "bv" then
        local _, _, bvid = string.find(url, "(BV[%dA-Za-z]+)")
        local query = { ["bvid"] = bvid }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("http://api.bilibili.com/x/web-interface/view", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local obj = obj["data"]
        local aid = string.format("%d", obj["aid"])
        local results = {}
        for _, bobj in ipairs(obj["pages"]) do
            local data = {
                ["aid"] = aid,
                ["cid"] = string.format("%d", bobj["cid"]),
                ["bvid"] = bvid,
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = bobj["part"],
                ["duration"] = bobj["duration"] or 0,
                ["data"] = data_str
            })
        end
        return results
    end
end

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

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    local cid = source_obj["cid"]
    if cid == nil then return {} end
    local err, reply = kiko.httpget(string.format("http://comment.bilibili.com/%s.xml", cid))
    if err ~= nil then error(err) end
    local content = reply["content"]
    local danmus = {}
    local xmlreader = kiko.xmlreader(content)
    while not xmlreader:atend() do
        if xmlreader:startelem() and xmlreader:name()=="d" then
            if xmlreader:hasattr("p") then
                local attrs = string.split(xmlreader:attr("p"), ',')
                if #attrs >= 8 then
                    local text = xmlreader:elemtext()
                    local time = tonumber(attrs[1]) * 1000
                    local dmType = tonumber(attrs[2])
                    local size = tonumber(attrs[3])
                    if size == 18 then
                        size = 1
                    elseif size == 36 then
                        size = 2
                    else 
                        size = 0
                    end
                    local color = tonumber(attrs[4])
                    local date = attrs[5]
                    local sender = "[Bilibili]" .. attrs[7]
                    table.insert(danmus, {
                        ["text"]=text,
                        ["time"]=time,
                        ["color"]=color,
                        ["fontsize"]=size,
                        ["type"]=dmType,
                        ["date"]=date,
                        ["sender"]=sender
                    })
                end
            end
        end
        xmlreader:readnext()
    end
    return nil, danmus
end

function canlaunch(sources)
    for _, src in pairs(sources) do
        if src["scriptId"]==info["id"] then
            local err, source_obj = kiko.json2table(src["data"])
            if err == nil and source_obj["cid"] ~= nil then 
                return true
            end
        end
    end
    return false
end

function launch(sources, comment)
    kiko.log(sources)
    kiko.log(comment)    
    local status, text = kiko.dialog({
        ["title"]="Bilibili",
        ["tip"]="弹幕发送测试",
        ["text"]="(并没有真实发送弹幕)",
    })
    return nil
end 