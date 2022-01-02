-- DbScrape
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TMDb",
    ["id"] = "Kikyou.l.TMDb",
    ["desc"] = "The Movie Database 脚本，从 (api.)themoviedb.org 中获取匹配的影视元数据 Edited by: kafovin",
    ["version"] = "0.1"
}

-- 设置项
-- `key`为设置项的`key`，`value`是一个`table`。设置项值`value`的类型都是字符串。
-- 由于加载脚本后的特性，在脚本中，可以直接通过`settings["xxxx"]`获取设置项的值。

settings = {
    ["search_type"] = {
        ["title"] = "搜索结果类型",
        ["default"] = "multi",
        ["desc"] = "搜索条目的媒体类型。\n movie：电影； multi：电影/剧集； tv：剧集。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "movie,multi,tv"
    },
    ["match_type"] = {
        ["title"] = "匹配来源类型",
        ["default"] = "local_Emby_nfo",
        ["desc"] = "自动匹配本地媒体文件的条目来源。\n local：来自Emby刮削TMDb、并在本地媒体文件同目录存储元数据的 .nfo格式文件(内含.xml格式文本)；\nonline：来自在线搜索（现在还没有这个功能 (*￣▽￣）", -- 丢弃`person`的演员搜索结果
        ["choices"] = "local_Emby_nfo"
    },
    ["api_key"] = {
        ["title"] = "TMDb API 密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "在`themoviedb.org`注册账号，并把个人设置中的API申请到的\n`API 密钥` (api key) 填入此项。（一般为一串字母数字）"
    },
    ["metadata_lang"] = {
        ["title"] = "元数据语言",
        ["default"] = "zh-CN",
        ["desc"] = "搜索什么语言的资料作元数据。\n en-US：英语(美国)；ja-JP：日语(日本)；zh-CN：简体中文(中国)；zh-HK：繁体中文(香港特区,中国)；zh-TW：繁体中文(台湾省，中国)。",
        ["choices"] = "en-US,ja-JP,zh-CN,zh-HK,zh-TW"
    },
    ["metadata_info_origin_title"] = {
        ["title"] = "元数据使用原语言标题",
        ["default"] = "0",
        ["desc"] = "元数据的标题是否使用原语言。\n0-不使用；1-使用。",
        ["choices"] = "0,1"
    }
}

Metadata_search_page = 1 -- 元数据总共搜索页数。 默认： 1 页
Metadata_search_adult = false -- Choose whether to inlcude adult (pornography) content in the results when searching metadata. Default: false
Metadata_info_origin_title = true -- 是否使用源语言标题，在运行函数内更新值

-- 说明
-- 三目运算符 ((condition) and {trueCDo} or {falseCDo})[1] === (condition)?(trueCDo):(falseCDo)

