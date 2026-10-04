-- 豆瓣电影 Scraper
-- KikoPlay 资料脚本，从豆瓣电影获取相关信息
--
-- 关于自动关联，建议的[电视剧]目录层级以及命名方式  (KikoPlay 2.0开始文件识别脚本与资料脚本分离，这个脚本中的match函数不会被调用)
-- > 我有一个朋友
--      -- 01.mp4
--      -- 02.mp4
--      -- ...
--      -- 番外.mp4
-- > 克拉克森的农场
--      -- S01E01.mp4
--      -- S01E02.mp4
--      -- ...
--      -- S02E02.mp4
--      -- ...

----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "豆瓣电影",
    ["id"] = "Kikyou.l.Douban",
    ["desc"] = "豆瓣电影脚本，从 movie.douban.com 中获取视频信息",
    ["version"] = "0.3.1",
    ["min_kiko"] = "2.0.0"
}


local function url_decode(str)
    if not str then return "" end
    -- 处理加号表示的空格
    str = string.gsub(str, "+", " ")
    -- 处理百分比编码的字符
    str = string.gsub(str, "%%(%x%x)", function(hex)
        -- 将16进制字符串转换为字符
        return string.char(tonumber(hex, 16))
    end)
    return str
end

-- 解析查询字符串部分
local function parse_query_string(query_str)
    local params = {}
    if not query_str or query_str == "" then
        return params
    end
    
    -- 分割参数对
    for pair in string.gmatch(query_str, "[^&]+") do
        if pair ~= "" then
            -- 分割键和值，处理没有值的参数（如?debug&verbose）
            local key, value = string.match(pair, "^([^=]+)=?(.*)$")
            if key then
                -- 解码键和值
                key = url_decode(key)
                value = url_decode(value)
                
                -- 处理多个同名参数的情况
                if params[key] then
                    -- 如果已经存在该键，将其转为数组
                    if type(params[key]) ~= "table" then
                        params[key] = {params[key]}
                    end
                    table.insert(params[key], value)
                else
                    params[key] = value
                end
            end
        end
    end
    
    return params
end

-- 解析完整URL并获取查询参数，处理转义字符
local function parse_url_query(url)
    if not url or type(url) ~= "string" then
        return {}
    end
    
    -- 提取查询字符串部分（问号后面、锚点前面的内容）
    local query_str = string.match(url, "?([^#]*)")
    
    -- 解析查询字符串
    return parse_query_string(query_str)
end

-- HTML实体解码函数
local function html_entity_decode(str)
    if not str or type(str) ~= "string" then
        return ""
    end
    
    -- 常见的HTML命名实体映射表
    local entities = {
        ["&amp;"]  = "&",   -- 和号
        ["&quot;"] = "\"",  -- 双引号
        ["&apos;"] = "'",   -- 单引号
        ["&lt;"]   = "<",   -- 小于号
        ["&gt;"]   = ">",   -- 大于号
        ["&nbsp;"] = " ",   -- 非换行空格
        ["&copy;"] = "©",   -- 版权符号
        ["&reg;"]  = "®",   -- 注册商标
        ["&trade;"]= "™",   -- 商标符号
        ["&cent;"] = "¢",   -- 分
        ["&pound;"]= "£",   -- 英镑
        ["&yen;"]  = "¥",   -- 日元
        ["&euro;"] = "€",   -- 欧元
    }
    
    -- 单次解码，数字实体使用 Unicode，避免中文实体超出 string.char 的范围。
    return (string.gsub(str, "&(#?[%w]+);", function(entity)
        local named = entities["&" .. entity .. ";"]
        if named then return named end
        local hex = string.match(entity, "^#[xX](%x+)$")
        local decimal = string.match(entity, "^#(%d+)$")
        local code = hex and tonumber(hex, 16) or tonumber(decimal)
        if code and code > 0 and code <= 0x10ffff and not (code >= 0xd800 and code <= 0xdfff) then
            return utf8.char(code)
        end
        return "&" .. entity .. ";"
    end))
end

local function plain_text(str)
    return string.trim(html_entity_decode(string.gsub(str or "", "<.->", " ")))
end

