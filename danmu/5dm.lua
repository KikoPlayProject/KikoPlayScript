info = {
    ["name"] = "5dm",
    ["id"] = "Kikyou.d.5dm",
    ["desc"] = "5dm弹幕脚本",
    ["version"] = "0.5",
    ["min_kiko"] = "2.0.0",
    ["label_color"] = "0xEB5D56",
}

settings = {
    ["latest_addr"] = {
        ["title"] = "5dm最新地址",
        ["desc"] = "地址不要添加'https://'前缀",
        ["default"] = "www.5dm.dev",
    }
}

supportedURLsRe = {
    "(https?://)?(www\\.)?5dm\\.dev/[A-Za-z0-9_-]+/dv\\d+/?(\\?[^#\\s]*)?(#.*)?",
}

sampleSupporedURLs = {
    "https://www.5dm.dev/bangumi/dv56062?link=6",
    "https://www.5dm.dev/end/dv17582?line=1&link=2"
}

local function unescape(str)
    str = string.gsub(str, '&lt;', '<')
    str = string.gsub(str, '&gt;', '>')
    str = string.gsub(str, '&quot;', '"')
    str = string.gsub(str, '&apos;', "'")
    str = string.gsub(str, '&#(%d+);', function(n) return utf8.char(tonumber(n)) end)
    str = string.gsub(str, '&#x(%x+);', function(n) return utf8.char(tonumber(n, 16)) end)
    return string.gsub(str, '&amp;', '&')
end

local function decodeJson(content)
    local err, obj = kiko.json2table(content)
    if err ~= nil then error("5dm JSON解析失败: " .. err) end
    if type(obj) ~= "table" then error("5dm返回的数据格式不正确") end
    return obj
end

local function encodeJson(obj)
    local err, content = kiko.table2json(obj, 'compact')
    if err ~= nil then error(err) end
    return content
end

local function get(url, query, headers)
    headers = headers or {}
    headers["User-Agent"] = kiko.browser.ua()
    local err, reply = kiko.httpget(url, query or {}, headers)
    if err ~= nil then error(err) end
    if reply["hasError"] then error(reply["errInfo"] or "5dm请求失败") end
    if reply["statusCode"] and reply["statusCode"] >= 400 then
        error("5dm请求失败: HTTP " .. tostring(reply["statusCode"]))
    end
    return reply["content"]
end

local function parseUrl(url)
    url = unescape(url):gsub("#.*$", ""):gsub("^https?://", "")
    local host, category, dv, tail = url:match("^([^/]+)/([%w_-]+)/dv(%d+)(.*)$")
    if not dv or (host ~= settings["latest_addr"] and host ~= "www.5dm.dev" and host ~= "5dm.dev") then
        return nil
    end
    tail = tail:gsub("^/", "")
    if tail ~= "" and tail:sub(1, 1) ~= "?" then return nil end
    local data = { ["dv"] = dv, ["category"] = category }
    for key, value in tail:gmatch("[?&]([^=&]+)=([^&]*)") do
        if key == "line" or key == "link" then
            if not value:match("^%d+$") or tonumber(value) < 1 then return nil end
            data[key] = value
        end
    end
    return data
end

local function pageUrl(data)
    return string.format("https://%s/%s/dv%s", settings["latest_addr"], data["category"] or "bangumi", data["dv"])
end

local function episodeUrl(data)
    return string.format("%s?line=%s&link=%s", pageUrl(data), data["line"], data["link"])
end

local function sourceId(data)
    return string.format("%s_%s_%s", data["dv"], data["line"], data["link"])
end