-- (\{)(\[)("id"\]=)([0-9]{1,}?)(,\["name")(\]="[\S ^"]{1,}")(\})(,)
-- \2\4\6
Media_genre = {
    [28] = "动作",
    [12] = "冒险",
    [16] = "动画",
    [35] = "喜剧",
    [80] = "犯罪",
    [99] = "纪录",
    [18] = "剧情",
    [10751] = "家庭",
    [14] = "奇幻",
    [36] = "历史",
    [27] = "恐怖",
    [10402] = "音乐",
    [9648] = "悬疑",
    [10749] = "爱情",
    [878] = "科幻",
    [10770] = "电视电影",
    [53] = "惊悚",
    [10752] = "战争",
    [37] = "西部",
    [10759] = "动作冒险",
    [10762] = "儿童",
    [10763] = "新闻",
    [10764] = "真人秀",
    [10765] = "Sci-Fi & Fantasy",
    [10766] = "肥皂剧",
    [10767] = "脱口秀",
    [10768] = "War & Politics"
}
--[[
Anime_data = {
    ["media_title"] = unescape(mediai["media_title"]) or unescape(mediai["media_name"]),		-- 标题
    ["original_title"] = unescape(mediai["original_title"]) or unescape(mediai["original_name"]),-- 原始语言标题
    ["media_id"] = tostring(mediai["id"]),			-- 媒体的 tmdb id
    ["media_imdbid"],			-- 媒体的 imdb id
    ["media_type"] = mediai["media_type"],			-- 媒体类型 movie tv person
    ["genre_ids"] = mediai["genre_ids"],			-- 流派类型的编号 table/Array
    ["genre_names"],			-- 流派类型 table/Array
    ["release_date"] = mediai["release_date"] or mediai["air_date"] or mediai["first_air_date"], -- 首映/本季首播/发行日期
    ["original_language"] = mediai["original_language"], -- 原始语言
    ["origin_country"] = mediai["origin_country"],	-- 原始首映/首播国家地区
    ["origin_company"],	-- 原始首映/首播国家地区
    ["overview"] = mediai["overview"],				-- 剧情梗概
    ["vote_average"] = mediai["vote_average"],		-- 平均tmdb评分
    -- 原图  "https://image.tmdb.org/t/p/original"..data["image_path"]
    -- 小图  "https://image.tmdb.org/t/p/w500"..data["image_path"]
    ["person_staff"],			-- "job1:name1;job2;name2;..."
    ["person_character"],		-- { ["name"]=string,   --人物名称 ["actor"]=string,  --演员名称 ["link"]=string,   --人物资料页URL  ["imgurl"]=string --人物图片URL }
    ["rate_mpaa"],				-- MPAA分级
    ["file_path"],				-- 文件目录

-- ["season_episode"],			-- 某季的集数 {{season_number,episode_count},{0,10}，{1,16}，{2,11}}
    ["season_count"],			-- 剧集的 总季数 - 含 S00/Specials/特别篇/S05/Season 5/第 5 季
    ["season_number"],			-- 本季的 季序数 /第几季 - 0-specials
    ["season_title"],			-- 本季的 季名称 - "季 2" "Season 2" "Specials"
    ["episode_count"],			-- 本季的 总集数
    ["tv_first_air_date"] = ["first_air_date"],		-- 剧集首播/发行日期
    ["poster_path"] = "https://image.tmdb.org/t/p/original"...mediai["poster_path"] or tvSeasonsIx["poster_path"],		-- 海报图片 电影/剧集某季
    ["tv_poster_path"] = "https://image.tmdb.org/t/p/original"..mediai["poster_path"],  -- 海报图片 剧集
    ["backdrop_path"] = "https://image.tmdb.org/t/p/original"..mediai["backdrop_path"],	-- 背景图片 电影/剧集
}]] --

---------------------
-- 资料脚本部分
-- copy (as template) from & thanks to "..\\library\\bangumi.lua", "..\\danmu\\bilibili.lua"
--

function search(keyword)
    -- keyword： string，搜索关键字
    -- 返回：Array[AnimeLite]
    -- 完成搜索功能，可选
    -- 需要注意的是，除了下面定义的AnimeLite结构，还可以增加一项eps，类型为Array[EpInfo]，包含动画的剧集列表。
    -- httpget( query, header ) -> json:reply
    kiko.log("[INFO]  Searching <" .. keyword .. ">")
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    local query = {
        ["api_key"] = settings["api_key"],
        ["language"] = settings["metadata_lang"],
        ["query"] = keyword,
        ["page"] = Metadata_search_page,
        ["include_adult"] = Metadata_search_adult
    }
    local header = {
        ["Accept"] = "application/json"
    }
    if settings["api_key"] == "<<API_Key_Here>>" then
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/search/" .. settings["search_type"]),
        query, header)

    if err ~= nil then
        kiko.log("[ERROR] httpget ERROR")
        error(err)
    end
    -- json:reply -> Table:obj
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    -- Table:obj["results"] -> Array:mediai
    local mediais = {}
    for _, mediai in pairs(obj['results']) do
        if (mediai["media_type"] ~= 'tv' and mediai["media_type"] ~= 'movie' and settings["search_type"] == "multi") then
            goto continue_search_a
        end
        -- title/name
        local mediaName
        if (Metadata_info_origin_title) then
            mediaName = unescape(mediai["original_title"] or mediai["original_name"])
        else
            mediaName = unescape(mediai["title"] or mediai["name"])
        end
        -- local extra = {}
        local data = {}
        if settings["search_type"] == "multi" then
            data["media_type"] = mediai["media_type"] -- 媒体类型 movie tv person
        elseif settings["search_type"] == "movie" then
            data["media_type"] = "movie"
        elseif settings["search_type"] == "tv" then
            data["media_type"] = "tv"
        end
        data["media_title"] = unescape(mediai["title"]) or unescape(mediai["name"]) -- 标题
        data["original_title"] = unescape(mediai["original_title"]) or unescape(mediai["original_name"]) -- 原始语言标题
        data["media_id"] = string.format("%d", mediai["id"]) -- 媒体的 tmdb id
        data["release_date"] = mediai["release_date"] or mediai["first_air_date"] -- 首映/首播/发行日期
        data["original_language"] = mediai["original_language"] -- 原始语言
        data["origin_country"] = mediai["origin_country"] -- 原始首映/首播国家地区
        data["overview"] = string.gsub(string.gsub(mediai["overview"], "\n\n", "\n"), "\r\n\r\n", "\r\n") -- 剧情梗概
        data["vote_average"] = mediai["vote_average"] -- 平均tmdb评分
        -- genre_ids -> genre_names
        data["genre_names"] = {} -- 流派类型 table/Array
        for key, value in pairs(mediai["genre_ids"]) do -- key-index value-id
            local genreIdIn = false -- genre_ids.value-id in Media_genre
            for k, v in pairs(Media_genre) do
                if k == value then
                    genreIdIn = true
                end
            end
            if genreIdIn then
                data["genre_names"][key] = Media_genre[value]
            end
        end
        -- 原图  "https://image.tmdb.org/t/p/original"..data["image_path"]
        -- 小图  "https://image.tmdb.org/t/p/w500"..data["image_path"]
        if (mediai["poster_path"] ~= nil and mediai["poster_path"] ~= "") then
            data["poster_path"] = "https://image.tmdb.org/t/p/original" .. mediai["poster_path"]
        else
            data["poster_path"] = ""
        end -- 海报图片
        if (mediai["backdrop_path"] ~= nil and mediai["backdrop_path"] ~= "") then
            data["backdrop_path"] = "https://image.tmdb.org/t/p/original" .. mediai["backdrop_path"]
        else
            data["backdrop_path"] = ""
        end -- 背景图片

        -- season_number, episode_count,
        if data["media_type"] == "movie" then
            data["season_number"] = 1
            data["episode_count"] = 1
            data["season_count"] = 1
            data["season_title"] = data["original_title"]
            local media_data_json
            err, media_data_json = kiko.table2json(table.deepCopy(data))
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, tableToStringLines(data)));

            -- get "Movie Name (YEAR)"
            if data["release_date"] ~= nil and data["release_date"] ~= "" then
                mediaName = mediaName .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
            end
            -- 插入搜索条目table到列表 mediais
            table.insert(mediais, {
                ["name"] = mediaName,
                ["data"] = media_data_json,
                ["extra"] = "类型：" .. data["media_type"] .. "  |  首映：" ..
                    ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) .. "  |  语言：" ..
                    (data["original_language"] or "") .. "  " .. arrayToString(data["origin_country"]) ..
                    "\r\n简介：" .. (data["overview"] or ""),
                -- ["extra"] = "  " .. data["media_type"] .. "  |  " ..
                --     ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) .. "  |  " ..
                --     (data["original_language"] or "") .. "-" .. arrayToString(data["origin_country"]) ..
                --     "\r\n" .. (data["overview"] or "")
                -- ["eps"]=epList
                ["scriptId"] = "Kikyou.l.TMDb"
            })
        elseif data["media_type"] == "tv" then
            --
            local queryTv = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            if settings["api_key"] == "<<API_Key_Here>>" then
                error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
            end
            local err, replyTv = kiko.httpget(string.format(
                "http://api.themoviedb.org/3/" .. data["media_type"] .. "/" .. data["media_id"]), queryTv, header)

            if err ~= nil then
                kiko.log("[ERROR] httpget ERROR")
                error(err)
            end
            -- json:reply -> Table:obj
            local contentTv = replyTv["content"]
            local err, objTv = kiko.json2table(contentTv)
            if err ~= nil then
                error(err)
            end

            -- 去除剧情介绍多余的空行
            data["season_count"] = #(objTv["seasons"])
            if objTv["tagline"] ~= "" then
                data["overview"] =
                    string.gsub(string.gsub(objTv["tagline"], "\n\n", "\n"), "\r\n\r\n", "\r\n") .. "\n" ..
                        data["overview"]
            end

            -- Table:obj -> Array:mediai
            -- local tvSeasonsIxs = {}
            data["tv_first_air_date"] = data["release_date"]
            data["tv_poster_path"] = data["poster_path"]
            local data_overview = data["overview"]
            for _, tvSeasonsIx in pairs(objTv['seasons']) do
                local mediaNameSeason = mediaName
                data["release_date"] = tvSeasonsIx["air_date"]
                data["season_title"] = tvSeasonsIx["name"]
                if tvSeasonsIx["overview"] ~= "" then
                    data["overview"] = string.gsub(string.gsub(tvSeasonsIx["overview"], "\n\n", "\n"), "\r\n\r\n",
                        "\r\n") .. "\n" .. data_overview
                else
                    data["overview"] = data_overview
                end
                if (tvSeasonsIx["poster_path"] ~= nil and tvSeasonsIx["poster_path"] ~= "") then
                    data["poster_path"] = "https://image.tmdb.org/t/p/original" .. tvSeasonsIx["poster_path"]
                elseif (data["tv_poster_path"] ~= nil and data["tv_poster_path"] ~= "") then
                    data["poster_path"] = data["tv_poster_path"]
                else
                    data["poster_path"] = ""
                end
                data["origin_country"] = {}
                if tvSeasonsIx["production_countries"] ~= nil then
                    for _, value in pairs(tvSeasonsIx["production_countries"]) do
                        data["origin_country"].insert(value["name"])
                        data["origin_country"].insert(value["iso_3166_1"])
                    end
                end

                data["season_number"] = math.floor(tvSeasonsIx["season_number"])
                data["episode_count"] = math.floor(tvSeasonsIx["episode_count"])

                local seasonNameNormal -- 判断是否为普通的 季名称 S00/Specials/特别篇/S05/Season 5/第 5 季
                seasonNameNormal = (data["season_title"] == string.format("Season %d", data["season_number"])) or
                                       (data["season_title"] == "Specials")
                seasonNameNormal = (data["season_title"] == string.format("第 %d 季", data["season_number"])) or
                                       (data["season_title"] == "特别篇") or seasonNameNormal
                seasonNameNormal = (data["season_title"] == string.format("第%d季", data["season_number"])) or
                                       (data["season_title"] == (string.format('S%02d', data["season_number"]))) or
                                       seasonNameNormal
                -- TODO: 格式化标题
                if seasonNameNormal then
                    if not (Metadata_info_origin_title) then
                        if tonumber(data["season_number"]) ~= 0 then
                            mediaNameSeason = mediaNameSeason .. string.format(' 第%d季', data["season_number"])
                        else
                            mediaNameSeason = mediaNameSeason .. ' 特别篇'
                        end
                    else
                        if tonumber(data["season_number"]) ~= 0 then
                            mediaNameSeason = mediaNameSeason .. string.format(' S%02d', data["season_number"])
                        else
                            mediaNameSeason = mediaNameSeason .. ' Specials'
                        end
                    end
                else
                    mediaNameSeason = mediaNameSeason .. " " .. data["season_title"]
                end
                if data["release_date"] ~= nil and data["release_date"] ~= "" then
                    mediaNameSeason = mediaNameSeason .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
                end

                local media_data_json
                err, media_data_json = kiko.table2json(table.deepCopy(data))
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, tableToStringLines(data)));
                local seasonTextNormal = ""
                if data["season_number"] ~= 0 then
                    seasonTextNormal = string.format("第%02d季", data["season_number"] or "")
                else
                    seasonTextNormal = "特别篇"
                end

                -- 插入搜索条目table到列表 mediais
                table.insert(mediais, {
                    ["name"] = mediaNameSeason,
                    ["data"] = media_data_json,
                    ["extra"] = "类型：" .. data["media_type"] .. "          |  首播：" ..
                        ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) .. "  |  语言：" ..
                        (data["original_language"] or "") .. "  " .. arrayToString(data["origin_country"]) .. "  |  " ..
                        seasonTextNormal .. string.format(" (共%2d季) ", data["season_count"] or "") ..
                        "  |  集数：" .. string.format("%d", data["episode_count"] or "") .. "\r\n简介：" ..
                        (data["overview"] or ""),
                    -- ["extra"] = "  " .. data["media_type"] .. " | " ..
                    --     (data["release_date"] or tvSeasonsIx["air_date"] or data["first_air_date"] or "") .. " | " ..
                    --     (data["original_language"] or "") .. "-" .. tableToString(data["origin_country"]) ..
                    --     "\r\n" .. (data["overview"] or "")
                    -- ["eps"]=epList
                    ["scriptId"] = "Kikyou.l.TMDb"
                })
            end
        end

        ::continue_search_a::
    end
    kiko.log("[INFO]  Finished searching <" .. keyword .. "> with " .. #(obj['results']) .. " results")
    -- kiko.log("[INFO]  Reults:\t" .. tableToStringLines(mediais))
    return mediais
end
-- ]]--

