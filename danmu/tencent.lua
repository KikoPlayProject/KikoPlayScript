info = {
    ["name"] = "腾讯视频",
    ["id"] = "Kikyou.d.Tencent",
	["desc"] = "腾讯视频弹幕脚本",
	["version"] = "0.1"
}

supportedURLsRe = {
    "(https?://)?v\\.qq\\.com/x/cover/[a-zA-Z0-9/]+\\.html"
}

sampleSupporedURLs = {
    "https://v.qq.com/x/cover/gtn6ik9kapbiqm0.html",
    "https://v.qq.com/x/cover/gtn6ik9kapbiqm0/o0029t5qpp8.html"
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
    local err, reply = kiko.httpget("https://v.qq.com/x/search/", {["q"]=keyword})
    if err ~= nil then error(err) end
    local content = reply["content"]
    local parser = kiko.htmlparser(content)
    local spos, epos = string.find(content, "<div class=\"%s*result_item%s*result_item_[vh]")
    local results = {}
    while spos do
        parser:seekto(spos-1)
        parser:readnext()
        local isItem_v = string.find(parser:curproperty("class"), "result_item_v")
        repeat
            parser:readnext()
        until parser:curproperty("class")=="result_title"
        parser:readnext()
        local titleURL = parser:curproperty("href")
        if string.startsWith(titleURL, "https?://v.qq.com") and not string.startsWith(titleURL, "https?://v.qq.com/search_redirect.html") then
            local title = parser:readuntil("a", false)
            local title = string.gsub(title, "<.->", "")
            local title = string.gsub(title, "[\n\t]", "")
            if isItem_v then
                repeat
                    parser:readnext()
                until parser:curproperty("class")=="item" or parser:curproperty("class")=="result_btn_line" or parser:curproperty("class")=="result_video_fragment"
                while parser:curproperty("class")=="item" do
                    parser:readnext()
                    local url = parser:curproperty("href")
                    if string.startsWith(url, "https?://v.qq.com") then
                        local data = { ["url"] = url }
                        local _, data_str = kiko.table2json(data)
                        table.insert(results, {
                            ["title"] = title .. " " .. parser:readcontent(),
                            ["data"] = data_str
                        })
                    end
                    repeat
                        parser:readnext()
                    until parser:curnode()=="div"
                    parser:readnext()
                end
            else
                local data = { ["url"] = titleURL }
                local _, data_str = kiko.table2json(data)
                table.insert(results, {
                    ["title"] = title,
                    ["data"] = data_str
                })
            end
        end
        spos, epos = string.find(content, "<div class=\"%s*result_item%s*result_item_[vh]", epos)
    end
    return results
end

function epinfo(source)
    return {source}
end

function urlinfo(url)
    local pattens = {
        ["https?://v%.qq%.com/x/cover/[a-zA-Z0-9/]+%.html"]="qq",
        ["v%.qq%.com/x/cover/[a-zA-Z0-9/]+%.html"]="qq"
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
    local err, dmObj = kiko.json2table(content)
    if err ~= nil then return danmuList end
    local dmArray = dmObj["comments"]
    if dmArray == nil then return danmuList end
    for _, dm in ipairs(dmArray) do
        local text = dm["content"]
        if string.startsWith("VIP :") then
            text = string.sub(text, 6)
        end
        local dmType = 1
        local color = 0xffffff
        local err, pobj = kiko.json2table(dm["content_style"])
        if err==nil then
            local pos = tonumber(pobj["position"])
            if pos~=nil then
                if pos==5 then  --top
                    dmType = 5
                elseif pos==6 then  --bottom
                    dmType = 4
                end
            end
            local pcolor = pobj["gradient_colors"]
            if type(pcolor) == "table" then
                pcolor = pcolor[1]
            end
            if type(pcolor) == "string" then
                color = tonumber(pcolor, 16)
            else
                color = tonumber(pcolor)
            end
            if color == nil then
                color = 0xffffff
            end
        end
        table.insert(danmuList, {
            ["text"]=text,
            ["time"]=tonumber(dm["timepoint"])*1000,
            ["color"]=color,
            ["type"]=dmType,
            ["sender"]="[Tencent]" .. dm["opername"]
        })
    end
    return danmuList
end

function downloadDanmu(id, pieces)
    local baseUrl = "https://mfm.video.qq.com/danmu"
    local urls, querys = {}, {}
    for i=0,pieces do
        table.insert(urls, baseUrl)
        table.insert(querys, {
            ["otype"]="json", 
            ["target_id"]=id, 
            ["timestamp"]=string.format("%d", i*30)
        })
    end
    local danmuList = {}
    local _, rets = kiko.httpgetbatch(urls, querys)
    for _, v in ipairs(rets) do
        if not v["hasError"] then
            danmuList = decodeDanmu(v["content"], danmuList)
        end
    end
    return danmuList
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    if source_obj["targetid"] ~= nil then
        return nil, downloadDanmu(source_obj["targetid"], source_obj["pieces"])
    end

    local url = source_obj["url"]
    if url == nil then return nil, {} end
    local err, reply = kiko.httpget(url)
    if err ~= nil then error(err) end
    local content = reply["content"]

    local _, _, infoContent = string.find(content, "VIDEO_INFO = (.-)\n")
    if infoContent == nil then error("解析信息失败") end
    local err, obj = kiko.json2table(infoContent) 
    if err ~= nil then 
        kiko.log(playInfo)
        error(err)
    end
    source["title"] = obj["title"]
    source["duration"] = obj["duration"]
    source_obj["vid"] = obj["vid"]
    source_obj["pieces"] = math.ceil(source["duration"] / 30)
    local err, reply = kiko.httpget("http://bullet.video.qq.com/fcgi-bin/target/regist", {["vid"]=source_obj["vid"]})
    if err ~= nil then error(err) end
    local content = reply["content"]

    local xmlreader = kiko.xmlreader(content)
    while not xmlreader:atend() do
        if xmlreader:startelem() then
            if xmlreader:name()=="targetid" then
                source_obj["targetid"] = xmlreader:elemtext()
                break
            end
        end
        xmlreader:readnext()
    end
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str
    return source, downloadDanmu(source_obj["targetid"], source_obj["pieces"])
end