-- 页面可能包含多个 JSON-LD 块，只接受当前豆瓣条目的数据。
local function read_detail_data(content, subject_id)
    local reason = "豆瓣页面中未找到详情数据"
    if type(content) ~= "string" then return nil, reason end
    local candidate, media_candidate
    for attributes, json in string.gmatch(content, "<script%s+([^>]-)>(.-)</script%s*>") do
        if string.find(" " .. attributes, [=[%stype%s*=%s*["']application/ld%+json["']]=]) then
            local err, data = kiko.json2table(json)
            if err ~= nil or type(data) ~= "table" then
                reason = "豆瓣详情 JSON 解析失败：" .. tostring(err or "数据格式不正确")
            elseif type(data.url) == "string" then
                if string.match(data.url, "/subject/(%d+)") == subject_id then
                    if data["@type"] == "Movie" or data["@type"] == "TVSeries" then
                        if type(data.name) == "string" and string.trim(data.name) ~= ""
                            and type(data.datePublished) == "string"
                            and string.match(data.datePublished, "^%d%d%d%d%-%d%d%-%d%d") then
                            return data
                        end
                        media_candidate = media_candidate or data
                    end
                    candidate = candidate or data
                else
                    reason = "豆瓣返回的条目与所选条目不一致，请重新搜索后再试"
                end
            end
        end
    end
    -- 保留不完整的影视数据，让 detail 给出缺标题/日期的具体提示。
    if media_candidate or candidate then return media_candidate or candidate end
    return nil, reason
end

local function is_verification_page(content)
    -- sec 是当前自动验证表单；captcha-solution 是需要人工输入的验证码。
    return string.find(content, [=[<form[^>]*%sname%s*=%s*["']sec["']]=]) ~= nil
        or string.find(content, [=[<form[^>]*%sid%s*=%s*["']sec["']]=]) ~= nil
        or string.find(content, "captcha%-solution") ~= nil
end

local function fetch_detail(url, subject_id)
    local headers = {}
    if kiko.browser and kiko.browser.ua then
        headers["User-Agent"] = kiko.browser.ua()
    end
    local err, reply = kiko.httpget(url, {}, headers)
    if err == nil and type(reply) == "table" then
        local data = read_detail_data(reply.content, subject_id)
        if data then return reply.content, data end
    end

    kiko.log("豆瓣详情：普通请求未取得条目数据，尝试内置浏览器")
    if not kiko.browser or not kiko.browser.create or not kiko.sleep then
        error("豆瓣详情需要内置浏览器验证，请使用 KikoPlay 2.0.0 或以上版本")
    end
    local browser = kiko.browser.create()
    local loaded = browser:load(url, {}, 15000)
    local content = browser:html() or ""
    local data, reason = read_detail_data(content, subject_id)
    if data then return content, data end
    if not loaded then
        error("豆瓣详情页加载失败或超时，请检查网络后重试")
    end

    -- load 只等待页面加载，验证页的异步计算和跳转可能尚未完成。
    for _ = 1, 50 do
        kiko.sleep(200)
        content = browser:html() or ""
        data, reason = read_detail_data(content, subject_id)
        if data then return content, data end
    end

    if is_verification_page(content) then
        kiko.log("豆瓣详情：需要完成网页验证")
        browser:show("请完成豆瓣验证，看到所选条目的详情后关闭窗口；关闭未完成的页面将取消本次获取。")
        content = browser:html() or ""
        data, reason = read_detail_data(content, subject_id)
        if data then return content, data end
        error("豆瓣验证未完成或已取消，请重试。" .. reason)
    end
    error(reason .. "，请稍后重试或检查豆瓣页面是否发生变化")
end

local function is_image_content(content)
    if type(content) ~= "string" or #content < 12 then return false end
    return string.sub(content, 1, 3) == "\255\216\255"
        or string.sub(content, 1, 8) == "\137PNG\r\n\26\n"
        or (string.sub(content, 1, 4) == "RIFF" and string.sub(content, 9, 12) == "WEBP")
        or string.sub(content, 1, 6) == "GIF87a"
        or string.sub(content, 1, 6) == "GIF89a"
end

local function image_download_url(url)
    -- 豆瓣这些图片同时提供 JPEG 版本，兼容未安装 WebP 解码插件的 Qt。
    -- 只调整本次下载地址，保留 coverurl/imgurl 中的原始来源 URL。
    local path, suffix = string.match(url, "^([^?#]+)(.*)$")
    if path and string.match(path, "^https?://img%d+%.doubanio%.com/view/") then
        return (string.gsub(path, "%.webp$", ".jpg")) .. suffix
    end
    return url
end

local function load_images(anime)
    -- 宿主按 URL 下载时不带 Referer，豆瓣 CDN 会返回 418。
    -- 直接提供二进制 cover/image，宿主会保存图片并跳过无请求头的下载。
    local urls, querys, headers, targets = {}, {}, {}, {}
    local image_headers = { ["Referer"] = anime.url }
    if kiko.browser and kiko.browser.ua then
        image_headers["User-Agent"] = kiko.browser.ua()
    end
    local function add(target, url_key, image_key, label)
        local url = target[url_key]
        if type(url) ~= "string" or url == "" then return end
        table.insert(urls, image_download_url(url))
        table.insert(querys, {})
        table.insert(headers, image_headers)
        table.insert(targets, { object = target, key = image_key, label = label })
    end
    add(anime, "coverurl", "cover", "封面")
    for _, character in ipairs(anime.crt) do
        add(character, "imgurl", "image", "人物：" .. character.name)
    end
    if #urls == 0 then return end

    local err, replies = kiko.httpgetbatch(urls, querys, headers)
    if err ~= nil or type(replies) ~= "table" then
        kiko.log("豆瓣图片下载失败：" .. tostring(err or "未收到响应"))
        return
    end
    for i, target in ipairs(targets) do
        local reply = replies[i]
        local status = type(reply) == "table" and tonumber(reply.statusCode)
        if status and status >= 200 and status < 300 and not reply.hasError and is_image_content(reply.content) then
            target.object[target.key] = reply.content
        else
            -- CDN 的错误文本也可能标记为 image/webp，不能只检查 Content-Type。
            local reason = type(reply) == "table" and reply.errInfo
            if not reason or reason == "" then reason = status and ("HTTP " .. status .. "，响应不是有效图片") or "未收到图片响应" end
            kiko.log("豆瓣图片下载失败（" .. target.label .. "）：" .. reason)
        end
    end
end


-- 完成搜索功能 ，可选
-- keyword： string，搜索关键字
-- options：table，如果脚本中包含searchsettings，可以通过options["xxx"]获取设置项的值；否则不会传递这个参数
-- 返回：Array[AnimeLite]
-- 需要注意的是，除了下面定义的AnimeLite结构，还可以增加一项eps，类型为Array[EpInfo]，包含动画的剧集列表。
function search(keyword, options)
    kiko.log("function search")
    options = options or {}
    local mediais = {}

    local err, reply = kiko.httpget(string.format("https://www.douban.com/search?cat=1002&q=%s", keyword))
    if err ~= nil then error(err) end
    local content = reply["content"]

    local result = string.find(content, "no%-result")
    if result ~= nil then
        table.insert(mediais, {
            ["name"] = "没有找到相关信息",
            ["data"] = "",
            ["extra"] = "换个关键词试试"
        })
        return mediais
    end

    local _, _, itemListStr = string.find(content, '<div class="result%-list">(.-)<div class="back%-to%-top">')

    local itemStrList = string.split(itemListStr, '<div class="result">')

    if itemStrList ~= nil then
        for i = 2, #itemStrList do -- 第一条是无意义换行"\n\n            \n  \n\n  ",从第二条开始遍历
            local itemStr = itemStrList[i]

            if itemStr ~= "" then
                local _, _, tag, url, title = string.find(itemStr, [[<h3>
    %s-<span>(.-)</span>
    %s-&nbsp;<a href="(.-)".->(.-)</a>.-</h3>]])

                local _, _, cast = string.find(itemStr, '<span class="subject%-cast">(.-)</span>')
                local extra = ""
                if tag ~= nil then
                    extra = extra .. tag
                end
                if cast ~= nil then
                    extra = extra .. '\n' .. cast
                end
                local _, _, desc = string.find(itemStr, '<p>(.-)</p>')
                if desc ~= nil then
                    extra = extra .. '\n' .. desc
                end
                
                local url_query = parse_url_query(url)
                if url_query["url"] ~= nil then
                    url = url_query["url"]
                end
                local data = {
                    ["url"] = url,
                }
                local _, _, subject_id = string.find(url, "subject/(%d+)")
                if subject_id ~= nil then
                    data["subject_id"] = subject_id
                end
                local err, media_data_json = kiko.table2json(data)

                table.insert(mediais, {
                    ["name"] = string.trim(title),
                    ["data"] = media_data_json,
                    ["extra"] = extra,
                })
            end
        end
    end

    return mediais
end

function getEpInfo(count)
    local eps = {}
    for i = 1, count do
        local name = ""

        if i < 10 then
            name = "0" .. i
        else
            name = "" .. i
        end
        table.insert(eps, {
            ["name"] = name, --分集名称
            ["index"] = i,   --分集编号（索引）
            ["type"] = 1     --分集类型
        })
    end
    return eps
end

-- 获取动画的剧集信息。
-- anime： Anime
-- 返回： Array[EpInfo]

-- 在调用这个函数时，anime的信息可能不全，但至少会包含name，data这两个字段。
function getep(anime)
    kiko.log("function getep")
    local err, data = kiko.json2table(anime.data or "")
    if err == nil and type(data) == "table" then
        local count = tonumber(data.epcount)
        if count and count >= 0 and count % 1 == 0 then
            return getEpInfo(count)
        end
    end
    -- 兼容旧版保存的数据，以及宿主只传入 name/data 的情况。
    return detail(anime).eps
end

-- 获取动画详细信息
-- anime： AnimeLite
-- 返回：Anime
function detail(anime)
    kiko.log("function detail")
    local err, anime_data = kiko.json2table(anime.data or "")
    if err ~= nil or type(anime_data) ~= "table" then
        error("豆瓣条目数据无效，请重新搜索后再添加")
    end
    local subject_id = tostring(anime_data.subject_id or "")
    if not string.match(subject_id, "^%d+$") then
        subject_id = type(anime_data.url) == "string" and string.match(anime_data.url, "/subject/(%d+)")
    end
    if not subject_id then
        error("豆瓣条目地址无效，请重新搜索后再添加")
    end
    local url = "https://movie.douban.com/subject/" .. subject_id .. "/"
    local content, data = fetch_detail(url, subject_id)
    local name = type(data.name) == "string" and string.trim(html_entity_decode(data.name)) or ""
    if name == "" then
        error("豆瓣详情数据缺少标题，请稍后重试")
    end
    local airdate = type(data.datePublished) == "string" and string.match(data.datePublished, "^(%d%d%d%d%-%d%d%-%d%d)")
    if not airdate then
        error("豆瓣条目缺少有效的首播/上映日期，暂时无法添加到资料库")
    end
    if type(anime.name) == "string" and anime.name ~= "" and string.startswith(name, anime.name) then
        name = anime.name -- data.name 可能包含原名和翻译名
    end
    local anime_detail = {
        ["name"] = name,
        ["url"] = url,
        ["desc"] = html_entity_decode(data.description),
        ["airdate"] = airdate,
        ["coverurl"] = data.image,
    }

    local staffs = {}
    local function add_people(role, people)
        if type(people) ~= "table" then return end
        if people.name then people = {people} end
        local names = {}
        for _, person in ipairs(people) do
            if type(person) == "table" and type(person.name) == "string" then
                table.insert(names, html_entity_decode(person.name))
            end
        end
        if #names > 0 then table.insert(staffs, role .. ":" .. table.concat(names, ", ")) end
    end
    add_people("导演", data.director)
    add_people("编剧", data.author)
    add_people("主演", data.actor)

    -- 同时兼容原始 HTML 和浏览器序列化后的 <br> / <br/> / <br />。
    local fields = {}
    local staffListStr = string.match(content, [=[<div%s+[^>]-id%s*=%s*["']info["'][^>]*>(.-)</div>]=])
    if staffListStr then
        for role, names in string.gmatch(staffListStr, [=[<span%s+[^>]-class%s*=%s*["']pl["'][^>]*>([^<]-):%s*</span>%s*(.-)<br%s*/?>]=]) do
            role, names = plain_text(role), plain_text(names)
            fields[role] = names
            table.insert(staffs, role .. ":" .. names)
        end
    end
    if #staffs > 0 then anime_detail.staff = table.concat(staffs, ";") end

    -- 演职员区块是可选的，缺失时不能对 nil 调用 string.split。
    local celebrities = string.match(content, [=[<ul%s+[^>]-class%s*=%s*["'][^"']*celebrities%-list[^"']*["'][^>]*>(.-)</ul>]=])
    local crt = {}
    if celebrities then
        for celebrity in string.gmatch(celebrities, [=[<li%s+[^>]-class%s*=%s*["']celebrity["'][^>]*>(.-)</li>]=]) do
            local person_name = string.match(celebrity, [=[<span%s+[^>]-class%s*=%s*["']name["'][^>]*>(.-)</span>]=])
            if person_name then
                local c = { ["name"] = plain_text(person_name) }
                c.link = string.match(person_name, [=[href%s*=%s*["'](.-)["']]=])
                local role = string.match(celebrity, [=[<span%s+[^>]-class%s*=%s*["']role["'][^>]*>(.-)</span>]=])
                if role then c.actor = plain_text(role) end
                local image = string.match(celebrity, "background%-image:%s*url%((.-)%)")
                if image then
                    image = html_entity_decode(image)
                    c.imgurl = string.gsub(string.trim(image), [=[^["'](.-)["']$]=], "%1")
                end
                table.insert(crt, c)
            end
        end
    end
    anime_detail.crt = crt

    local count = fields["集数"] and tonumber(string.match(fields["集数"], "^%d+"))
    -- 电影视为一集，尚未公布集数的电视剧保留未知状态，避免误存为一集。
    if not count then count = data["@type"] == "TVSeries" and 0 or 1 end
    anime_detail.epcount = count
    anime_detail.eps = getEpInfo(count)

    local tags = {}
    local genres = data.genre
    if type(genres) == "string" then genres = {genres} end
    if type(genres) == "table" then
        for _, genre in ipairs(genres) do
            if type(genre) == "string" then table.insert(tags, html_entity_decode(genre)) end
        end
    end
    if #tags == 0 then
        for genre in string.gmatch(content, [=[<span%s+[^>]-property%s*=%s*["']v:genre["'][^>]*>(.-)</span>]=]) do
            table.insert(tags, plain_text(genre))
        end
    end
    anime_data.tags = tags
    anime_data.epcount = count
    anime_data.subject_id = subject_id
    anime_data.url = url
    local json_err, media_data_json = kiko.table2json(anime_data)
    if json_err ~= nil then error("豆瓣详情数据保存失败：" .. json_err) end
    anime_detail.data = media_data_json
    load_images(anime_detail)
    return anime_detail
end

-- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
-- anime： Anime
-- 返回： Array[string]，Tag列表
function gettags(anime)
    kiko.log("function gettags")
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil or type(anime_data) ~= "table" or type(anime_data.tags) ~= "table" then
        return {}
    end

    return anime_data.tags
end

-- 根据路径获取文件名
-- filterTitlle：是否过滤纯标题
-- 如果文件名是纯数字，使用上级文件夹名字
function getFileTitle(path, filterTitlle)
    local levels = string.split(path, '/')
    local _, _, fileName = string.find(levels[#levels], "(.+)%.(.-)")
    if filterTitlle and (tonumber(fileName) ~= nil or string.indexof(fileName, "番外") ~= -1) and string.indexof(levels[#levels - 1], ":") == -1 then
        fileName = levels[#levels - 1]
    end
    return fileName
end

-- 实现自动关联功能。提供此函数的脚本会被加入到播放列表的“关联”菜单中
-- path：文件路径
-- 返回：MatchResult
function match(path)
    kiko.log("function match")
    local fileName = getFileTitle(path, true)
    local animeLites = search(fileName)
    if #animeLites > 0 and animeLites[1]["data"] ~= "" then
        local anime = detail(animeLites[1])
        if anime ~= nil then
            local title = getFileTitle(path, false)
            local index
            if string.find(title, "S%d+E%d+") ~= nil then
                local _, _, index1 = string.find(title, "S%d+E(%d+)")
                index = tonumber(index1 or 1)
            else
                local _, _, index2 = string.find(title, "(%d+)")
                index = tonumber(index2 or 1)
            end

            if anime["epcount"] ~= nil and anime["epcount"] < index then
                index = 1
            end

            local type = 1
            if string.indexof(title, "番外") ~= -1 or string.indexof(title, "特别篇") ~= -1 then
                type = 2
            end

            return {
                ["success"] = true,    --是否成功关联
                ["anime"] = anime,     --关联的动画信息
                ["ep"] = {             --关联的剧集信息
                    ["name"] = title,  --分集名称
                    ["index"] = index, --分集编号（索引）
                    ["type"] = type    --分集类型
                }
            }
        end
    end
end

-- menus
-- Table，类型为 Array[LibraryMenu]
-- 如果资料库条目的scriptId和当前脚本的id相同，条目的右键菜单中会添加menus包含的菜单项，用户点击后会通过menuclick函数通知脚本

-- menuid： string，点击的菜单ID
-- anime： Anime， 条目信息

--function menuclick(menuid, anime)
--    kiko.log("menuclick")
--    -- kiko.log(kiko.table2json(menuid))
--    -- kiko.log(kiko.table2json(anime))
--end