function getep(anime)
    -- anime： Anime
    -- 返回： Array[EpInfo]
    -- 获取动画的剧集信息。在调用这个函数时，anime的信息可能不全，但至少会包含name，data这两个字段。
    -- epinfo = {
    -- 	["name"]=string,   --分集名称
    -- 	["index"]=number,  --分集编号（索引）
    -- 	["type"]=number    --分集类型
    -- 	--分集类型包括 EP, SP, OP, ED, Trailer, MAD, Other 七种，分别用1-7表示， 默认情况下为1（即EP，本篇）
    -- }

    -- local tmdbId = anime["data"]
    -- local header = {
    --     ["Accept"]="application/json"
    -- }
    -- local err, reply = kiko.httpget(string.format("https://api.bgm.tv/subject/%s/ep", bgmId), {}, header)
    -- if err ~= nil then error(err) end
    -- local content = reply["content"]
    -- local err, obj = kiko.json2table(content)
    -- if err ~= nil then error(err) end
    -- --

    kiko.log("[INFO]  Getting episodes of <" .. anime["name"] .. ">")
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    anime_data["season_number"] = math.floor(tonumber(anime_data["season_number"]))

    local eps = {}
    local epName, epIndex, epType = nil, nil, nil
    -- kiko.log(string.format("[INFO]  getting episode info ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- movie 假设为第一集，名称为标题
    if (anime_data["media_type"] == "movie") then
        -- 与标题语言要求相反的集标题
        -- if Metadata_info_origin_title==true then
        --     epName = anime_data["media_title"]
        -- else epName = anime_data["original_title"]
        -- end
        epName = anime_data["media_title"]
        epIndex = 1
        epType = 1
        table.insert(eps, {
            ["name"] = epName,
            ["index"] = epIndex,
            ["type"] = epType
        })
        -- kiko.log(string.format("[INFO]  Movie [%s] on Episode %d :[%s] %s", anime_data["original_title"], epIndex,epType, epName))
        -- tv
    elseif (anime_data["media_type"] == "tv") then

        local query = {
            ["api_key"] = settings["api_key"],
            ["language"] = settings["metadata_lang"]
        }
        local header = {
            ["Accept"] = "application/json"
        }
        if settings["api_key"] == "<<API_Key_Here>>" then
            error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
        end
        local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                          "/season/" .. (anime_data["season_number"])), query, header)

        if err ~= nil then
            kiko.log("[ERROR] httpget ERROR")
            error(err)
        end
        -- json:reply -> Table:obj
        local content = reply["content"]
        local err, objS = kiko.json2table(content)
        if err ~= nil then
            error(err)
        end

        local normalEpTitle = false --- TODO: 是否 没有特殊名称的标题，未测试
        if (objS["episodes"] == nil or #(objS["episodes"]) == 0) then
            return eps
        end
        local seasonEpsI = objS["episodes"][1]
        if seasonEpsI ~= nil then
            seasonEpsI["episode_number"] = math.floor(tonumber(seasonEpsI["episode_number"]))
        end
        if (seasonEpsI["name"] == "第 " .. seasonEpsI["episode_number"] .. " 集" or seasonEpsI["name"] == "第" ..
            seasonEpsI["episode_number"] .. "話" or seasonEpsI["name"] == "Episode " .. seasonEpsI["episode_number"]) then
            normalEpTitle = true
        end
        if (normalEpTitle and string.sub(query["language"], 1, 2) ~= anime_data["original_language"]) then
            -- and (query["language"] == "zh-CN" or query["language"] == "zh-HK" or query["language"] == "zh-TW" or query["language"] == "zh")
            query["language"] = anime_data["original_language"]
            local err, replyO = kiko.httpget(string.format(
                "http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] .. "/season/" .. anime_data["season_number"]),
                query, header)
            if err ~= nil then
                kiko.log("[ERROR] httpget ERROR")
                error(err)
            end
            -- json:reply -> Table:obj
            local contentO = replyO["content"]
            local err, objSO = kiko.json2table(contentO)
            if err ~= nil then
                error(err)
            end
            local seasonEpsIO = objSO['episodes'][1]
            normalEpTitle = false
            seasonEpsIO["episode_number"] = math.floor(tonumber(seasonEpsIO["episode_number"]))
            if (seasonEpsIO["name"] == "第 " .. seasonEpsIO["episode_number"] .. " 集" or seasonEpsIO["name"] == "第" ..
                seasonEpsIO["episode_number"] .. "話" or seasonEpsIO["name"] == "Episode " ..
                seasonEpsIO["episode_number"]) then
                normalEpTitle = true
            end
            if (normalEpTitle ~= true) then
                objS = objSO
            end
        end
        for _, seasonEpsIx in pairs(objS['episodes']) do

            epName = seasonEpsIx["name"]
            epIndex = math.floor(tonumber(seasonEpsIx["episode_number"]))
            -- seasonEpsIx["air_date"]
            -- seasonEpsIx["overview"]
            -- seasonEpsIx["vote_average"]
            -- seasonEpsIx["crew"] --array
            -- seasonEpsIx["guest_stars"] --array

            if anime_data["season_number"] == 0 then
                epType = 2
            else
                epType = 1
            end

            -- 插入搜索条目table到列表 eps
            table.insert(eps, {
                ["name"] = epName,
                ["index"] = epIndex,
                ["type"] = epType
            })
            -- kiko.log(string.format("[INFO]  TV [%s] on Episode %d :[%s] %s", anime_data["original_title"] ..string.format("S%02dE%02d", anime_data["season_number"], i), epIndex, epType, epName))
        end

        --[[
        -- 默认集数命名 [S01E02] - Season 1 Episode 2
        for i = 1, math.floor(anime_data["episode_count"]), 1 do
            epName, epIndex, epType = nil, nil, nil
            epName = string.format("S%02dE%02d", anime_data["season_number"], i)
            epIndex = i
            if anime_data["season_number"] == 0 then
                epType = 2
            else
                epType = 1
            end
            table.insert(eps, {
                ["name"] = epName,
                ["index"] = epIndex,
                ["type"] = epType
            })
            -- kiko.log(string.format("[INFO]  TV [%s] on Episode %d :[%s] %s", anime_data["original_title"] ..string.format("S%02dE%02d", anime_data["season_number"], i), epIndex, epType, epName))
        end
        ]] --
    end
    -- for _, ep in pairs(obj['eps']) do
    --     local epType = ep["type"] + 1  -- ep["type"]: 0~6
    --     local epIndex = ep["sort"]
    --     local epName = unescape(ep["name_cn"] or ep["name"])
    --     table.insert(eps, {
    --         ["name"]=epName,
    --         ["index"]=epIndex,
    --         ["type"]=epType
    --     })
    -- end
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. " >")
    end
    return eps
end
-- ]] --

