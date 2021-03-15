info = {
    ["name"] = "Tucao",
    ["id"] = "Kikyou.d.Tucao",
	["desc"] = "Tucao弹幕脚本",
	["version"] = "0.1"
}

supportedURLsRe = {
    "(https?://)?www\\.tucao\\.one/play/h[0-9]+(#[0-9]+)?/?"
}

sampleSupporedURLs = {
    "http://www.tucao.one/play/h4077044/"
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

function search(keyword)
    local query = {
        ["m"]="search",
        ["a"]="init2",
        ["time"]="all",
        ["q"]=keyword
    }
    local err, reply = kiko.httpget("http://www.tucao.one/index.php", query)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local start = string.find(content, "<div class=\"search_list\" style=\"border%-top:1px solid #eee;\">")
    if start == nil then return {} end

    local parser = kiko.htmlparser(content)
    parser:seekto(start-1)
    
    local curData, curTitle, curDesc = nil, nil, nil
    local results = {}
    local isStart = false
    while not parser:atend() do
        if parser:curproperty("class")=="blue" then
            local href = parser:curproperty("href")
            local _, _, hid = string.find(href, "h(%d+)")
            if hid ~= nil then
                curData = hid
                curTitle = parser:readcontent()
            end
        elseif parser:curproperty("class")=="d" then
            curDesc = parser:readcontent()
            if curData ~= nil and curTitle ~= nil and curDesc ~= nil then
                local data = {
                    ["hid"] = curData,
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
    local baseUrl = string.format("http://www.tucao.one/play/h%s/", source_obj["hid"])
    local err, reply = kiko.httpget(baseUrl)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, epContent = string.find(content, "<ul id=\"player_code\" mid=\".-\"><li>(.-)</li><li>.-</li></ul>")
    local results = {}
    if epContent ~= nil then
        local eps = string.split(epContent, '|')
        local _, _, pageTitle = string.find(content, "<h1 class=\"show_title\">(.-)<span style=\"color:#F40;\">")
        local index = 0
        for i = 2,#eps do
            local title = string.split(eps[i], '*')[1]
            if title == nil or #title == 0 then
                if pageTitle == nil or #pageTitle == 0 then
                    title = source["title"]
                else
                    title = pageTitle
                end
            end
            local data = {
                ["hid"] = source_obj["hid"],
                ["index"] = tostring(index)
            }
            local _, data_str = kiko.table2json(data)
            index = index + 1
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
        ["https?://www%.tucao%.one/play/h%d+/?"]="hid",
        ["www%.tucao%.one/play/h%d+/?"]="hid",
        ["https?://www%.tucao%.one/play/h%d+#%d+/?"]="hindex",
        ["www%.tucao%.one/play/h%d+#%d+/?"]="hindex",
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
    local re = "h(%d+)"
    if matched == "hindex" then 
        re = "h(%d+)#(%d+)"
    end
    local _, _, hid, index = string.find(url, re)
    if index == nil then index = "0" end
    local data = {
        ["hid"] = hid,
        ["index"] = index
    }
    local _, data_str = kiko.table2json(data)
    return epinfo({
        ["title"]="",
        ["data"] = data_str
    })
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    local query = {
        ["m"]="mukio",
        ["a"]="init",
        ["c"]="index",
        ["playerID"]=string.format("11-%s-1-%s", source_obj["hid"], source_obj["index"])
    }
    local err, reply = kiko.httpget("http://www.tucao.one/index.php", query)
    if err ~= nil then error(err) end
    local content = reply["content"]

    local danmus = {}
    local xmlreader = kiko.xmlreader(content)
    while not xmlreader:atend() do
        if xmlreader:startelem() and xmlreader:name()=="d" then
            if xmlreader:hasattr("p") then
                local attrs = string.split(xmlreader:attr("p"), ',')
                if #attrs >= 5 then
                    local text = xmlreader:elemtext()
                    local time = tonumber(attrs[1]) * 1000
                    local mode = tonumber(attrs[2])
                    local dmType = 0 --rolling
                    if mode == 4 then
                        dmType = 2  --bottom
                    elseif mode == 5 then
                        dmType = 1  --top
                    end
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
                    local sender = "[Tucao]"
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