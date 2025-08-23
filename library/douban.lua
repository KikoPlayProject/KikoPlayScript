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
    ["version"] = "0.2",
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
    
    -- 首先替换命名实体
    local result = str
    for entity, char in pairs(entities) do
        result = string.gsub(result, entity, char)
    end
    
    -- 处理十进制实体，如&#39;
    result = string.gsub(result, "&#(%d+);", function(num)
        return string.char(tonumber(num))
    end)
    
    -- 处理十六进制实体，如&#x27;
    result = string.gsub(result, "&#x(%x+);", function(hex)
        return string.char(tonumber(hex, 16))
    end)
    
    return result
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

    if anime.url == "" then
        anime = detail(anime)
    end

    return anime.eps
end

-- 获取动画详细信息
-- anime： AnimeLite
-- 返回：Anime
function detail(anime)
    kiko.log("function detail")
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil or anime_data.url == nil or anime_data.url == "" then
        return nil
    end

    local url = ''
    if anime_data.url ~= nil then
        url = anime_data.url
    end
    if anime_data.subject_id ~= nil then
        url = "https://movie.douban.com/subject/" .. anime_data.subject_id .. "/"
    end

    local err, reply = kiko.httpget(url)

    if err ~= nil then error(err) end
    local content = reply["content"]

    local _, _, dataJsonStr = string.find(content, "<script type=\"application/ld%+json\">(.-)</script>")
    if dataJsonStr ~= nil then
        local err1, data = kiko.json2table(dataJsonStr)

        if err1 ~= nil then
            kiko.log("[ERROR] JSON 转换失败" .. dataJsonStr .. ".json2table: " .. err1)
            error(err1)
        end

        local name = data.name
        if string.startswith(name, anime.name) then
            name = anime.name  -- data.name 可能包含原名和翻译名
        end
        local anime_detail = {
            ["name"] = name,
            ["url"] = "https://movie.douban.com" .. data.url,
            ["desc"] = data.description,
            ["airdate"] = data.datePublished,
            ["coverurl"] = data.image,
        }

        local staffs = {}
        if data.director ~= nil and #data.director > 0 then
            local directors = {}
            for _, director in ipairs(data.director) do
                table.insert(directors, html_entity_decode(director.name))
            end
            table.insert(staffs, "导演:" .. table.concat(directors, ", "))
        end
        if data.author ~= nil and #data.author > 0 then
            local authors = {}
            for _, author in ipairs(data.author) do
                table.insert(authors, html_entity_decode(author.name))
            end
            table.insert(staffs, "编剧:" .. table.concat(authors, ", "))
        end
        if data.actor ~= nil and #data.actor > 0 then
            local actors = {}
            for _, actor in ipairs(data.actor) do
                table.insert(actors, html_entity_decode(actor.name))
            end
            table.insert(staffs, "主演:" .. table.concat(actors, ", "))
        end
        -- staff info
        local _, _, staffListStr = string.find(content, '<div id="info">(.-)</div>')
        if staffListStr ~= nil then
            local lpos = 1
            local npos = #staffListStr
            while lpos < npos do
                local _, epos, role, names = string.find(staffListStr, '<span class="pl">(.-):</span>(.-)<br/?>', lpos)
                if role ~= nil and names ~= nil then
                    role = string.trim(role)
                    names = string.gsub(names, "<.->", " ")
                    names = string.trim(names)
                    table.insert(staffs, role .. ":" .. html_entity_decode(names))
                    lpos = epos + 1
                else
                    break
                end
            end
        end
        if #staffs > 0 then
            anime_detail["staff"] = table.concat(staffs, ";")
        end

        -- 角色
        local _, _, celebritieListStr = string.find(content,
            "<ul class=\"celebrities%-list from%-subject __oneline\">(.-)</ul>")

        local celebritieStrList = string.split(celebritieListStr, '<li class="celebrity">')

        if (celebritieStrList ~= nil) then
            local crt = {}
            for i = 2, #celebritieStrList do -- 第一条是无意义换行"\n\n            \n  \n\n  ",从第二条开始遍历
                local celebritie = celebritieStrList[i]
                if celebritie ~= "" then
                    local _, _, actor = string.find(celebritie, '<span class="role" .->(.-)</span>')
                    local c = {}
                    if actor ~= nil then
                        c["actor"] = actor
                    end

                    local _, _, link, name = string.find(celebritie,
                        '<span class="name"><a href="(.-)" .->(.-)</a></span>')

                    if link ~= nil then
                        c["link"] = link
                    end

                    if name ~= nil then
                        c["name"] = name
                    end


                    local _, _, imgurl = string.find(celebritie,
                        '<div class="avatar" style="background%-image: url%((.-)%)">')
                    if imgurl ~= nil then
                        c["imgurl"] = imgurl
                    end

                    table.insert(crt, c)
                end
            end

            anime_detail["crt"] = crt
        end

        -- 集数
        local _, _, epCount = string.find(content, '<span class="pl">集数:</span> (%d-)<br/>')
        if epCount ~= nil then
            local count = tonumber(epCount)
            anime_detail["epcount"] = tonumber(count)

            if count > 0 then
                anime_detail["eps"] = getEpInfo(count)
            end
        else
            anime_detail["epcount"] = 1
            anime_detail["eps"] = getEpInfo(1)
        end

        -- 标签
        local _, _, tagsStr = string.find(content, '<span class="pl">类型:</span> (.-)<br/>')
        if tagsStr ~= nil then
            local parser = kiko.htmlparser(tagsStr)
            local tags = {}
            while not parser:atend() do
                if parser:curnode() == "span" and parser:start() and parser:curproperty("property") == "v:genre" then
                    table.insert(tags, parser:readcontent())
                end
                parser:readnext()
            end

            anime_data["tags"] = tags
        end

        local err, media_data_json = kiko.table2json(anime_data)
        anime_detail["data"] = media_data_json

        return anime_detail
    end

    return anime
end

-- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
-- anime： Anime
-- 返回： Array[string]，Tag列表
function gettags(anime)
    kiko.log("function gettags")
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil or anime_data.tags == nil or anime_data.tags == "" then
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