function detail(anime)
    -- anime： AnimeLite
    -- 返回：Anime
    -- 获取动画详细信息
    -- {
    --     ["name"]=string,     --动画名称，注意KikoPlay通过name标识动画，name相同即为同一部
    -- 动画
    --     ["data"]=string,     --脚本可以自行存放一些数据
    --     ["extra"]=string,    --附加显示数据，这个信息不会由KikoPlay传递到脚本，仅用户向用
    -- 户展示
    --     ["scriptId"]=string  --脚本ID，这里可以指定其他脚本的ID，后续的获取详细信息等任务将
    -- 会由指定的其他脚本完成。为空则默认为当前脚本
    -- }
    kiko.log("[INFO]  Getting detail of <" .. anime["name"] .. ">")
    -- tableToStringPrint(anime) -- kiko.log()
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    -- tableToStringPrint(anime_data) -- kiko.log("")

    local titleTmp = "" -- 形如 "media_title (original_title)"
    if anime_data["media_title"] then
        titleTmp = titleTmp .. "\n" .. anime_data["media_title"]
        if anime_data["original_title"] then
            titleTmp = titleTmp .. " (" .. anime_data["original_title"] .. ")"
        end
    else
        if anime_data["original_title"] then
            titleTmp = titleTmp .. "\n" .. anime_data["original_title"]
        end
    end
    -- 从AmimeLite:anime["data"]读取详细信息
    local animePlus = {
        ["name"] = anime["name"], -- (()and{}or{})[1]
        ["data"] = anime["data"],
        ["url"] = ((anime_data["media_type"]) and
            {"https://www.themoviedb.org/" .. anime_data["media_type"] .. "/" .. anime_data["media_id"]} or {""})[1], -- 条目页面URL
        ["desc"] = anime_data["overview"] .. titleTmp, -- 描述
        ["airdate"] = ((anime_data["release_date"]) and {anime_data["release_date"]} or
            {anime_data["tv_first_air_date"]})[1] or "", -- 发行日期，格式为yyyy-mm-dd 
        ["epcount"] = anime_data["episode_count"], -- 分集数
        ["coverurl"] = anime_data["poster_path"], -- 封面图URL
        ["staff"] = anime_data["person_staff"], -- staff - "job1:staff1;job2:staff2;..."
        ["crt"] = anime_data["person_character"], -- 人物
        ["scriptId"] = "Kikyou.l.TMDb"
    }
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. ">")
    end
    kiko.log("[INFO]  Anime = "..tableToStringLines(animePlus))
    return animePlus
end