local function playerConfig(content)
    local json = content:match([[<script[^>]-id=["']moe%-player%-config["'][^>]*>(.-)</script%s*>]])
    if not json then error("5dm播放器配置解析失败，未找到moe-player-config") end
    local cfg = decodeJson(json)
    if not cfg["id"] or type(cfg["rest"]) ~= "string" or cfg["rest"] == "" then
        error("5dm播放器配置缺少id或rest")
    end
    for _, key in ipairs({ "id", "line", "episode" }) do
        local value = tonumber(cfg[key])
        if not value or value < 1 or value ~= math.floor(value) or value == math.huge then
            error("5dm播放器配置中的" .. key .. "无效")
        end
        cfg[key] = string.format("%.0f", value)
    end
    return cfg
end

local function loadPage(source)
    local data = source["data"] and source["data"] ~= "" and decodeJson(source["data"]) or {}
    local fromUrl = source["url"] and parseUrl(source["url"])
    if fromUrl then
        for key, value in pairs(fromUrl) do
            if data[key] == nil then data[key] = value end
        end
    end
    if not data["dv"] then error("5dm弹幕源缺少视频编号，请从播放页URL重新添加") end
    local query = {}
    if data["line"] then query["line"] = tostring(data["line"]) end
    if data["link"] then query["link"] = tostring(data["link"]) end
    local content = get(pageUrl(data), query)
    local cfg = playerConfig(content)
    data["dv"] = tostring(cfg["id"])
    data["line"] = tostring(cfg["line"])
    data["link"] = tostring(cfg["episode"])
    -- 旧版缓存的cid不再用于请求，每次读取页面以取得当前集的配置和nonce。
    data["cid"] = nil
    return data, cfg, content
end

function epinfo(source)
    local data, cfg, content = loadPage(source)
    local results, seen = {}, {}
    local hasRows = false
    for attrs, row in content:gmatch("<tr([^>]*)>(.-)</tr%s*>") do
        local line = attrs:match([=[data%-source%-row=["'](%d+)["']]=])
        if line then hasRows = true end
        if line == data["line"] then
            local parser = kiko.htmlparser(row)
            while not parser:atend() do
                if parser:curnode() == "a" and parser:start() then
                    local class = " " .. (parser:curproperty("class") or "") .. " "
                    if class:match("%smultilink%-btn%s") then
                        local href = unescape(parser:curproperty("href"))
                        if href:sub(1, 1) == "?" then
                            href = pageUrl(data) .. href
                        elseif href:sub(1, 1) == "/" then
                            href = "https://" .. settings["latest_addr"] .. href
                        end
                        local ep = parseUrl(href)
                        if ep and ep["dv"] == data["dv"] and ep["link"] then
                            ep["line"] = ep["line"] or line
                            local id = sourceId(ep)
                            if ep["line"] == line and not seen[id] then
                                local title = parser:curproperty("title")
                                if not title or title == "" then title = parser:readuntil('a', false):gsub("<.->", "") end
                                table.insert(results, {
                                    ["title"] = string.trim(unescape(title)),
                                    ["data"] = encodeJson(ep),
                                    ["url"] = episodeUrl(ep),
                                    ["srcid"] = id,
                                })
                                seen[id] = true
                            end
                        end
                    end
                end
                parser:readnext()
            end
        end
    end
    if #results == 0 then
        if hasRows then error("5dm分集列表解析失败") end
        -- 单集页面可能没有选集表。
        table.insert(results, {
            ["title"] = cfg["episodeTitle"] or source["title"] or ("第" .. data["link"] .. "集"),
            ["data"] = encodeJson(data),
            ["url"] = episodeUrl(data),
            ["srcid"] = sourceId(data),
        })
    end
    return results
end

function urlinfo(url)
    local data = parseUrl(url)
    if not data then error("不支持的URL") end
    return epinfo({ ["data"] = encodeJson(data) })
end

local function danmuColor(value)
    local color = tonumber(value)
    if not color and type(value) == "string" then
        local hex = value:match("^#(%x+)$")
        if hex and #hex == 3 then hex = hex:gsub(".", "%0%0") end
        if hex and #hex == 6 then color = tonumber(hex, 16) end
        local r, g, b = value:match("^rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$")
        if r and tonumber(r) <= 255 and tonumber(g) <= 255 and tonumber(b) <= 255 then
            color = tonumber(r) * 65536 + tonumber(g) * 256 + tonumber(b)
        end
    end
    if not color or color ~= color or color < 0 or color > 0xffffff then return 0xffffff end
    return math.floor(color)
end

local function appendDanmu(danmus, list)
    for _, item in ipairs(list) do
        if type(item) == "table" then
            local time, dmType, color, author, text
            if item[1] ~= nil then
                time, dmType, color, author, text = item[1], item[2], item[3], item[4], item[5]
            else
                time, dmType, color = item["time"], item["type"], item["color"]
                author, text = item["author"] or item["id"], item["text"]
            end
            if text ~= nil and tostring(text) ~= "文明追番，请勿剧透！" then
                time = tonumber(time) or 0
                if time ~= time or time == math.huge or time == -math.huge then time = 0 end
                if dmType == "top" then dmType = 1
                elseif dmType == "bottom" then dmType = 2
                else dmType = tonumber(dmType) or 0 end
                if dmType ~= 1 and dmType ~= 2 then dmType = 0 end
                table.insert(danmus, {
                    ["text"] = tostring(text),
                    ["time"] = time * 1000,
                    ["color"] = danmuColor(color),
                    ["fontsize"] = 1,
                    ["type"] = dmType,
                    ["sender"] = "[5dm]" .. tostring(author or "0"),
                })
            end
        end
    end
end

local function downloadDanmu(cfg, referer)
    local headers = { ["Accept"] = "application/json", ["Referer"] = referer }
    if type(cfg["nonce"]) == "string" and cfg["nonce"] ~= "" then
        headers["X-WP-Nonce"] = cfg["nonce"]
    end
    local query = { ["line"] = tostring(cfg["line"]), ["episode"] = tostring(cfg["episode"]) }
    local obj = decodeJson(get(cfg["rest"], query, headers))
    local list = obj["data"]
    if type(list) ~= "table" then list = obj["records"] end
    if type(list) ~= "table" or (obj["code"] ~= nil and tonumber(obj["code"]) ~= 0) then
        error("5dm弹幕接口返回错误: " .. tostring(obj["message"] or obj["code"] or "缺少data/records"))
    end
    local danmus = {}
    appendDanmu(danmus, list)
    if type(cfg["external_danmaku"]) == "string" and cfg["external_danmaku"] ~= "" then
        -- 外部弹幕属于补充数据，请求失败时保留已取得的站内弹幕。
        local ok, external = pcall(function()
            return decodeJson(get(cfg["external_danmaku"], {}, { ["Referer"] = referer }))
        end)
        if ok then
            appendDanmu(danmus, type(external["data"]) == "table" and external["data"] or external)
        else
            kiko.log("5dm外部弹幕获取失败: " .. tostring(external))
        end
    end
    return danmus
end

function danmu(source)
    local data, cfg = loadPage(source)
    local url = episodeUrl(data)
    local danmus = downloadDanmu(cfg, url)
    local dataStr, srcid = encodeJson(data), sourceId(data)
    if source["data"] ~= dataStr or source["srcid"] ~= srcid or source["url"] ~= url then
        source["data"], source["srcid"], source["url"] = dataStr, srcid, url
        return source, danmus
    end
    return nil, danmus
end
