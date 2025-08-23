info = {
    ["name"] = "爱奇艺",
    ["id"] = "Kikyou.d.Iqiyi",
	["desc"] = "爱奇艺弹幕脚本",
	["version"] = "0.4",
    ["min_kiko"] = "2.0.0",
    ["label_color"] = "0x00da5a",
}

supportedURLsRe = {
    "(https?://)?www\\.iqiyi\\.com/(v|w)_.+\\.html"
}

sampleSupporedURLs = {
    "https://www.iqiyi.com/v_19rrofvlmo.html",
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
        ["key"] = keyword,
        ["if"] = "html5",
    }
    local err, reply = kiko.httpget("https://search.video.iqiyi.com/o", query)
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply.content)
    if err ~= nil then error(err) end

    local res = {}
    if obj["data"] == nil or obj["data"]["docinfos"] == nil then
        return res
    end

    for _, doc in ipairs(obj["data"]["docinfos"]) do
        local albumDocInfo = doc["albumDocInfo"]
        if albumDocInfo	~= nil and albumDocInfo["videoinfos"] ~= nil then
            local items = {}
            for _, video in ipairs(albumDocInfo["videoinfos"]) do
                if video["tvId"] ~= nil then
                    local source_obj = {
                        ["vid"] = string.format("%d", video["tvId"]),
                        ["pieces"] = math.ceil(video["timeLength"] / 300 + 1),
                    }
                    local _, data_str = kiko.table2json(source_obj)
                    local source = {
                        ["title"] = video["itemshortTitle"],
                        ["duration"] = video["timeLength"],
                        ["data"] = data_str,
                    }
                    table.insert(items, source)
                end
            end
            if #items == 1 then
                table.insert(res, items[1])
            elseif #items > 1 then
                local _, data_str = kiko.table2json(items)
                table.insert(res, {
                    ["title"] = albumDocInfo["albumTitle"],
                    ["desc"] = string.format("共 %d 集", #items),
                    ["data"] = data_str
                })
            end
        end
    end

    return res
end

function epinfo(source)
    local err, obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    if obj["url"] ~= nil then
        return {source}
    elseif obj["vid"] ~= nil then
        return {source}
    end
    return obj
end

function urlinfo(url)
    local pattens = {
        ["https?://www%.iqiyi%.com/v_.+%.html"]="iqy",
        ["https?://www%.iqiyi%.com/w_.+%.html"]="iqy",
        ["www%.iqiyi%.com/v_.+%.html"]="iqy",
        ["www%.iqiyi%.com/w_.+%.html"]="iqy"
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
    local data = { ["url"] = url }
    local _, data_str = kiko.table2json(data)
    table.insert(results, {
        ["title"] = "unknown",
        ["data"] = data_str
    })
    return results
end

function decodeDanmu(content, danmuList)
    local err, danmuContent = kiko.decompress(content)
    if err ~= nil then return danmuList end
    local xmlreader = kiko.xmlreader(danmuContent)
    local curDate, curText, curTime, curColor, curUID = nil, nil, nil, nil, nil
    while not xmlreader:atend() do
        if xmlreader:startelem() then
            if xmlreader:name()=="contentId" then
                curDate = string.sub(xmlreader:elemtext(), 1, 10)
            elseif xmlreader:name()=="content" then
                curText = xmlreader:elemtext()
            elseif xmlreader:name()=="showTime" then
                curTime = tonumber(xmlreader:elemtext()) * 1000
            elseif xmlreader:name()=="color" then
                curColor = tonumber(xmlreader:elemtext(), 16)
            elseif xmlreader:name()=="uid" then
                curUID = "[iqiyi]" .. xmlreader:elemtext()
            end
        elseif xmlreader:endelem() then
            if xmlreader:name()=="bulletInfo" then
                table.insert(danmuList, {
                    ["text"]=curText,
                    ["time"]=curTime,
                    ["color"]=curColor,
                    ["date"]=curDate,
                    ["sender"]=curUID
                })
            end
        end
        xmlreader:readnext()
    end
    return danmuList
end

function downloadDanmu(id, pieces)
    local tvid = "0000" .. id
    local s1 = string.sub(tvid, -4, -3)
    local s2 = string.sub(tvid, -2)
    local url = string.format("http://cmts.iqiyi.com/bullet/%s/%s/%s_300_%s.z", s1, s2, id, "%d")
    local danmuList = {}
    if pieces == nil then
        local i = 1
        while true do
            local err, reply = kiko.httpget(string.format(url, i))
            if err ~= nil then break end
            local content = reply["content"]
            i = i+1
            danmuList = decodeDanmu(content, danmuList)
        end
    else
        local urls = {}
        for i=1,pieces do
            table.insert(urls, string.format(url, i))
        end
        local _, rets = kiko.httpgetbatch(urls)
        for _, v in ipairs(rets) do
            if not v["hasError"] then
                danmuList = decodeDanmu(v["content"], danmuList)
            end
        end
    end
    return danmuList
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    if source_obj["vid"] ~= nil then
        return nil, downloadDanmu(source_obj["vid"], source_obj["pieces"])
    end


    local headers = {
        ["Referer"] = source_obj["url"],
    }
    
    local err, reply = kiko.httpget("https://mesh.if.iqiyi.com/player/lw/lwplay/accelerator.js", {["format"]="json"}, headers)
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply.content) 
    if err ~= nil then error(err) end

    local videoInfo = obj["videoInfo"]
    if videoInfo == nil or videoInfo["tvId"] == nil then
        error("视频信息获取失败")
    end

    local err, reply = kiko.httpget(string.format("https://pcw-api.iqiyi.com/video/video/baseinfo/%d", videoInfo["tvId"]))
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply.content) 
    if err ~= nil then error(err) end
    local data_obj = obj["data"]

    source["title"] = videoInfo["title"]
    source["duration"] = str2time(data_obj["duration"])
    source_obj["vid"] = string.format("%d", videoInfo["tvId"])
    source_obj["pieces"] = math.ceil(source["duration"] / 300 + 1)
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str
    return source, downloadDanmu(source_obj["vid"], source_obj["pieces"])
end