function gettags(anime)
    -- anime： Anime
    -- 返回： Array[string]，Tag列表
    -- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
    kiko.log("[INFO]  Starting getting tags of" .. anime["name"])
    -- tableToStringPrint(anime) -- kiko.log()
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    -- tableToStringPrint(anime_data) -- kiko.log("")
    local mtag = {} -- 标签数组
    local genre_name_tmp -- 暂存字符串
    for _, value in pairs(anime_data["genre_names"]) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, genre_name_tmp)
        end
    end
    if anime_data["media_type"] == "movie" then
        table.insert(mtag, "电影")

    elseif anime_data["media_type"] == "tv" then
        table.insert(mtag, "剧集")
    end
    if anime_data["origin_company"] ~= nil then
        for _, value in pairs(anime_data["origin_company"]) do
            if (value ~= nil) then
                genre_name_tmp = value .. ""
                table.insert(mtag, genre_name_tmp)
            end
        end

    end
    if anime_data["origin_country"] ~= nil then
        for _, value in pairs(anime_data["origin_country"]) do
            if (value ~= nil) then
                genre_name_tmp = value .. ""
                table.insert(mtag, genre_name_tmp)
            end
        end

    end
    if anime_data["original_language"] ~= nil then
        table.insert(mtag, anime_data["original_language"])

    end
    kiko.log("[INFO]  Finished getting " .. #mtag .. " tags of < " .. anime["name"] .. ">")
    return mtag
end

-- path：视频文件全路径 -  path/to/video.ext
-- 返回：MatchResult
-- 实现自动关联功能。提供此函数的脚本会被加入到播放列表的“关联”菜单中)
-- 读取 Emby 在媒体文件夹存储的 媒体信息文件 -  path/to/video.nfo
--     与媒体文件同目录同名的文本文档，文本格式为 .xml
function match(path)
    -- local err, fileHash = kiko.hashdata(path, true, 16*1024*1024)
    kiko.log('[INFO]  Matching path - <' .. path .. '> - ' .. #path)
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    -- string.gmatch(path,"\\[%S ^\\]+",-1)
    -- path: tv\season\video.ext  lff\lf\l  Emby 存储剧集的目录 -  tv/tvshow.nfo  tv/season/season.nfo
    -- path: movie\video.ext	  l\        Emby 存储电影的目录 -  movie/video.nfo
    local path_file_sign, _ = stringfindre(path, ".", -1) -- 路径索引 文件拓展名前'.' path/to/video[.]ext
    local path_folder_sign, _ = stringfindre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
    -- kiko.log('TEST  - '..path_file_sign)
    -- kiko.log('TEST  - '..path_folder_sign)
    local path_file_name = string.sub(path, path_folder_sign + 1, path_file_sign - 1) -- 媒体文件名称 不含拓展名 - video
    local path_folder_l = string.sub(path, 1, path_folder_sign) -- 父文件夹路径 含结尾'/' -  tv/season/   movie/
    path_folder_sign, _ = stringfindre(path, "/", path_folder_sign - 1) -- 路径索引 父父文件夹尾'/' path[/]to/video.ext
    local path_folder_lf = string.sub(path, 1, path_folder_sign) -- 父父文件夹路径 含结尾'/' -  tv/

    --
    local mediainfo, epinfo = {}, {}
    if settings["match_type"] ~= "local_Emby_nfo" then
        -- TODO: 添加在线搜索 匹配本地文件 的功能
        return {
            ["success"] = false,
            ["anime"] = {},
            ["ep"] = {}
        }
    end
    local xml_file_path = path_folder_l .. path_file_name .. '.nfo' -- 媒体信息文档全路径 path/to/video.nfo 文本为 .xml 格式
    local xml_v_nfo = readxmlfile(xml_file_path) -- 获取媒体信息文档
    if xml_v_nfo == nil then
        error("Fail to read xml content from <" .. xml_file_path .. ' >.')
        -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
        return {
            ["success"] = false
        };
    end
    --[[
	mediainfo = {
		["name"]=string,          --动画名称
		["data"]=string,          --脚本可以自行存放一些数据
		["url"]=string,           --条目页面URL
		["desc"]=string,          --描述
		["airdate"]=string,       --放送日期，格式为yyyy-mm-dd
		["epcount"]=number,       --分集数
		["coverurl"]=string,      --封面图URL
		["staff"]=string,         --staff
		["crt"]=Array[Character], --人物
		["scriptId"]=string       --脚本ID
	}
	epinfo = {
		["name"]=string,   --分集名称
		["index"]=number,  --分集编号（索引）
		["type"]=number    --分集类型
		--分集类型包括 EP, SP, OP, ED, Trailer, MAD, Other 七种，分别用1-7表示， 默认情况下为1（即EP，本篇）
	}
	Character = {
    ["name"]=string,   --人物名称
    ["actor"]=string,  --演员名称
    ["link"]=string,   --人物资料页URL
    ["imgurl"]=string  --人物图片URL
	}
	]] --
    -- xml_v_nfo
    -- local mname, mdata, murl, mdesc, mairdate, mepcount, mcoverurl, mstaff, mcrt = nil, {}, nil, nil, nil, nil, nil,
    local mname, mdata, mepcount = nil, {}, nil
    local ename, eindex, etype, eseason = nil, nil, nil, nil
    -- tstitle = season title
    local tstitle = nil
    local myear = nil
    local tmpElem -- 临时存 xml_v_nfo:elemtext()
    mdata["file_path"] = path
    while not xml_v_nfo:atend() do
        if xml_v_nfo:startelem() then
            -- movie
            if xml_v_nfo:name() == "movie" then
                mdata["media_type"] = "movie"
                mdata["poster_path"] = "file:///"..path_folder_l .. "poster.jpg"
                mdata["backdrop_path"] = "file:///"..path_folder_l .. "fanart.jpg"
                kiko.log('[INFO]  Reading movie nfo')
                xml_v_nfo:readnext()
                while not xml_v_nfo:atend() do
                    if xml_v_nfo:startelem() then
                        -- read metadata
                        if xml_v_nfo:name() ~= "actor" then
                            tmpElem = xml_v_nfo:elemtext() .. ""
                        else
                            tmpElem = ""
                        end
                        if xml_v_nfo:name() == "title" then
                            mdata["media_title"] = tmpElem
                            -- if not (Metadata_info_origin_title) then
                            --     mname = mdata["media_title"]
                            -- end
                        elseif xml_v_nfo:name() == "originaltitle" then
                            mdata["original_title"] = tmpElem
                            -- if Metadata_info_origin_title then
                            --     mname = mdata["original_title"]
                            -- end
                        elseif xml_v_nfo:name() == "plot" then
                            -- mdesc = tmpElem
                            mdata["overview"] = tmpElem
                        elseif xml_v_nfo:name() == "director" then
                            if mdata["person_staff"] == nil then
                                mdata["person_staff"] = ''
                            end
                            mdata["person_staff"] = mdata["person_staff"] .. 'Director:' .. tmpElem .. ';'
                        elseif xml_v_nfo:name() == "rating" then
                            mdata["vote_average"] = tmpElem
                        elseif xml_v_nfo:name() == "year" then
                            if tmpElem ~= nil and tmpElem ~= "" then
                                myear = tmpElem
                            elseif mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                                myear = string.sub(mdata["release_date"], 1, 4)
                            end
                            -- elseif xml_v_nfo:name()=="content" then
                            -- mcoverurl = tmpElem
                            -- elseif xml_v_nfo:name() == "sorttitle" then
                            --     mdata["sort_title"] = tmpElem
                        elseif xml_v_nfo:name() == "mpaa" then
                            mdata["rate_mpaa"] = tmpElem
                        elseif xml_v_nfo:name() == "tmdbid" then
                            mdata["media_id"] = string.format("%d", tmpElem)
                            -- if mdata["media_id"] ~= nil then
                            --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                            -- end
                        elseif xml_v_nfo:name() == "imdbid" then
                            mdata["media_imdbid"] = tmpElem
                        elseif xml_v_nfo:name() == "premiered" then -- 首映
                            local elemtext_tmp = tmpElem
                            if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                            end
                        elseif xml_v_nfo:name() == "releasedate" then -- 发行
                            local elemtext_tmp = tmpElem
                            if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                            end
                        elseif xml_v_nfo:name() == "country" then
                            if mdata["origin_country"] == nil then
                                mdata["origin_country"] = {}
                            end
                            table.insert(mdata["origin_country"], tmpElem)
                        elseif xml_v_nfo:name() == "genre" then
                            if mdata["genre_names"] == nil then
                                mdata["genre_names"] = {}
                            end
                            table.insert(mdata["genre_names"], tmpElem)
                        elseif xml_v_nfo:name() == "studio" then
                            if mdata["origin_company"] == nil then
                                mdata["origin_company"] = {}
                            end
                            table.insert(mdata["origin_company"], tmpElem)
                        elseif xml_v_nfo:name() == "actor" then
                            if mdata["person_character"] == nil then
                                mdata["person_character"] = {}
                            end
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                            xml_v_nfo:readnext()
                            -- read actors in .nfo
                            while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                if xml_v_nfo:startelem() then
                                    tmpElem = xml_v_nfo:elemtext() .. ""
                                    if xml_v_nfo:name() == "role" then
                                        cname = tmpElem
                                    elseif xml_v_nfo:name() == "name" then
                                        cactor = tmpElem
                                    elseif xml_v_nfo:name() == "tmdbid" then
                                        clink = "https://www.themoviedb.org/person/" .. tmpElem
                                        -- elseif xml_v_nfo:name()=="content" then
                                        --     cimgurl = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                end
                                xml_v_nfo:readnext()
                            end
                            --[[
							xml_v_nfo_crt=kiko.xmlreader(tmpElem)
							kiko.log('TEST  - Actor Tag: ')
							cname, cactor, clink, cimgurl=nil, nil, nil, nil
							while not xml_v_nfo_crt:atend() do
								if xml_v_nfo_crt:startelem() then
									if xml_v_nfo_crt:name()=="role" then
										cname = xml_v_nfo_crt:elemtext()
									elseif xml_v_nfo_crt:name()=="name" then
										cactor = xml_v_nfo_crt:elemtext()
									-- elseif xml_v_nfo_crt:name()=="content" then
										-- clink = xml_v_nfo_crt:elemtext()
									-- elseif xml_v_nfo_crt:name()=="content" then
										-- cimgurl = xml_v_nfo_crt:elemtext()
									end
									kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.')
								end
								xml_v_nfo:readnext()
							end
							]] --
                            table.insert(mdata["person_character"], {
                                ["name"] = cname, -- 人物名称
                                ["actor"] = cactor, -- 演员名称
                                ["link"] = clink -- 人物资料页URL
                                -- ["imgurl"]=cimgurl,  --人物图片URL
                            })
                            -- xml_v_nfo_crt=nil
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_v_nfo:readnext()
                end
                -- xml_v_nfo:clear()

                mepcount, ename, eindex, etype = 1, "", 1, 1

                if Metadata_info_origin_title then
                    mname = mdata["original_title"]
                    kiko.log("T " .. mname)
                else
                    mname = mdata["media_title"]
                    kiko.log("F " .. mname)
                end
                kiko.log("OOO " .. mname .. "\t" .. tostring(Metadata_info_origin_title))
                ename = mdata["media_title"]
                local err, movie_data_json = kiko.table2json(table.deepCopy(mdata))
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                mediainfo = {
                    ["name"] = mname, -- 动画名称
                    ["data"] = movie_data_json, -- 脚本可以自行存放一些数据
                    -- ["url"] = murl, -- 条目页面URL
                    -- ["desc"] = mdesc, -- 描述
                    -- ["airdate"] = mairdate, -- 放送日期，格式为yyyy-mm-dd
                    ["epcount"] = mepcount -- 分集数
                    -- ["coverurl"]=mcoverurl,      --封面图URL
                    -- ["staff"] = mstaff, -- staff
                    -- ["crt"] = mcrt -- 人物
                }
                -- get "Movie Name (YEAR)"
                if mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                    mediainfo["name"] = mname .. string.format(' (%s)', string.sub(mdata["release_date"], 1, 4))
                elseif myear ~= nil and myear ~= "" then
                    mediainfo["name"] = mname .. string.format(' (%s)', myear)
                end
                epinfo = {
                    ["name"] = ename, -- 分集名称
                    ["index"] = eindex, -- 分集编号（索引）
                    ["type"] = etype -- 分集类型
                }
                break

                -- tv_show
            elseif xml_v_nfo:name() == "episodedetails" then
                mdata["media_type"] = "tv"
                kiko.log('[INFO]  \t Reading tv episode nfo')
                xml_v_nfo:startelem()
                xml_v_nfo:readnext()
                -- read metadata
                while not xml_v_nfo:atend() do
                    if xml_v_nfo:startelem() then

                        if xml_v_nfo:name() ~= "actor" then
                            tmpElem = xml_v_nfo:elemtext() .. ""
                        else
                            tmpElem = ""
                        end
                        -- kiko.log("GE "..xml_v_nfo:name().."\t"..tmpElem)
                        if xml_v_nfo:name() == "title" then
                            ename = tmpElem
                        elseif xml_v_nfo:name() == "episode" then
                            eindex = tonumber(tmpElem)
                        elseif xml_v_nfo:name() == "season" then
                            if (tmpElem ~= nil and tmpElem ~= '') then
                                mdata["season_number"] = tonumber(tmpElem)
                                -- S00 == Specials
                                -- 分集类型: EP, SP, OP, ED, Trailer, MAD, Other 分别用1-7表示，默认为1（即EP，本篇）
                                if mdata["season_number"] == 0 then
                                    etype = 2
                                else
                                    etype = 1
                                end
                            end

                        elseif xml_v_nfo:name() == "director" then
                            if mdata["person_staff"] == nil then
                                mdata["person_staff"] = ''
                            end
                            mdata["person_staff"] = mdata["person_staff"] .. 'Director:' .. tmpElem .. ';'
                        elseif xml_v_nfo:name() == "actor" then
                            -- xml_v_nfo:readnext()
                            -- ignore actors
                            -- while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                            --     -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>'..tmpElem)
                            --     xml_v_nfo:readnext()

                            if mdata["person_character"] == nil then
                                mdata["person_character"] = {}
                            end
                            -- kiko.log("TEST  - Actor tag"..tmpElem)
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                            xml_v_nfo:readnext()
                            -- read actors in .nfo
                            while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                if xml_v_nfo:startelem() then
                                    tmpElem = xml_v_nfo:elemtext() .. ""
                                    if xml_v_nfo:name() == "role" then
                                        cname = tmpElem
                                    elseif xml_v_nfo:name() == "name" then
                                        cactor = tmpElem
                                    elseif xml_v_nfo:name() == "tmdbId" then
                                        clink = "https://www.themoviedb.org/person/" .. tmpElem
                                        -- elseif xml_v_nfo:name()=="content" then
                                        --     cimgurl = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                end
                                xml_v_nfo:readnext()
                            end
                            table.insert(mdata["person_character"], {
                                ["name"] = cname, -- 人物名称
                                ["actor"] = cactor, -- 演员名称
                                ["link"] = clink -- 人物资料页URL
                                -- ["imgurl"]=cimgurl,  --人物图片URL
                            })
                            -- kiko.log(tableToString(mdata["person_character"]))
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_v_nfo:readnext()
                end
                -- xml_v_nfo:clear()

                kiko.log('[INFO]  \t Reading tv season nfo')
                local xml_ts_path = path_folder_l .. 'season.nfo'
                local xml_ts_nfo = readxmlfile(xml_ts_path)
                if xml_ts_nfo == nil then
                    error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                    -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                    return {
                        ["success"] = false
                    };
                end
                while (xml_ts_nfo:endelem()) or xml_ts_nfo:name() ~= "season" do
                    xml_ts_nfo:readnext()
                end
                -- read metadata
                xml_ts_nfo:readnext()
                while not xml_ts_nfo:atend() do
                    if xml_ts_nfo:startelem() then
                        if xml_ts_nfo:name() ~= "actor" then
                            tmpElem = xml_ts_nfo:elemtext() .. ""
                        else
                            tmpElem = ""
                        end
                        if xml_ts_nfo:name() == "title" then
                            tstitle = tmpElem
                        elseif xml_ts_nfo:name() == "plot" then
                            mdata["overview"] = string.gsub(string.gsub(tmpElem, "\n\n", "\n"), "\r\n\r\n", "\r\n")
                        elseif xml_ts_nfo:name() == "premiered" then
                            local elemtext_tmp = tmpElem
                            if elemtext_tmp ~= nil then
                                mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                            end
                            if (myear == nil or myear == "") and mdata["release_date"] ~= nil and mdata["release_date"] ~=
                                "" then
                                myear = string.sub(mdata["release_date"], 1, 4)
                            end
                        elseif xml_ts_nfo:name() == "releasedate" then
                            local elemtext_tmp = tmpElem
                            if (mdata["release_date"] == nil or mdata["release_date"] == "") and elemtext_tmp ~= nil then
                                mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                            end
                            if (myear == nil or myear == "") and mdata["release_date"] ~= nil and mdata["release_date"] ~=
                                "" then
                                myear = string.sub(mdata["release_date"], 1, 4)
                            end
                        elseif xml_ts_nfo:name() == "seasonnumber" then
                            if (mdata["season_number"] == nil and tmpElem ~= nil and tmpElem ~= '') then
                                mdata["season_number"] = tonumber(tmpElem)
                                if mdata["season_number"] == 0 then
                                    etype = 2
                                else
                                    etype = 1
                                end
                            end
                            -- elseif xml_ts_nfo:name()=="content" then
                            -- mepcount = tmpElem

                        elseif xml_ts_nfo:name() == "actor" then
                            if mdata["person_character"] == nil then
                                mdata["person_character"] = {}
                            end
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                            xml_ts_nfo:readnext()
                            -- read actors in .nfo
                            while xml_ts_nfo:name() ~= "actor" or not (not xml_ts_nfo:startelem()) do
                                if xml_ts_nfo:startelem() then
                                    tmpElem = xml_ts_nfo:elemtext() .. ""
                                    if xml_ts_nfo:name() == "role" then
                                        cname = tmpElem
                                    elseif xml_ts_nfo:name() == "name" then
                                        cactor = tmpElem
                                    elseif xml_ts_nfo:name() == "tmdbId" then
                                        clink = "https://www.themoviedb.org/person/" .. tmpElem
                                        -- elseif xml_ts_nfo:name()=="content" then
                                        --     cimgurl = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_ts_nfo:name()..'>.'..tmpElem)
                                end
                                xml_ts_nfo:readnext()
                            end
                            -- TODO: 不确定这里是否需要去重
                            table.insert(mdata["person_character"], {
                                ["name"] = cname, -- 人物名称
                                ["actor"] = cactor, -- 演员名称
                                ["link"] = clink -- 人物资料页URL
                                -- ["imgurl"]=cimgurl,  --人物图片URL
                            })
                            -- kiko.log(tableToString(mdata["person_character"]))
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_ts_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_ts_nfo:readnext()
                end
                xml_ts_nfo:clear()

                kiko.log('[INFO]  \t Reading tv nfo')
                local xml_tv_path = path_folder_lf .. 'tvshow.nfo'
                local xml_tv_nfo = readxmlfile(xml_tv_path)
                if xml_tv_nfo == nil then
                    error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                    -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                    return {
                        ["success"] = false
                    };
                end
                while (xml_tv_nfo:endelem()) or xml_tv_nfo:name() ~= "tvshow" do
                    xml_tv_nfo:readnext()
                end
                -- read metadata
                xml_tv_nfo:readnext()
                while not xml_tv_nfo:atend() do
                    if xml_tv_nfo:startelem() then
                        if xml_tv_nfo:name() ~= "actor" then
                            tmpElem = xml_tv_nfo:elemtext() .. ""
                        else
                            tmpElem = ""
                        end
                        if xml_tv_nfo:name() == "title" then
                            mdata["media_title"] = tmpElem
                            -- if not (Metadata_info_origin_title) then
                            --     mname = mdata["media_title"]
                            -- end
                        elseif xml_tv_nfo:name() == "originaltitle" then
                            mdata["original_title"] = tmpElem
                            -- if Metadata_info_origin_title then
                            --     mname = mdata["original_title"]
                            -- end
                        elseif xml_tv_nfo:name() == "plot" then
                            -- mdesc = tmpElem
                            if mdata["overview"] ~= nil then
                                mdata["overview"] = string.gsub(string.gsub(mdata["overview"], "\n\n", "\n"),
                                    "\r\n\r\n", "\r\n") .. "\r\n"
                            else
                                mdata["overview"] = ""
                            end
                            mdata["overview"] = mdata["overview"] ..
                                                    string.gsub(string.gsub(tmpElem, "\n\n", "\n"), "\r\n\r\n", "\r\n")
                            -- elseif xml_tv_nfo:name()=="content" then
                            -- mcoverurl = tmpElem
                        elseif xml_tv_nfo:name() == "rating" then
                            mdata["vote_average"] = tmpElem
                            -- elseif xml_tv_nfo:name() == "sorttitle" then
                            --     mdata["sort_title"] = tmpElem
                        elseif xml_tv_nfo:name() == "mpaa" then
                            mdata["rate_mpaa"] = tmpElem
                        elseif xml_tv_nfo:name() == "tmdbid" then
                            mdata["media_id"] = string.format("%d", tonumber(tmpElem))
                            -- if mdata["media_id"] ~= nil then
                            --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                            -- end
                        elseif xml_tv_nfo:name() == "imdbid" then
                            mdata["media_imdbid"] = tmpElem
                        elseif xml_tv_nfo:name() == "country" then
                            if mdata["origin_country"] == nil then
                                mdata["origin_country"] = {}
                            end
                            table.insert(mdata["origin_country"], tmpElem)
                        elseif xml_tv_nfo:name() == "genre" then
                            if mdata["genre_names"] == nil then
                                mdata["genre_names"] = {}
                            end
                            table.insert(mdata["genre_names"], tmpElem)
                        elseif xml_tv_nfo:name() == "studio" then
                            if mdata["origin_company"] == nil then
                                mdata["origin_company"] = {}
                            end
                            table.insert(mdata["origin_company"], tmpElem)
                        elseif xml_tv_nfo:name() == "director" then
                            if mdata["person_staff"] == nil then
                                mdata["person_staff"] = ''
                            end
                            mdata["person_staff"] = mdata["person_staff"] .. "Director:" .. tmpElem .. ';' -- Director-zh
                        elseif xml_tv_nfo:name() == "actor" then
                            if mdata["person_character"] == nil then
                                mdata["person_character"] = {}
                            end
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                            -- read actors of tv
                            xml_tv_nfo:readnext()
                            while xml_tv_nfo:name() ~= "actor" or not (not xml_tv_nfo:startelem()) do
                                if xml_tv_nfo:startelem() then
                                    tmpElem = xml_tv_nfo:elemtext() .. ""
                                    if xml_tv_nfo:name() == "role" then
                                        cname = tmpElem
                                    elseif xml_tv_nfo:name() == "name" then
                                        cactor = tmpElem
                                        -- elseif xml_tv_nfo:name()=="content" then
                                        -- clink = tmpElem
                                        -- elseif xml_tv_nfo:name()=="content" then
                                        -- cimgurl = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_tv_nfo:name()..'>'..tmpElem)
                                end
                                xml_tv_nfo:readnext()
                            end
                            table.insert(mdata["person_character"], {
                                ["name"] = cname, -- 人物名称
                                ["actor"] = cactor -- 演员名称
                                -- ["link"]=clink,   --人物资料页URL
                                -- ["imgurl"]=cimgurl  --人物图片URL
                            })
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_tv_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_tv_nfo:readnext()
                end
                xml_tv_nfo:clear()

                local file_exist_test, file_exist_test_err, path_file_image_tmp
                if mdata["season_number"] ~= nil then
                    if mdata["season_number"] ~= "0" then
                        path_file_image_tmp = path_folder_lf .. "season" ..
                                                  string.format('S%02d', mdata["season_number"]) .. "-poster.jpg" -- season08-poster.jpg
                    else
                        path_file_image_tmp = path_folder_lf .. "season" ..
                                                  string.format('-specials', mdata["season_number"]) .. "-poster.jpg" -- season-specials-poster.jpg
                    end
                    file_exist_test, file_exist_test_err = io.open(path_file_image_tmp)
                    if file_exist_test ~= nil then
                        mdata["poster_path"] = path_file_image_tmp
                    else
                        mdata["poster_path"] = path_folder_lf .. "poster.jpg"
                    end
                    mdata["backdrop_path"] = path_folder_lf .. "fanart.jpg"
                end

                local err, ts_data_json = kiko.table2json(table.deepCopy(mdata))
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                -- get "TV Name S01"
                if mdata["season_number"] ~= nil then
                    -- TODO: 处理 tstitle 里的特殊 季标题
                    if not (Metadata_info_origin_title) then
                        mname = mdata["media_title"] .. ' 第' .. mdata["season_number"] .. "季"
                    else
                        mname = mdata["original_title"] .. string.format(' S%02d', mdata["season_number"])
                    end
                    -- mediainfo["data"] = mdata .. '/season/' .. mdata["season_number"]
                    -- mediainfo["url"] = "https://www.themoviedb.org/tv/" .. mdata
                else
                    if not (Metadata_info_origin_title) then
                        mname = mdata["media_title"]
                    else
                        mname = mdata["original_title"]
                    end
                end
                mediainfo = {
                    ["name"] = mname, -- 动画名称
                    ["data"] = ts_data_json -- 脚本可以自行存放一些数据
                    -- ["url"] = murl, -- 条目页面URL
                    -- ["desc"] = mdesc, -- 描述
                    -- ["airdate"] = mairdate, -- 放送日期，格式为yyyy-mm-dd
                    -- ["epcount"]=mepcount,       --分集数
                    -- ["coverurl"]=mcoverurl,      --封面图URL
                    -- ["staff"] = mstaff, -- staff
                    -- ["crt"] = mcrt -- 人物
                }
                if mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                    mediainfo["name"] = mediainfo["name"] ..
                                            string.format(' (%s)', string.sub(mdata["release_date"], 1, 4))
                end
                epinfo = {
                    ["name"] = ename, -- 分集名称
                    ["index"] = eindex, -- 分集编号（索引）
                    ["type"] = etype -- 分集类型
                }
                break
            end
        end
        xml_v_nfo:readnext()
    end
    xml_v_nfo:clear()
    kiko.log("[INFO]  TMDb matching succeeded.")

    mediainfo["scriptId"] = "Kikyou.l.TMDb"
    kiko.log("[INFO]  <mediainfo>")
    kiko.log(tableToStringLines(mediainfo))
    kiko.log("[INFO]  <epinfo>")
    kiko.log(tableToStringLines(epinfo))
    -- kiko.log("TEST  - others")
    -- kiko.log("| mname, mdata, murl, mairdate, myear | ename, eindex, etype, | mdata["season_number"], tstitle |")
    -- kiko.log("| mname, mdata, myear | ename, eindex, etype, | eseason, tstitle |")
    -- kiko.log('|', mname, '*', mdata, '*', murl, '*', mairdate, '*', myear)
    -- kiko.log('|', mname, '*', tableToString(mdata), '*', myear)
    -- kiko.log('|', ename, '*', tostring(eindex), '*', tostring(etype))
    -- kiko.log('|', tostring(eseason), '*', tstitle, '|')

    return {
        ["success"] = true,
        ["anime"] = mediainfo,
        ["ep"] = epinfo
    }

    -- ::continue_match_a::
