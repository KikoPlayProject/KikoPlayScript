info = {
    ["name"] = "5dm",
    ["id"] = "Kikyou.d.5dm",
	["desc"] = "5dm弹幕脚本",
	["version"] = "0.1",
    ["min_kiko"] = "2.0.0",
    ["label_color"] = "0xEB5D56",
}

supportedURLsRe = {
    "(https?://)?www\\.5dm\\.link/bangumi/dv(\\d+)?(link=[0-9]+)?"
}

sampleSupporedURLs = {
    "https://www.5dm.link/bangumi/dv56062?link=6"
}

function unescape(str)
    str = string.gsub( str, '&lt;', '<' )
    str = string.gsub( str, '&gt;', '>' )
    str = string.gsub( str, '&quot;', '"' )
    str = string.gsub( str, '&apos;', "'" )
    str = string.gsub( str, '&#(%d+);', function(n) return utf8.char(n) end )
    str = string.gsub( str, '&#x(%x+);', function(n) return utf8.char(tonumber(n,16)) end )
    str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
    return str
end


function epinfo(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    local baseUrl = "https://www.5dm.link/bangumi/dv" .. source_obj["dv"]
    local headers =  {
        ["User-Agent"] = kiko.browser.ua(),
    }
    local err, reply = kiko.httpget(baseUrl, {}, headers)
    if err ~= nil then error(err) end

    local content = reply["content"]
    local _, _, epContent = string.find(content, "<td>(.-)</td>")
    local results = {}
    if epContent ~= nil then
        local parser = kiko.htmlparser(epContent)
        while not parser:atend() do
            if parser:curnode()=="a" and parser:start() then
                local href = parser:curproperty("href")
                local _, _, dv, link = string.find(href, "dv(%d+)%?link=(%d+)")
                if dv ~= nil and link ~= nil then
                    local data = {
                        ["dv"] = dv,
                        ["link"] = link
                    }
                    local _, data_str = kiko.table2json(data)
                    title = parser:readuntil('a', false)
                    title = string.gsub(title,"<.->", "")
                    title = string.trim(title)
                    table.insert(results, {
                        ["title"] = title,
                        ["data"] = data_str
                    })
                end
            end
            parser:readnext()
        end
    end
    return results
end

function urlinfo(url)
    local pattens = {
        ["https?://www%.5dm%.link/bangumi/dv(%d+)%?link=(%d+)"]="dv_link",
        ["www%.5dm%.link/bangumi/dv(%d+)%?link=(%d+)"]="dv_link",
        ["https?://www%.5dm%.link/bangumi/dv(%d+)"]="dv",
        ["www%.5dm%.link/bangumi/dv(%d+)"]="dv"
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
    local _, _, dv = string.find(url, "dv(%d+)")
    local data = {
        ["dv"] = dv
    }
    if matched == "dv_link" then
        local _, _, link = string.find(url, "link=(%d+)")
        data["link"] = link
    end
    local _, data_str = kiko.table2json(data)
    return epinfo({
        ["data"] = data_str
    })
end

function downloadDanmu(cid)
    local danmuUrl = "https://www.5dm.link/player/nxml.php"
    local query = {
        ["id"] = cid
    }
    local headers = {
        ["Accept"]="application/json",
        ["User-Agent"] = kiko.browser.ua(),
    }

    local err, reply = kiko.httpget(danmuUrl, query, headers)
    if err ~= nil then error(err) end

    local danmuContent = reply["content"]
    local err, obj = kiko.json2table(danmuContent)
    local danmuArray = obj["data"]

    local danmus = {}

    for _, dmObj in ipairs(danmuArray) do
        local time = tonumber(dmObj[1]) * 1000

        local dmType = 0
        if dmObj[2] == "top" then
            dmType = 1
        elseif dmObj[2] == "bottom" then
            dmType = 2
        end
        
        local color = dmObj[3]
        if color == "#fff" then
            color = 0xffffff
        else
            if string.sub(color, 1, 1) == "#" then
                color = tonumber(string.sub(color, 2), 16)
            else
                if string.sub(color, 1, 3) == "rgb" then
                    color = string.sub(color, 5, -2)
                    color = string.gsub(color, " ", "")
                    local r, g, b = string.match(color, "(%d+),(%d+),(%d+)")
                    color = tonumber(r) << 16 | tonumber(g) << 8 | tonumber(b)
                end
            end
        end

        local sender = tostring(dmObj[4])

        local text = unescape(dmObj[5])
        if text == "文明追番，请勿剧透！" then
            goto continue
        end

         table.insert(danmus, {
            ["text"]=text,
            ["time"]=time,
            ["color"]=color,
            ["fontsize"]=1,
            ["type"]=dmType,
            ["sender"]=sender
        })

        ::continue::
    end
    return danmus
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    
    if source_obj["cid"] ~= nil then
        return nil, downloadDanmu(source_obj["cid"])
    end

    local url = "https://www.5dm.link/bangumi/dv" .. source_obj["dv"]
    if source_obj["link"] ~= nil then
        url = url .. "?link=" .. source_obj["link"]
    end
    local headers =  {
        ["User-Agent"] = kiko.browser.ua(),
    }
    local err, reply = kiko.httpget(url, {}, headers)

    if err ~= nil then error(err) end
    local content = reply["content"]

    local _, _, cid = string.find(content, "cid=(.-)&")
    if cid == nil then error("cid解析失败") end
    source_obj["cid"] = cid
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str

    return source, downloadDanmu(cid)
end
