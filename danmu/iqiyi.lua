info = {
    ["name"] = "爱奇艺",
    ["id"] = "Kikyou.d.Iqiyi",
	["desc"] = "爱奇艺弹幕脚本",
	["version"] = "0.1"
}

supportedURLsRe = {
    "(https?://)?www\\.iqiyi\\.com/(v|w)_.+\\.html"
}

sampleSupporedURLs = {
    "https://www.iqiyi.com/v_19rr1jer2o.html",
    "https://www.iqiyi.com/w_19rsjq2cbh.html"
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

function string.startsWith(str, substr)  
    if str == nil or substr == nil then  return false end  
    if string.find(str, substr) ~= 1 then  
        return false  
    else  
        return true  
    end  
end

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
    local err, reply = kiko.httpget(string.format("https://so.iqiyi.com/so/q_%s", keyword), {}, {["Accept"]="*/*"})
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, itemContent = string.find(content, "<div class=\"layout%-main\"(.*)<div class=\"layout%-side\"")
    if itemContent == nil then return {} end

    local parser = kiko.htmlparser(itemContent)
    local itemStart = false
    local curData, curTitle = nil, nil
    local results = {}
    while not parser:atend() do
        if string.startsWith(parser:curproperty("class"), "qy%-search%-result%-tit") then
            repeat
                parser:readnext()
            until parser:curproperty("class")=="main-tit"
            if itemStart then
                if string.startsWith(curData, "http://www.iqiyi.com") or string.startsWith(curData, "https://www.iqiyi.com") then
                    local data = { ["url"] = curData }
                    local _, data_str = kiko.table2json(data)
                    table.insert(results, {
                        ["title"] = curTitle,
                        ["data"] = data_str
                    })
                end
            end
            itemStart = true
            curTitle = parser:curproperty("title")
            curData  = parser:curproperty("href")
            if string.startsWith(curData, "//") then
                curData = "http:" .. curData
            end
        elseif parser:curproperty("class")=="qy-search-result-album" or parser:curproperty("class")=="qy-search-result-album-half" then
            local typeAlbum = parser:curproperty("class")=="qy-search-result-album"
            while parser:curnode()~="ul" or parser:start() do
                parser:readnext()
                if parser:curnode()=="li" and parser:curproperty("class")=="album-item" then
                    parser:readnext()
                    local epTitle = parser:curproperty("title")
                    if typeAlbum then
                        epTitle = curTitle .. " " .. epTitle
                    end
                    local epURL = parser:curproperty("href")
                    if string.startsWith(epURL, "//") then
                        epURL = "http:" .. epURL
                    end
                    if string.startsWith(epURL, "http://www.iqiyi.com") or string.startsWith(epURL, "https://www.iqiyi.com") then
                        local data = { ["url"] = epURL }
                        local _, data_str = kiko.table2json(data)
                        table.insert(results, {
                            ["title"] = epTitle,
                            ["data"] = data_str
                        })
                    end
                end
            end
            itemStart = false
        end
        parser:readnext()
    end
    if itemStart then
        if string.startsWith(curData, "http://www.iqiyi.com") or string.startsWith(curData, "https://www.iqiyi.com") then
            local data = { ["url"] = curData }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = curTitle,
                ["data"] = data_str
            })
        end
    end
    return results
end

function epinfo(source)
    return {source}
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

    local url = source_obj["url"]
    if url == nil then return nil, {} end
    local err, reply = kiko.httpget(url)
    if err ~= nil then error(err) end
    local content = reply["content"]

    local start = nil
    repeat
        local pos, _, cvid = string.find(content, "playPageInfo%s-=%s-({\".-})")
        if cvid ~= nil then
            start = pos
            break
        end
        local pos, _, cvid = string.find(content, "playPageInfo%s-||%s-({\".-})")
        if cvid ~= nil then
            start = pos
            break
        end
        error("视频Id解析失败")
    until true
    while string.sub(content, start, start)~='{' do
        start = start+1
    end
    local c = 1;
    local endPos = start
    for i=start+1,#content do
        if string.sub(content, i, i)=='{' then
            c = c+1
        elseif string.sub(content, i, i)=='}' then
            c = c-1
            if c == 0 then 
                endPos = i
                break
            end
        end
    end
    local playInfo = string.sub(content, start, endPos)
    local err, obj = kiko.json2table(playInfo) 
    if err ~= nil then 
        kiko.log(playInfo)
        error(err)
    end
    source["title"] = obj["tvName"]
    source["duration"] = str2time(obj["duration"])
    source_obj["vid"] = string.format("%d", obj["tvId"])
    source_obj["pieces"] = math.ceil(source["duration"] / 300 + 1)
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str
    return source, downloadDanmu(source_obj["vid"], source_obj["pieces"])
end