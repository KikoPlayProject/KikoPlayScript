info = {
    ["name"] = "动画疯",
    ["id"] = "Kikyou.d.Gamer",
	["desc"] = "巴哈姆特动画疯弹幕脚本",
	["version"] = "0.1.2"
}

supportedURLsRe = {
    "(https?://)?ani\\.gamer\\.com\\.tw/animeVideo\\.php\\?sn=[0-9]+/?"
}

sampleSupporedURLs = {
    "https://ani.gamer.com.tw/animeVideo.php?sn=9285"
}

settings = {
    ["user_agent"]={
        ["title"]="UA",
        ["desc"]="User Agent",
    },
    ["cookie"]={
        ["title"]="Cookie",
        ["desc"]="Cookie",
    },
}


function search(keyword)
    local _, tradKw = kiko.sttrans(keyword, false)
    local query = {
        ["kw"]=tradKw
    }
    local headers = {}
    if #settings["user_agent"] > 0 and #settings["cookie"] > 0 then
        headers = {
            ["User-Agent"] = settings["user_agent"],
            ["Cookie"] = settings["cookie"],
        }
    end
    local err, reply = kiko.httpget("https://ani.gamer.com.tw/search.php", query, headers)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, searchContent = string.find(content, "<div class=\"animate%-theme%-list\">(.+)<div class=\"animate%-theme%-list animate%-wish\">")
    if searchContent == nil then
        _, _, searchContent = string.find(content, "<div class=\"animate%-theme%-list\">(.+)<div class=\"footer\">")
    end
    if searchContent == nil then return {} end

    local parser = kiko.htmlparser(searchContent)
    local curData, curTitle, curDesc = nil, nil, nil
    local results = {}
    while not parser:atend() do
        if parser:curproperty("class")=="theme-list-main" and parser:start() then
            local href = parser:curproperty("href")
            local _, _, sn = string.find(href, "animeRef%.php%?sn=(%d+)")
            if sn ~= nil then curData = sn end
        elseif parser:curproperty("class")=="theme-name" then
            curTitle = parser:readcontent()
        elseif parser:curproperty("class")=="theme-time" then
            curDesc = parser:readcontent()
            if curData ~= nil and curTitle ~= nil and curDesc ~= nil then
                local data = {
                    ["sn"] = tostring(curData),
                    ["fromSearch"] = true
                }
                local _, data_str = kiko.table2json(data)
                table.insert(results, {
                    ["title"] = curTitle,
                    ["desc"] = curDesc,
                    ["data"] = data_str
                })
                curData, curTitle, curDesc = nil, nil, nil
            end
        end
        parser:readnext()
    end
    return results
end

function epinfo(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    local baseUrl = "https://ani.gamer.com.tw/animeVideo.php"
    if source_obj["fromSearch"] then
        baseUrl = "https://ani.gamer.com.tw/animeRef.php"
    end
    local query = {
        ["sn"]=source_obj["sn"]
    }
    local headers = {}
    if #settings["user_agent"] > 0 and #settings["cookie"] > 0 then
        headers = {
            ["User-Agent"] = settings["user_agent"],
            ["Cookie"] = settings["cookie"],
        }
    end
    local err, reply = kiko.httpget(baseUrl, query, headers)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, epContent = string.find(content, "<section class=\"season\">(.-)</section>")
    local results = {}
    if epContent ~= nil then
        local parser = kiko.htmlparser(epContent)
        while not parser:atend() do
            if parser:curnode()=="a" and parser:start() then
                local href = parser:curproperty("href")
                local _, _, sn = string.find(href, "%?sn=(%d+)")
                if sn ~= nil then
                    local data = {
                        ["sn"] = sn
                    }
                    local _, data_str = kiko.table2json(data)
                    table.insert(results, {
                        ["title"] = parser:readcontent(),
                        ["data"] = data_str
                    })
                end
            end
            parser:readnext()
        end
    else
        local _, _, sn, title = string.find(content, "animefun.videoSn.?=.?(%d+);.-animefun.title.?=.?'(.-)'")
        if sn ~= nil and title ~= nil then
            local data = {
                ["sn"] = sn
            }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = title,
                ["data"] = data_str
            })
        end
    end
    return results
end

function urlinfo(url)
    local pattens = {
        ["https?://ani%.gamer%.com%.tw/animeVideo%.php%?sn=%d+"]="sn",
        ["ani%.gamer%.com%.tw/animeVideo%.php%?sn=%d+"]="sn"
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
    local _, _, sn = string.find(url, "sn=(%d+)")
    local data = {
        ["sn"] = sn
    }
    local _, data_str = kiko.table2json(data)
    return epinfo({
        ["data"] = data_str
    })
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    local headers = {}
    if #settings["user_agent"] > 0 and #settings["cookie"] > 0 then
        headers = {
            ["User-Agent"] = settings["user_agent"],
            ["Cookie"] = settings["cookie"],
        }
    end
    local danmuUrl = "https://ani.gamer.com.tw/ajax/danmuGet.php"
    local postdata = string.format("sn=%s", source_obj["sn"])
    headers["Content-Length"] = tostring(#postdata)
    local err, reply = kiko.httppost(danmuUrl, postdata, headers)
    if err ~= nil then error(err) end
    local danmuContent = reply["content"]
    local err, array = kiko.json2table(danmuContent)
    if err ~= nil or array == nil then error(err) end

    local danmus = {}
    for _, dmObj in ipairs(array) do
        local text = dmObj["text"]
        local time = tonumber(dmObj["time"])*100
        local pos = tonumber(dmObj["position"])
        local dmType = pos  -- pos=1(top),pos=2(bottom)
        local size = tonumber(dmObj["size"])
        if size == 0 then  --small
            size = 1
        elseif size == 2 then  --large
            size = 2
        else  --normal
            size = 0
        end
        local color = tonumber(string.sub(dmObj["color"], 2),16)
        local sender = "[Gamer]" .. tostring(dmObj["userid"])
        table.insert(danmus, {
            ["text"]=text,
            ["time"]=time,
            ["color"]=color,
            ["fontsize"]=size,
            ["type"]=dmType,
            ["sender"]=sender
        })
    end
    return nil, danmus
end