end

-- Table，类型为 Array[LibraryMenu]
-- 如果资料库条目的scriptId和当前脚本的id相同，条目的右键菜单中会添加menus包含的菜单项，用户点击后会通过menuclick函数通知脚本
menus = {{
    ["title"] = "打开TMDb页面",
    ["id"] = "open_tmdb_webpage"
}}

-- 用户点击条目的右键菜单中的menus菜单后，会通过menuclick函数通知脚本
--- TODO: 格式化显示 anime["data"]
function menuclick(menuid, anime)
    -- menuid： string，点击的菜单ID
    -- anime： Anime， 条目信息
    -- 返回：无
    local NM_HIDE = 1
    local NM_PROCESS = 2
    local NM_SHOWCANCEL = 4
    local NM_ERROR = 8
    local NM_DARKNESS_BACK = 16
    kiko.log("Menu Click: ", menuid)

    if menuid == "open_tmdb_webpage" then
        -- 打开对应TMDb页面
        kiko.message("Menu Action: Open TMDb Webpage", NM_HIDE)
        kiko.execute(true, "cmd", {"/c", "start", anime["url"]})
    end
end

-- 对修改设置项`settings`响应。KikoPlay当 设置中修改了脚本设置项 时，会尝试调用`setoption`函数通知脚本。
-- key为设置项的key，val为修改后的value
function setoption(key, val)
    kiko.log(string.format("[INFO]  Settings changed: %s = %s", key, val))
