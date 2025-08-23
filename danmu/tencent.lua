info = {
    ["name"] = "腾讯视频",
    ["id"] = "Kikyou.d.Tencent",
	["desc"] = "腾讯视频弹幕脚本",
	["version"] = "0.4",
    ["min_kiko"] = "2.0.0",
    ["label_color"] = "0xD39900",
}

supportedURLsRe = {
    "(https?://)?v\\.qq\\.com/x/cover/[a-zA-Z0-9/]+\\.html"
}

sampleSupporedURLs = {
    "https://v.qq.com/x/cover/gtn6ik9kapbiqm0/o0029t5qpp8.html"
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

    local err, reply = kiko.httpget(url)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, title = string.find(content, "<title>(.-)</title>")
    if title == nil then title = "unknown" end

    table.insert(results, {
        ["title"] = title,
        ["data"] = data_str
    })
    return results
end

function decodeDanmu(content, danmuList)
    local err, dmObj = kiko.json2table(content)
    if err ~= nil then return danmuList end
    local dmArray = dmObj["barrage_list"]
    if dmArray == nil then return danmuList end
    for _, dm in ipairs(dmArray) do
        local text = dm["content"]
        if string.startswith(text, "VIP :") then
            text = string.sub(text, 6)
        end
        local dmType = 0
        local color = 0xffffff
        local err, pobj = kiko.json2table(dm["content_style"])
        if err==nil then
            local pos = tonumber(pobj["position"])
            if pos~=nil then
                if pos==2 then  --top
                    dmType = 1
                elseif pos==3 then  --bottom
                    dmType = 2
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
            ["time"]=tonumber(dm["time_offset"]),
            ["color"]=color,
            ["type"]=dmType,
            ["date"]=dm["create_time"],
            ["sender"]="[Tencent]" .. dm["nick"]
        })
    end
    return danmuList
end

function downloadDanmu(id)
    local baseUrl = string.format("https://dm.video.qq.com/barrage/base/%s", id)
    local err, reply = kiko.httpget(baseUrl)
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply["content"]) 
    if err ~= nil then 
        kiko.log(reply["content"])
        error(err)
    end
    local prefix = string.format("https://dm.video.qq.com/barrage/segment/%s/", id)
    local urls = {}
    for k, v in pairs(obj["segment_index"]) do
        table.insert(urls, prefix .. v["segment_name"])
    end
    local danmuList = {}
    local _, rets = kiko.httpgetbatch(urls)
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

    if source_obj["vid"] ~= nil then
        return nil, downloadDanmu(source_obj["vid"])
    end

    local url = source_obj["url"]
    if url == nil then return nil, {} end
    local s, e = string.lastindexof(url, '/'), string.lastindexof(url, '.')
    if s == nil or e == nil then error("vid not found") end
    local vid = string.sub(url, s + 1, e - 1)
    if vid == nil or #vid == 0 then error("vid not found") end
    source_obj["vid"] = vid
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str
    return source, downloadDanmu(vid)
end
