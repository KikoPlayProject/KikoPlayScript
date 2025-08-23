info = {
    ["name"] = "AcFun",
    ["id"] = "Kikyou.d.AcFun",
	["desc"] = "AcFun弹幕脚本",
	["version"] = "0.3",
    ["min_kiko"] = "2.0.0",
    ["label_color"] = "0xFD4C5D",
}

supportedURLsRe = {
    "(https?://)?www\\.acfun\\.cn/v/ac[0-9]+(_[0-9]+)?",
    "(https?://)?www\\.acfun\\.cn/bangumi/aa[0-9]+(_[0-9]+_[0-9]+)?"
}

sampleSupporedURLs = {
    "http://www.acfun.cn/v/ac4471456",
    "https://www.acfun.cn/bangumi/aa6000896"
}

function str2time(time_str)
    local timeArray = string.split(time_str, ':')
    local duration, base = 0, 0
    for i = #timeArray,1,-1 do
        duration = duration + 60^base*timeArray[i]
        base = base + 1
    end
    return duration
end

function search(keyword)
    local query = {
        ["keyword"]=keyword
    }
    local header = {

    }
    local err, reply = kiko.httpget("https://www.acfun.cn/rest/pc-direct/search/bgm", query, header)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then error(err) end
    local ret = obj["bgmList"]
    if ret == nil then return {} end
    local results = {}
    for _, item in ipairs(ret) do
        local itemType = item["itemType"]
        local bgmTitle = item["bgmTitle"]
        local bgmId = item["bgmId"]
        local i = 1
        local eps = {}
        for _, ep in ipairs(item["videoList"]) do
            local data = {
                ["url"] = string.format("https://www.acfun.cn/bangumi/aa%d_36188_%d", bgmId, ep["itemId"]),
            }
            local _, data_str = kiko.table2json(data)
            table.insert(eps, {
                ["title"] = bgmTitle .. " " .. tostring(i),
                ["data"] = data_str
            })
            i = i+1
        end
        local _, data_str = kiko.table2json(eps)
        table.insert(results, {
            ["title"] = bgmTitle,
            ["desc"] = string.format("共 %d 集", #eps),
            ["data"] = data_str
        })
    end
    return results
end

function epinfo(source)
    local err, obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    return obj
end

function urlinfo(url)
    local pattens = {
        ["https?://www%.acfun%.cn/v/ac%d+"]="ac",
        ["www%.acfun%.cn/v/ac%d+"]="ac",
        ["https?://www%.acfun%.cn/bangumi/aa%d+"]="aa",
        ["www%.acfun%.cn/bangumi/aa%d+"]="aa"
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
    local results = {}
    local data = {
        ["url"] = url
    }
    local _, data_str = kiko.table2json(data)
    table.insert(results, {
        ["title"] = "unknown",
        ["data"] = data_str
    })
    return results
end

function downloadDanmu(vid)
    local danmuUrl = "https://www.acfun.cn/rest/pc-direct/new-danmaku/list"
    local headers = {
        ["Content-Type"]="application/x-www-form-urlencoded"
    }

    local pcursor = "1"
    local dm_arrays = {}
    while pcursor ~= nil and pcursor ~= "no_more" do
        local postdata = string.format("resourceId=%s&pcursor=%s&resourceType=9&count=200", vid, pcursor)
        local err, reply = kiko.httppost(danmuUrl, postdata, headers)
        if err ~= nil then 
            kiko.log("slice fetch error: ", pcursor, err)
            pcursor = nil
        else
            local danmuContent = reply["content"]
            local err, obj = kiko.json2table(danmuContent)
            local danmuArray = obj["danmakus"]
            if danmuArray ~= nil then
                table.insert(dm_arrays, danmuArray)
            end
            pcursor = obj["pcursor"]
        end
    end
    
    local danmus = {}
    for _, danmuArray in ipairs(dm_arrays) do
        for _, dmObj in ipairs(danmuArray) do
            local text = dmObj["body"]
            local time = tonumber(dmObj["position"])
            local mode = tonumber(dmObj["mode"])
            local dmType = 0 --rolling
            if mode == 4 then
                dmType = 2  --bottom
            elseif mode == 5 then
                dmType = 1  --top
            end
            local size = tonumber(dmObj["size"])
            if size == 18 then
                size = 1
            elseif size == 36 then
                size = 2
            else 
                size = 0
            end
            local color = tonumber(dmObj["color"])
            local date =  tonumber(dmObj["createTime"])/1000
            local sender = "[AcFun]" .. string.format("%d", dmObj["userId"])
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
    return danmus
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    if source_obj["vid"] ~= nil then
        return nil, downloadDanmu(source_obj["vid"])
    end

    local url = source_obj["url"]
    if url == nil then return {} end
    local err, reply = kiko.httpget(url)
    if err ~= nil then error(err) end
    local content = reply["content"]

    local _, _, vid = string.find(content, "ideoId\":(%d+)")
    if vid == nil then error("视频Id解析失败") end
    source_obj["vid"] = vid
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str

    local _, _, durationMs = string.find(content, "\"durationMillis\":(%d+)")
    if durationMs ~= nil then source["duration"] = tonumber(durationMs)/1000 end

    local _, _, showTitle = string.find(content, "\"showTitle\":\"(..-)\"")
    if showTitle ~= nil then 
        source["title"] = showTitle 
    else
        local _, _, title = string.find(content, "\"title\":\"(..-)\"")
        if title ~= nil then source["title"] = title end
    end

    return source, downloadDanmu(vid)
end