end

---------------------
-- 功能函数
--

-- 特殊字符转换 "&amp;" -> "&"  "&quot;" -> "\""
-- copy from & thanks to "..\\library\\bangumi.lua"
--- TODO: 在此可能用于媒体的标题名中的特殊符号，但是不知道需不需要、用不用得上。
function unescape(str)
    if type(str) ~= "string" then
        return str
    end
    str = string.gsub(str, '&lt;', '<')
    str = string.gsub(str, '&gt;', '>')
    str = string.gsub(str, '&quot;', '"')
    str = string.gsub(str, '&apos;', "'")
    str = string.gsub(str, '&#(%d+);', function(n)
        return utf8.char(n)
    end)
    str = string.gsub(str, '&#x(%x+);', function(n)
        return utf8.char(tonumber(n, 16))
    end)
    str = string.gsub(str, '&amp;', '&') -- Be sure to do this after all others
    return str
end
-- ]]--
--[[
-- copy from & thanks to "..\\danmu\\iqiyi.lua"
function readxmlcontent(xmlreader, dstname, srcname)
    local curText, curTime, curColor, curDate, curUID = nil, nil, nil, nil, nil
    while not xmlreader:atend() do
        if xmlreader:startelem() then
            if xmlreader:name() == "contentId" then
                curDate = string.sub(xmlreader:elemtext(), 1, 10)
            elseif xmlreader:name() == "content" then
                curText = xmlreader:elemtext()
            elseif xmlreader:name() == "showTime" then
                curTime = tonumber(xmlreader:elemtext()) * 1000
            elseif xmlreader:name() == "color" then
                curColor = tonumber(xmlreader:elemtext(), 16)
            elseif xmlreader:name() == "uid" then
                curUID = "[iqiyi]" .. xmlreader:elemtext()
            end
        elseif xmlreader:endelem() then
            if xmlreader:name() == "bulletInfo" then
                table.insert(dstname, {
                    ["text"] = curText,
                    ["time"] = curTime,
                    ["color"] = curColor,
                    ["date"] = curDate,
                    ["sender"] = curUID
                })
            end
        end
        xmlreader:readnext()
    end
end
]] --

-- 读 xml 文本文件
-- path_xml:video.nfo|file_nfo -> kiko.xmlreader:xml_file_nfo
-- 拓展名 .nfo，内容为 .xml 格式
-- 文件来自 Emby 的本地服务器 在电影/剧集文件夹存储 从网站刮削出的信息。
function readxmlfile(path_xml)

    -- local io_status =io.type(path_xml)
    -- if io_status ==nil then
    -- error("readxmlfile - Fail to get valid path of file < ".. path_xml .. ' >.')
    -- return nil;
    -- end
    local file_nfo = io.open(path_xml, 'r')
    if file_nfo == nil then
        error("readxmlfile - Fail to open file < " .. path_xml .. ' >.')
        return nil;
    end
    local xml_file_nfo = file_nfo:read("*a")
    if xml_file_nfo == nil then
        error("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        return nil;
    end
    file_nfo:close()
    local kxml_file_nfo = kiko.xmlreader(xml_file_nfo)
    xml_file_nfo = nil
    local err = kxml_file_nfo:error()
    if err ~= nil then
        error("readxmlfile - Fail to read xml content < " .. path_xml .. ' | ' .. file_nfo .. ' >. ' .. err)
        return nil;
    end
    return kxml_file_nfo
end

-- string.find reverse
-- 反向查找字符串
-- string:str  string:substr  number|int:ix -> number|int:字串首位索引
function stringfindre(str, substr, ix)
    if ix < 0 then
        ix = #str + ix + 1
    end
    local dstl, dstr = string.find(string.reverse(str), string.reverse(substr), #str - ix + 1, true)
    return #str - dstl + 1, #str - dstr + 1
end

--[[
-- 打印 <table>
-- copy from & thanks to: https://blog.csdn.net/HQC17/article/details/52608464
function printT(table, level)
    local key = ""
    level = level or 1
    local indent = ""
    for i = 1, level do
        indent = indent .. "  "
    end

    if key ~= "" then
        print(indent .. key .. " " .. "=" .. " " .. "{")
    else
        print(indent .. "{")
    end

    key = ""
    for k, v in pairs(table) do
        if type(v) == "table" then
            key = k
            printT(v, level + 1)
        else
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v))
            print(content)
        end
    end
    print(indent .. "}")
    printT(table, level)
end
]] --
-- 打印 <table> 至 kiko
-- copy from & thanks to: https://blog.csdn.net/HQC17/article/details/52608464
-- { k = v }
Key_tts = "" -- 暂存来自上一级的键Key
function tableToStringPrint(table, level)
    if (table == nil) then
        return ""
    end
    local indent = "" -- 打印的缩进
    local content = "" -- 暂存的字符串

    level = level or 1 -- 根级别 无缩进
    -- 按与根相差的级别缩进，每一个递归加一
    for i = 1, level do
        indent = indent .. "  "
    end

    local str = "" -- return的字符串
    -- 输出键名
    if Key_tts ~= "" then
        content = (indent .. Key_tts .. " " .. "=" .. " " .. "{")
        str = str .. content .. "\n"
        kiko.log(content)
    else
        content = (indent .. "{")
        str = str .. content .. "\n"
        kiko.log(content)
    end

    Key_tts = ""
    for k, v in pairs(table) do
        if type(v) == "table" then
            -- <table>变量，递归
            Key_tts = k
            str = str .. tableToStringPrint(v, level + 1)
        else
            -- 普通变量，直接打印
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v))
            str = str .. content .. "\n"
            kiko.log(content)
        end
    end
    -- "}"
    str = str .. (indent .. "}") .. "\n"
    kiko.log(indent .. "}")
    return str
end
-- table 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"(k)v, (k)[(k)v, (k)v], "
function tableToString(table0)
    --
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "(" .. k .. ")" .. v .. ", "
        else
            -- <table>变量，递归
            str = str .. "(" .. k .. ")" .. "[ " .. tableToString(v) .. " ], "
        end
    end
    return str
end
-- array 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <array>table0 -> <string>:"v, [(k)v, (k)v], "
function arrayToString(table0)
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. v .. ", "
        else
            -- <table>变量，递归
            str = str .. "[ " .. tableToString(v) .. " ], "
        end
    end
    return str
end
-- table 转 多行的string - 把表转为多行（含\n）的字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"[k]\t v,\n [ (k)v,\t (k)v ], \n"
function tableToStringLines(table0, tabs)
    if tabs == nil then
        -- 根级别 无缩进
        tabs = 0
    end
    -- 排除非<table>类型
    if type(table0) ~= "table" then
        return ""
    end
    local str = "{ \n" -- 要return的字符串
    for k, v in pairs(table0) do
        for i = 1, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            print("\t")
            tabs = tabs + 1
        end
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "[ " .. k .. " ] : \t" .. v .. "\n"
        else
            -- <table>变量，递归
            str = str .. "[ " .. k .. " ] : \t" .. "[ \n" .. tableToStringLines(v, tabs) .. " ]\n"
        end
    end
    return str.."\n} "
end

-- 深拷贝<table>，包含元表(?)，不考虑键key为<table>的情形
-- copy from & thanks to - https://blog.csdn.net/qq_36383623/article/details/104708468
function table.deepCopy(tb)
    if tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return nil
    end
    local copy = {}
    for k, v in pairs(tb) do
        if type(v) == 'table' then
            -- 值是<table>，递归复制<table>值
            copy[k] = table.deepCopy(v)
        else
            -- 普通值，直接赋值
            copy[k] = v
        end
    end
    -- local meta = table.deepCopy(getmetatable(tb))
    -- TODO: 不知道这里是做什么的，就照源码放这里了 (元表?)
    setmetatable(copy, table.deepCopy(getmetatable(tb)))
    return copy
end
