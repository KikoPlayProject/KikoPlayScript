-- TMDb+ Lib Scraper
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TMDb+Lib",
    ["id"] = "Kikyou.l.TMDb",
    ["desc"] = "TMDb+ 资料刮削脚本  -  Edited by: kafovin \n"..
                "从 The Movie Database (TMDb) 刮削影剧元数据，也可设置选择刮削fanart的媒体图片、Jellyfin/Emby的本地元数据、TVmaze的剧集演员。",
    --            "▲与0.2.2-版本不兼容▲ 建议搜索旧关联用`本地数据库`，仅刮削详旧资料细信息时设置`搜索-关键词作标题`为`1`。",
    ["version"] = "0.2.29", -- 0.2.29.221005_build
    ["min_kiko"] = "0.9.1",
}

-- 设置项
-- `key`为设置项的`key`，`value`是一个`table`。设置项值`value`的类型都是字符串。
-- 由于加载脚本后的特性，在脚本中，可以直接通过`settings["xxxx"]`获取设置项的值。
settings = {
    ["api_key"] = {
        ["title"] = "API - TMDb的API密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "[必填项] 在`themoviedb.org`注册账号，并把个人设置中的API申请到的\n"..
                    "`API 密钥` (api key) 填入此项。 ( `https://www.themoviedb.org/settings/api`，一般为一串字母数字)",
        ["group"]="API授权",
    },
    ["api_key_fanart"] = {
        ["title"] = "API - fanart的API密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "[选填项] 在 `fanart.tv` 注册账号，并把页面`https://fanart.tv/get-an-api-key/`中申请到的\n"..
                    "`Personal API Keys` 填入此项。（一般为一串字母数字）\n"..
                    "注意：若需要跳过刮削fanart.tv的图片，请将设置项 `元数据 - 图片主要来源` 设为 `TMDb_only`。",
        ["group"]="API授权",
    },
    -- ["api_key_trakt"] = {
    --     ["title"] = "API - Trakt的API密钥",
    --     ["default"] = "<<API_Key_Here>>",
    --     ["desc"] = "[选填项] 在 `trakt.tv` 注册账号，并把页面`https://trakt.tv/oauth/applications`中申请到的\n"..
    --                 "`Client ID` 填入此项。（一般为一串字母数字）\n"..
    --                 "注意：目前Trakt用于 用户记录，例如 评分媒体、标记媒体为 稍后看/已看过/已收集。",
    --     ["group"]="API授权",
    -- },
    -- ["search_keyword_process"] = {
    --     ["title"] = "搜索 - 关键词处理",
    --     ["default"] = "filename",
    --     ["desc"] = "输入的字符经过何种处理作为关键词，来搜索媒体（不含集序号）。\n"..
    --             "filename：作为除去拓展名的文件名 (默认)。 plain：不处理，作为单纯的标题关键词（搜索请不要输入季序号等）。", -- 丢弃`person`的演员搜索结果
    --     ["choices"] = "filename,plain",
    --     ["group"]="搜索",
    -- },
    -- ["search_keyword_astitle"] = {
    --     ["title"] = "搜索 - 关键词作标题",
    --     ["default"] = "0",
    --     ["desc"] = "搜索的关键词是否作为标题。\n 0：不使用 (默认)。 1：使用关键词作为标题。",
    --     ["choices"] = "0,1",
    --     ["group"]="搜索",
    -- },
    -- ["search_list_season_all"] = {
    --     ["title"] = "搜索 - 显示更多季",
    --     ["default"] = "1",
    --     ["desc"] = "搜索操作中 在没识别到季序号时，是否显示全部季数。\n".."当且仅当 `搜索 - 关键词处理` 设置为 `filename`时有效。\n"..
    --             "0：没识别到季序号时，仅显示第1季、或特别篇。 1：没识别到季序号时，显示全部季数 (默认)。", -- 丢弃`person`的演员搜索结果
    --     ["choices"] = "0,1",
    --     ["group"]="搜索",
    -- },
    -- ["search_list_season_epgroup"] = {
    --     ["title"] = "搜索 - 显示剧集其他版本",
    --     ["default"] = "0",
    --     ["desc"] = "搜索操作中 是否搜索并显示 剧集其他版本及其各季。其他版本会把剧集以不同方式分季(如：原播出时间、故事线、数字出版等)。\n"..
    --             "0：不显示其他版本的季数 (默认)。 1：显示剧集其他版本及其各季数。", -- 丢弃`person`的演员搜索结果
    --     ["choices"] = "0,1",
    --     ["group"]="搜索",
    -- },
    -- ["search_type"] = {
    --     ["title"] = "搜索 - 媒体类型",
    --     ["default"] = "multi",
    --     ["desc"] = "搜索的数据仅限此媒体类型。\n movie：电影。 multi：电影/剧集 (默认)。 tv：剧集。", -- 丢弃`person`的演员搜索结果
    --     ["choices"] = "movie,multi,tv",
    --     ["group"]="搜索",
    -- },
    ["match_source"] = {
        ["title"] = "匹配 - 数据来源",
        ["default"] = "online_TMDb_filename",
        ["desc"] = "自动匹配本地媒体文件的数据来源。值为<local_Emby_nfo>时需要用软件Emby提前刮削过。\n" ..
                    "local_Emby_nfo：来自Jellyfin/Emby在刮削TMDb媒体后 在本地媒体文件同目录存储元数据的 .nfo格式文件(内含.xml格式文本) (不稳定/可能不兼容)；\n" ..
                    "online_TMDb_filename：从文件名模糊识别关键词，再用TMDb的API刮削元数据 (不稳定) (默认)。 (*￣▽￣）", -- 丢弃`person`的演员搜索结果
        ["choices"] = "local_Emby_nfo,online_TMDb_filename",
        ["group"]="匹配",
    },
    ["match_priority"] = {
        ["title"] = "匹配 - 备用媒体类型",
        ["default"] = "multi",
        ["desc"] = "模糊匹配文件名信息时，类型待定的媒体以此类型匹配，仅适用于匹配来源为`online_TMDb_filename`的匹配操作。\n" ..
                    "此情况发生于文件名在描述 所有的电影、以及一些情况的剧集正篇或特别篇 的时候。\n" ..
                    -- "other：识别为`其他`类型的集（不同于本篇/特别篇），置于剧集特别篇或电影中。\n" ..
                    "movie：电影。multi：采用刮削时排序靠前的影/剧 (默认)。tv：剧集。single：以对话框确定影/剧某一种 (不稳定)。",
        ["choices"] = "movie,multi,single,tv",
                    -- "movie,multi,tv,movie_other,multi_other,tv_other"
        ["group"]="匹配",
    },
    ["metadata_lang"] = {
        ["title"] = "元数据 - 语言地区",
        ["default"] = "zh-CN",
        ["desc"] = "按此`语言编码-地区编码`搜索元数据资料，主要指简介、海报、搜索的标题等。看着有很多语言，其实大部分都缺乏资料。\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请使用`搜索 - 关键词作标题`的功能重新搜索详细信息。\n" ..
                    "zh-CN：中文(中国)，(默认)。zh-HK：中文(香港特區,中國)。zh-TW：中文(台灣省，中國)。\n" ..
                    "en-US：English(US)。es-ES：español(España)。fr-FR：Français(France)。ja-JP：日本語(日本)。ru-RU：Русский(Россия)。",
        ["choices"] = "af-ZA,ar-AE,ar-SA,be-BY,bg-BG,bn-BD,ca-ES,ch-GU,cn-CN,cs-CZ,cy-GB,da-DK" ..
                    ",de-AT,de-CH,de-DE,el-GR,en-AU,en-CA,en-GB,en-IE,en-NZ,en-US,eo-EO,es-ES,es-MX,et-EE" ..
                    ",eu-ES,fa-IR,fi-FI,fr-CA,fr-FR,ga-IE,gd-GB,gl-ES,he-IL,hi-IN,hr-HR,hu-HU,id-ID,it-IT" ..
                    ",ja-JP,ka-GE,kk-KZ,kn-IN,ko-KR,ky-KG,lt-LT,lv-LV,ml-IN,mr-IN,ms-MY,ms-SG,nb-NO,nl-BE" ..
                    ",nl-NL,no-NO,pa-IN,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,si-LK,sk-SK,sl-SI,sq-AL,sr-RS,sv-SE" ..
                    ",ta-IN,te-IN,th-TH,tl-PH,tr-TR,uk-UA,vi-VN,zh-CN,zh-HK,zh-SG,zh-TW,zu-ZA",
        -- ["choices"] = "ar-SA,de-DE,en-US,es-ES,fr-FR,it-IT,ja-JP,ko-KR,pt-PT,ru-RU,zh-CN,zh-HK,zh-TW",
        -- ["choices"] = "en-US,fr-FR,ja-JP,ru-RU,zh-CN,zh-HK,zh-TW",
        ["group"]="元数据 - 语言",
    },
    ["metadata_info_update_keep"] = {
        ["title"] = "元数据 - 更新时维持更改",
        ["default"] = "0",
        ["desc"] = "更新资料夹元数据时，对于之前的编辑的更改(例如描述、演职员表等)，是否保留。\n" ..
                    "0：不保留 (默认)。 1：保留(当前不支持此功能)。",
        ["choices"] = "0",
        ["group"]="元数据 - 其他",
    },
    ["metadata_info_origin_title"] = {
        ["title"] = "元数据 - 标题优先原语言",
        ["default"] = "0",
        ["desc"] = "媒体的标题 是否优先使用媒体原语言。(不论此项的设置，更新详细信息时 始终维持已有的标题。)\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请使用`搜索 - 关键词作标题`的功能重新搜索详细信息。\n"..
                    "0：优先使用刮削时`元数据 - 语言`所设定的语言 (默认)。 1：优先使用原语言。",
        ["choices"] = "0,1",
        ["group"]="元数据 - 语言",
    },
    ["metadata_info_origin_image"] = {
        ["title"] = "元数据 - 图片优先原语言",
        ["default"] = "0",
        ["desc"] = "媒体的图片 是否优先使用媒体原语言。\n"..
                    "0：优先使用刮削时`元数据 - 语言`所设定的语言 (默认)。 1：优先使用原语言。 2：优先使用无语言。",
        ["choices"] = "0,1,2",
        ["group"]="元数据 - 语言",
    },
    ["metadata_image_priority"]={
        ["title"] = "元数据 - 图片主要来源",
        ["default"] = "TMDb_only",
        ["desc"] = "元数据的图片源是使用TMDb还是fanart，需要各自的api密钥。\n"..
                    "其中，fanart的网络连接比较缓慢 (经常会加载失败)、图片种类更多 (可完全覆盖TMDb中所有图片种类)。\n"..
                    "fanart_prior：图片优先fanart，(由于fanart的图片种类较多，因此TMDb的图片通常会被忽略)。\n"..
                    "TMDb_only：图片仅TMDb，(不会从fanart刮削图片，仅此项不需要 fanart的API密钥) (默认)。\n"..
                    "TMDb_prior：图片优先TMDb，TMDb提供海报、背景，其他的由fanart提供。",
        ["choices"] = "fanart_prior,TMDb_only,TMDb_prior",
        ["group"]="元数据 - 图片",
    },
    ["metadata_show_imgtype"] = {
        ["title"] = "元数据 - 显示的图片种类",
        ["default"] = "background",
        ["desc"] = "仅限资料夹的右键菜单里`显示媒体元数据`弹出窗口中 所显示的那一张图片的种类。\n"..
                    "当 `元数据 - 图片主要来源` 设置为`TMDb_only`时，仅海报、背景、标志可用。\n"..
                    "当 `元数据 - 图片主要来源` 设置为`fanart_prior`或`TMDb_prior`时，以下均有效（除非图片未刮削到）。\n" ..
                    "poster: 海报。banner: 横幅。thumb: 缩略图。background: 背景 (默认)。\n"..
                    "logo: 标志。art: 艺术图。otherart: 其他艺术图。",
                    -- "logo: 标志。logoL: 标志*。art: 艺术图。artL: 艺术图*。otherart: 其他艺术图。",
        ["choices"] = "poster,banner,thumb,background,logo,art,otherart",
        -- ["choices"] = "poster,banner,thumb,background,logo,logoL,art,artL,otherart",
        ["group"]="元数据 - 图片",
    },
    ["metadata_castcrew_castcount"]={
        ["title"] = "元数据 - 演员总数至多为",
        ["default"] = "12",
        ["desc"] = "元数据的演员表至多保留多少演员 (默认 12)。\n"..
                    "其中，数目>0时，为至多保留的数目；数目=0时，不保留；数目<0时，保留所有；小数，则向负无穷方向取整。",
        ["group"]="元数据 - 演职员",
    },
    ["metadata_castcrew_crewcount"]={
        ["title"] = "元数据 - 职员总数至多为",
        ["default"] = "12",
        ["desc"] = "元数据的职员表至多保留多少职员 (默认 12)。\n"..
                    "其中，数目>0时，为至多保留的数目；数目=0时，不保留；数目<0时，保留所有；小数，则向负无穷方向取整。",
        ["group"]="元数据 - 演职员",
    },
    ["metadata_castcrew_season_aggregate"]={
        ["title"] = "元数据 - 本季所有演职员",
        ["default"] = "0",
        ["desc"] = "元数据对于剧集某季的演职员表，是否也包括所有单集的演职员。\n"..
                    "0：仅包括出现于或负责本季整季的演职员 (默认)。 1：包含前者，以及出现于或负责各集的演职员(按默认顺序)。",
        ["choices"] = "0,1",
        ["group"]="元数据 - 演职员",
    },
    ["metadata_castcrew_source_cast"]={
        ["title"] = "元数据 - 演员来源",
        ["default"] = "TMDb_season",
        ["desc"] = "元数据中演员表的数据来源。\n"..
                    "TMDb_season：本电影或剧集本季的演员表 来自TMDb  (默认)。\n"..
                    "TVmaze_show：剧集本季的演员表 来自TVmaze 对应的本剧集整剧(不是本季)，本电影 来源取默认，仅英文。",
        ["choices"] = "TMDb_season,TVmaze_show",
        ["group"]="元数据 - 演职员",
    },
}

scriptmenus = {
    {["title"]="检测连接", ["id"]="detect_valid_api"},
    {["title"]="使用方法", ["id"]="link_repo_usage"},
    {["title"]="关于", ["id"]="display_dialog_about"},
}

searchsettings = {
    ["search_keyword_astitle"] = {
        ["title"] = "关键词作弹幕池标题 ",
        ["default"] = "0",
        ["desc"] = "搜索的关键词是否作为标题。\n 不选(0)：不使用 (默认)。 选中(1)：使用关键词作为标题。",
        -- ["choices"] = "0,1",
        ["save"]=false,
        ["display_type"] = 3,
    },
    ["search_keyword_process"] = {
        ["title"] = "关键词作文件名识别  | ",
        ["default"] = "1",
        -- ["default"] = "filename",
        ["desc"] = "输入的字符经过何种处理作为关键词，来搜索媒体（不含集序号）。\n"..
                "不选(0)：不处理，作为单纯的标题关键词（搜索请不要输入季序号等）。 选中(1)：作为除去拓展名的文件名 (默认)。", -- 丢弃`person`的演员搜索结果
        --      "filename：作为除去拓展名的文件名 (默认)。 plain：不处理，作为单纯的标题关键词（搜索请不要输入季序号等）。", -- 丢弃`person`的演员搜索结果
        -- ["choices"] = "filename,plain",
        ["save"]=true,
        ["display_type"] = 3,
    },
    ["search_list_season_all"] = {
        ["title"] = "显示更多季 ",
        ["default"] = "1",
        ["desc"] = "搜索操作中 在没识别到季序号时，是否显示全部季数。\n".."当且仅当 `搜索 - 关键词处理` 设置为 `filename`时有效。\n"..
                "不选(0)：没识别到季序号时，仅显示第1季、或特别篇。 选中(1)：没识别到季序号时，显示全部季数 (默认)。", -- 丢弃`person`的演员搜索结果
        -- ["choices"] = "0,1",
        ["save"]=false,
        ["display_type"] = 3,
    },
    ["search_list_season_epgroup"] = {
        ["title"] = "显示其他版本  | ",
        ["default"] = "0",
        ["desc"] = "搜索操作中 是否搜索并显示 剧集其他版本及其各季。其他版本会把剧集以不同方式分季(如：原播出时间、故事线、数字出版等)。\n"..
                "不选(0)：不显示其他版本的季数 (默认)。 选中(1)：显示剧集其他版本及其各季数。", -- 丢弃`person`的演员搜索结果
        -- ["choices"] = "0,1",
        ["save"]=false,
        ["display_type"] = 3,
    },
    ["search_type"] = {
        ["title"] = "媒体类型",
        ["default"] = "电影/剧集",
        -- ["default"] = "multi",
        ["desc"] = "搜索的数据仅限此媒体类型。\n 电影：仅电影。 电影/剧集：电影 或 剧集 (默认)。 剧集：仅剧集。", -- 丢弃`person`的演员搜索结果
        -- ["desc"] = "搜索的数据仅限此媒体类型。\n movie：电影。 multi：电影/剧集 (默认)。 tv：剧集。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "电影/剧集,电影,剧集",
        -- ["choices"] = "movie,multi,tv",
        ["save"]=false,
        ["display_type"] = 1,
    },
}

-- 不会 在运行函数内更新值
Metadata_search_page = 1 -- 元数据搜索第几页。 默认：第 1 页
Metadata_search_adult = false -- Choose whether to inlcude adult content in the results when searching metadata. Default: false
-- 会  在运行函数内更新值
Metadata_info_origin_title = true -- 是否使用源语言标题
Metadata_info_origin_image = true -- 是否使用源语言图片 --仅fanart图片
Metadata_person_max_cast = 16 -- 演员表最多保留
Metadata_person_max_crew = 16 -- 职员表最多保留
Metadata_show_imgtype="background" -- 图片类型使用背景
Tag_rating_on_region = {"FR", "GB", "HK", "RU","US",}

NM_HIDE = 1 -- 一段时间后自动隐藏
NM_PROCESS = 2 -- 显示busy动画
NM_SHOWCANCEL = 4 -- 显示cancel按钮
NM_ERROR = 8 -- 错误信息
NM_DARKNESS_BACK = 16 -- 显示暗背景，阻止用户执行其他操作

Array={}
Kikoplus={}
Path={}
-- 说明: 三目运算符 ((condition) and {trueCDo} or {falseCDo})[1] === (condition)?(trueCDo):(falseCDo)
-- (() and{} or{})[1]

-- TMDb图片配置
Image_tmdb = {
    ["prefix"]= "https://image.tmdb.org/t/p/", -- 网址前缀
    -- path="https://image.tmdb.org/t/p/" .. "size" .. "/q1w2e3.png"
    ["min_ix"]= 2, -- 尺寸索引
    ["mid_ix"]= 5,
    ["max_ix"]= 7,
    ["background"]= {"w300","w300","w780","w780","w1280","w1280","original"}, -- 影/剧剧照
    ["logo"]= {"w45","w92","w154","w185","w300","w500","original"}, -- /company/id - /network/id - 出品公司/电视网标志
    ["poster"]= {"w92","w154","w185","w342","w500","w780","original"}, -- 影/剧海报
    ["profile"]= {"w45","w45","w185","w185","h632","h632","original"}, -- /person/id 演员肖像
    ["still"]= {"w92","w92","w185","w185","w300","w300","original"}, -- /tv/id/season/sNum/episode/eNum 单集剧照
}
Image_fanart = {
    ["prefix"]= "https://assets.fanart.tv/",
    ["size"]= {"preview","fanart"},
    ["min_ix"]= 1, -- 尺寸索引
    ["mid_ix"]= 1,
    ["max_ix"]= 2,
    ["len_preix_size"]= 31, -- https://assets.fanart.tv/fanart (30) not https
    -- image_path="/movies/id/type/title-name-q1w2e3.png" "/tv/id/type/title-name-q1w2e3.png"
    ["movie"]={"movieposter","moviebanner","moviethumb","moviebackground",
                "hdmovielogo","movielogo","hdmovieclearart","movieart","moviedisc",},
    ["tv"]={"tvposter","tvbanner","tvthumb","showbackground",
                "hdtvlogo","clearlogo","hdclearart","clearart","characterart",},
    ["season"]={"seasonposter","seasonbanner","seasonthumb ","showbackground",},
    ["type_zh"]={
        ["movieposter"]="电影海报",["moviebanner"]="电影横幅",["moviethumb"]="电影缩略图",["moviebackground"]="电影背景",
        ["hdmovielogo"]="电影标志",["movielogo"]="电影标志*",["hdmovieclearart"]="电影艺术图",["movieart"]="电影艺术图*",["moviedisc"]="电影光盘",
        ["tvposter"]="剧集海报",["tvbanner"]="剧集横幅",["tvthumb"]="剧集缩略图",["showbackground"]="剧/季背景",["tvbackground"]="剧/季背景",["tvlogo"]="剧集标志",
        ["hdtvlogo"]="剧集标志",["clearlogo"]="剧集标志*",["hdclearart"]="剧集艺术图",["clearart"]="剧集艺术图*",["characterart"]="剧集角色图",
        ["seasonposter"]="本季海报",["seasonbanner"]="本季横幅",["seasonthumb"]="本季缩略图",["seasonbackground"]="本季背景",["seasonlogo"]="本季标志",
    },
}
Translation = {
    ["und-XX"] = {
        ["language"]={ [""]= "Others", ["Unknown"]= "Unknown", ["cmn"]="Mandarin", ["mis"]="", ["mul"]="Multi Languages", ["und"]="Undetermined", ["zxx"]="No Language", ["xx"]="No Language", ["00"]="No Language", },
        ["region"]={ [""]= "Others", ["Unknown"]= "Unknown", ["XX"]="Undetermined", ["XZ"]="International Water", ["ZZ"]="未识别", ["International"]="International", },
        ["media_genre"] = {[""]= "Others", ["Unknown"]= "Unknown", ["Adult"]= "Adult", },
        ["media_status"] = { [""]= "Others", ["Unknown"]= "Unknown", },
        ["media_type"] = { [""]= "Others", ["Unknown"]= "Unknown", },
        ["character_gsub"] = { {"^$","Unknown Character"}, },
        ["department"] = { [""]= "Others", ["Unknown"]= "Unknown", },
        ["credit_job"] = { [""]= "Others", ["Unknown"]= "Unknown", },
        ["media_type_epgroup"] = { [1]= "Original air date", [2]= "Absolute", [3]= "DVD", [4]= "Digital", [5]= "Story arc", [6]= "Production", [7]= "TV", [""]= "Others", ["Unknown"]= "Unknown", },
    },
}
Translation["zh-CN"] = {
    ["language"]={
        ["aa"]= "阿法尔语", ["ab"]= "阿布哈兹语", ["af"]= "南非荷兰语", ["ak"]= "阿坎语", ["sq"]= "阿尔巴尼亚语", ["am"]= "阿姆哈拉语", ["ar"]= "阿拉伯语", ["an"]= "阿拉贡语", ["hy"]= "亚美尼亚语", ["as"]= "阿萨姆语", ["av"]= "阿瓦尔语", ["ae"]= "阿维斯陀语", ["ay"]= "艾马拉语", ["az"]= "阿塞拜疆语", ["ba"]= "巴什基尔语",
        ["bm"]= "班巴拉语", ["eu"]= "巴斯克语", ["be"]= "白俄罗斯语", ["bn"]= "孟加拉语", ["bh"]= "比哈尔语", ["bi"]= "比斯拉玛语", ["bs"]= "波斯尼亚语", ["br"]= "布里多尼语", ["bg"]= "保加利亚语", ["my"]= "缅甸语", ["ca"]= "加泰罗尼亚语", ["ch"]= "查莫罗语", ["ce"]= "车臣语", ["zh"]= "汉语", ["cu"]= "教会斯拉夫语",
        ["cv"]= "楚瓦什语", ["kw"]= "康沃尔语", ["co"]= "科西嘉语", ["cr"]= "克里语", ["cs"]= "捷克语", ["da"]= "丹麦语", ["dv"]= "迪维希语", ["nl"]= "荷兰语", ["dz"]= "不丹语", ["en"]= "英语", ["eo"]= "世界语", ["et"]= "爱沙尼亚语", ["ee"]= "埃维语", ["fo"]= "法罗语", ["fj"]= "斐济语", ["fi"]= "芬兰语", ["fr"]= "法语",
        ["fy"]= "弗里西亚语", ["ff"]= "富拉语", ["ka"]= "格鲁吉亚语", ["de"]= "德语", ["gd"]= "苏格兰盖尔语", ["ga"]= "爱尔兰语", ["gl"]= "加利西亚语", ["gv"]= "马恩岛语", ["el"]= "现代希腊语", ["gn"]= "瓜拉尼语", ["gu"]= "古吉拉特语", ["ht"]= "海地克里奥尔语", ["ha"]= "豪萨语", ["he"]= "希伯来语", ["hz"]= "赫雷罗语",
        ["hi"]= "印地语", ["ho"]= "希里莫图语", ["hr"]= "克罗地亚语", ["hu"]= "匈牙利语", ["ig"]= "伊博语", ["is"]= "冰岛语", ["io"]= "伊多语", ["ii"]= "四川彝语", ["iu"]= "伊努伊特语", ["ie"]= "国际语E", ["ia"]= "拉丁国际语", ["id"]= "印尼语", ["ik"]= "依努庇克语", ["it"]= "意大利语", ["jv"]= "爪哇语", ["ja"]= "日语",
        ["kl"]= "格陵兰语", ["kn"]= "卡纳达语", ["ks"]= "克什米尔语", ["kr"]= "卡努里语", ["kk"]= "哈萨克语", ["km"]= "高棉语", ["ki"]= "基库尤语", ["rw"]= "基尼阿万达语", ["ky"]= "吉尔吉斯语", ["kv"]= "科米语", ["kg"]= "刚果语", ["ko"]= "朝鲜语", ["kj"]= "宽亚玛语", ["ku"]= "库尔德语", ["lo"]= "老挝语", ["la"]= "拉丁语",
        ["lv"]= "拉脱维亚语", ["li"]= "林堡语", ["ln"]= "林加拉语", ["lt"]= "立陶宛语", ["lb"]= "卢森堡语", ["lu"]= "卢巴-加丹加语", ["lg"]= "干达语", ["mk"]= "马其顿语", ["mh"]= "马绍尔语", ["ml"]= "马拉雅拉姆语", ["mi"]= "毛利语", ["mr"]= "马拉提语", ["ms"]= "马来语", ["mg"]= "马达加斯加语", ["mt"]= "马耳他语",
        ["mo"]= "摩尔达维亚语", ["mn"]= "蒙古语", ["na"]= "蒙古语", ["nv"]= "纳瓦霍语", ["nr"]= "南恩德贝勒语", ["nd"]= "北恩德贝勒语", ["ng"]= "恩敦加语", ["ne"]= "尼泊尔语", ["nn"]= "新挪威语", ["nb"]= "挪威布克莫尔语", ["no"]= "书面挪威语", ["ny"]= "尼扬贾语", ["oc"]= "奥克语", ["oj"]= "奥杰布瓦语", ["or"]= "奥利亚语",
        ["om"]= "奥洛莫语", ["os"]= "奥塞梯语", ["pa"]= "旁遮普语", ["fa"]= "波斯语", ["pi"]= "巴利语", ["pl"]= "波兰语", ["pt"]= "葡萄牙语", ["ps"]= "普什图语", ["qu"]= "凯楚亚语", ["rm"]= "利托-罗曼语", ["ro"]= "罗马尼亚语", ["rn"]= "基隆迪语", ["ru"]= "俄语", ["sg"]= "桑戈语", ["sa"]= "梵语", ["si"]= "僧加罗语",
        ["sk"]= "斯洛伐克语", ["sl"]= "斯洛文尼亚语", ["se"]= "北萨莫斯语", ["sm"]= "萨摩亚语", ["sn"]= "绍纳语", ["sd"]= "信德语", ["so"]= "索马里语", ["st"]= "南索托语", ["es"]= "西班牙语", ["sc"]= "撒丁语", ["sr"]= "塞尔维亚语", ["ss"]= "斯瓦特语", ["su"]= "巽他语", ["sw"]= "斯瓦希里语", ["sv"]= "瑞典语",
        ["ty"]= "塔希提语", ["ta"]= "泰米尔语", ["tt"]= "塔塔尔语", ["te"]= "泰卢固语", ["tg"]= "塔吉克语", ["tl"]= "塔加洛语", ["th"]= "泰语", ["bo"]= "藏语", ["ti"]= "提格里尼亚语", ["to"]= "汤加语", ["tn"]= "塞茨瓦纳语", ["ts"]= "宗加语", ["tk"]= "土库曼语", ["tr"]= "土耳其语", ["tw"]= "特威语", ["ug"]= "维吾尔语",
        ["uk"]= "乌克兰语", ["ur"]= "乌尔都语", ["uz"]= "乌兹别克语", ["ve"]= "文达语", ["vi"]= "越南语", ["vo"]= "沃拉普克语", ["cy"]= "威尔士语", ["wa"]= "沃伦语", ["wo"]= "沃洛夫语", ["xh"]= "科萨语", ["yi"]= "依地语", ["yo"]= "约鲁巴语", ["za"]= "壮语", ["zu"]= "祖鲁语",
        ["Unknown"]="未知", [""]="其他", ["cmn"]="普通话", ["mis"]="未识别", ["mul"]="多语言", ["und"]="未确定", ["zxx"]="无语言", ["xx"]="无语言", ["00"]="无语言",
    },
    ["region"]={
        ["AC"]= "阿森松岛", ["AD"]= "安道尔", ["AE"]= "阿拉伯联合酋长国", ["AF"]= "阿富汗", ["AG"]= "安提瓜和巴布达", ["AI"]= "安圭拉", ["AL"]= "阿尔巴尼亚", ["AM"]= "亚美尼亚", ["AN"]= "荷属安的列斯群岛", ["AO"]= "安哥拉", ["AQ"]= "南极洲", ["AR"]= "阿根廷", ["AS"]= "美属萨摩亚", ["AT"]= "奥地利", ["AU"]= "澳大利亚",
        ["AW"]= "阿鲁巴", ["AX"]= "奥兰群岛", ["AZ"]= "阿塞拜疆", ["BA"]= "波斯尼亚和黑塞哥维那", ["BB"]= "巴巴多斯", ["BD"]= "孟加拉国", ["BE"]= "比利时", ["BF"]= "布基纳法索", ["BG"]= "保加利亚", ["BH"]= "巴林", ["BI"]= "布隆迪", ["BJ"]= "贝宁", ["BL"]= "圣巴泰勒米", ["BM"]= "百慕大", ["BN"]= "文莱", ["BO"]= "玻利维亚",
        ["BQ"]= "荷兰加勒比区", ["BR"]= "巴西", ["BS"]= "巴哈马", ["BT"]= "不丹", ["BV"]= "布维特岛", ["BW"]= "博茨瓦纳", ["BY"]= "白俄罗斯", ["BZ"]= "伯利兹", ["CA"]= "加拿大", ["CC"]= "科科斯（基林）群岛", ["CD"]= "刚果（金）", ["CF"]= "中非共和国", ["CG"]= "刚果（布）", ["CH"]= "瑞士", ["CI"]= "科特迪瓦",
        ["CK"]= "库克群岛", ["CL"]= "智利", ["CM"]= "喀麦隆", ["CN"]= "中国", ["CO"]= "哥伦比亚", ["CP"]= "克利珀顿岛", ["CR"]= "哥斯达黎加", ["CU"]= "古巴", ["CV"]= "佛得角", ["CW"]= "库拉索", ["CX"]= "圣诞岛", ["CY"]= "塞浦路斯", ["CZ"]= "捷克共和国", ["DE"]= "德国", ["DG"]= "迪戈加西亚岛", ["DJ"]= "吉布提",
        ["DK"]= "丹麦", ["DM"]= "多米尼克", ["DO"]= "多米尼加共和国", ["DZ"]= "阿尔及利亚", ["EA"]= "休达及梅利利亚", ["EC"]= "厄瓜多尔", ["EE"]= "爱沙尼亚", ["EG"]= "埃及", ["EH"]= "西撒哈拉", ["ER"]= "厄立特里亚", ["ES"]= "西班牙", ["ET"]= "埃塞俄比亚", ["EU"]= "欧盟", ["FI"]= "芬兰", ["FJ"]= "斐济", ["FK"]= "马尔维纳斯群岛",
        ["FM"]= "密克罗尼西亚", ["FO"]= "法罗群岛", ["FR"]= "法国", ["GA"]= "加蓬", ["GB"]= "英国", ["GD"]= "格林纳达", ["GE"]= "格鲁吉亚", ["GF"]= "法属圭亚那", ["GG"]= "根西岛", ["GH"]= "加纳", ["GI"]= "直布罗陀", ["GL"]= "格陵兰", ["GM"]= "冈比亚", ["GN"]= "几内亚", ["GP"]= "瓜德罗普", ["GQ"]= "赤道几内亚", ["GR"]= "希腊",
        ["GS"]= "南乔治亚岛和南桑威齐群岛", ["GT"]= "危地马拉", ["GU"]= "关岛", ["GW"]= "几内亚比绍", ["GY"]= "圭亚那", ["HK"]= "中国香港特别行政区", ["HM"]= "赫德岛和麦克唐纳群岛", ["HN"]= "洪都拉斯", ["HR"]= "克罗地亚", ["HT"]= "海地", ["HU"]= "匈牙利", ["IC"]= "加纳利群岛", ["ID"]= "印度尼西亚", ["IE"]= "爱尔兰",
        ["IL"]= "以色列", ["IM"]= "曼岛", ["IN"]= "印度", ["IO"]= "英属印度洋领地", ["IQ"]= "伊拉克", ["IR"]= "伊朗", ["IS"]= "冰岛", ["IT"]= "意大利", ["JE"]= "泽西岛", ["JM"]= "牙买加", ["JO"]= "约旦", ["JP"]= "日本", ["KE"]= "肯尼亚", ["KG"]= "吉尔吉斯斯坦", ["KH"]= "柬埔寨", ["KI"]= "基里巴斯", ["KM"]= "科摩罗",
        ["KN"]= "圣基茨和尼维斯", ["KP"]= "朝鲜", ["KR"]= "韩国", ["KW"]= "科威特", ["KY"]= "开曼群岛", ["KZ"]= "哈萨克斯坦", ["LA"]= "老挝", ["LB"]= "黎巴嫩", ["LC"]= "圣卢西亚", ["LI"]= "列支敦士登", ["LK"]= "斯里兰卡", ["LR"]= "利比里亚", ["LS"]= "莱索托", ["LT"]= "立陶宛", ["LU"]= "卢森堡", ["LV"]= "拉脱维亚",
        ["LY"]= "利比亚", ["MA"]= "摩洛哥", ["MC"]= "摩纳哥", ["MD"]= "摩尔多瓦", ["ME"]= "黑山共和国", ["MF"]= "法属圣马丁", ["MG"]= "马达加斯加", ["MH"]= "马绍尔群岛", ["MK"]= "马其顿", ["ML"]= "马里", ["MM"]= "缅甸", ["MN"]= "蒙古", ["MO"]= "中国澳门特别行政区", ["MP"]= "北马里亚纳群岛", ["MQ"]= "马提尼克",
        ["MR"]= "毛里塔尼亚", ["MS"]= "蒙特塞拉特", ["MT"]= "马耳他", ["MU"]= "毛里求斯", ["MV"]= "马尔代夫", ["MW"]= "马拉维", ["MX"]= "墨西哥", ["MY"]= "马来西亚", ["MZ"]= "莫桑比克", ["NA"]= "纳米比亚", ["NC"]= "新喀里多尼亚", ["NE"]= "尼日尔", ["NF"]= "诺福克岛", ["NG"]= "尼日利亚", ["NI"]= "尼加拉瓜", ["NL"]= "荷兰",
        ["NO"]= "挪威", ["NP"]= "尼泊尔", ["NR"]= "瑙鲁", ["NU"]= "纽埃", ["NZ"]= "新西兰", ["OM"]= "阿曼", ["PA"]= "巴拿马", ["PE"]= "秘鲁", ["PF"]= "法属波利尼西亚", ["PG"]= "巴布亚新几内亚", ["PH"]= "菲律宾", ["PK"]= "巴基斯坦", ["PL"]= "波兰", ["PM"]= "圣皮埃尔和密克隆群岛", ["PN"]= "皮特凯恩群岛", ["PR"]= "波多黎各",
        ["PS"]= "巴勒斯坦", ["PT"]= "葡萄牙", ["PW"]= "帕劳", ["PY"]= "巴拉圭", ["QA"]= "卡塔尔", ["QO"]= "大洋洲外围群岛", ["RE"]= "留尼汪", ["RO"]= "罗马尼亚", ["RS"]= "塞尔维亚", ["RU"]= "俄罗斯", ["RW"]= "卢旺达", ["SA"]= "沙特阿拉伯", ["SB"]= "所罗门群岛", ["SC"]= "塞舌尔", ["SD"]= "苏丹", ["SE"]= "瑞典",
        ["SG"]= "新加坡", ["SH"]= "圣赫勒拿", ["SI"]= "斯洛文尼亚", ["SJ"]= "斯瓦尔巴特和扬马延", ["SK"]= "斯洛伐克", ["SL"]= "塞拉利昂", ["SM"]= "圣马力诺", ["SN"]= "塞内加尔", ["SO"]= "索马里", ["SR"]= "苏里南", ["SS"]= "南苏丹", ["ST"]= "圣多美和普林西比", ["SV"]= "萨尔瓦多", ["SX"]= "荷属圣马丁", ["SY"]= "叙利亚",
        ["SZ"]= "斯威士兰", ["TA"]= "特里斯坦-达库尼亚群岛", ["TC"]= "特克斯和凯科斯群岛", ["TD"]= "乍得", ["TF"]= "法属南部领地", ["TG"]= "多哥", ["TH"]= "泰国", ["TJ"]= "塔吉克斯坦", ["TK"]= "托克劳", ["TL"]= "东帝汶", ["TM"]= "土库曼斯坦", ["TN"]= "突尼斯", ["TO"]= "汤加", ["TR"]= "土耳其", ["TT"]= "特立尼达和多巴哥",
        ["TV"]= "图瓦卢", ["TW"]= "中国台湾", ["TZ"]= "坦桑尼亚", ["UA"]= "乌克兰", ["UG"]= "乌干达", ["UM"]= "美国本土外小岛屿", ["US"]= "美国", ["UY"]= "乌拉圭", ["UZ"]= "乌兹别克斯坦", ["VA"]= "梵蒂冈", ["VC"]= "圣文森特和格林纳丁斯", ["VE"]= "委内瑞拉", ["VG"]= "英属维京群岛", ["VI"]= "美属维京群岛", ["VN"]= "越南",
        ["VU"]= "瓦努阿图", ["WF"]= "瓦利斯和富图纳", ["WS"]= "萨摩亚", ["XK"]= "科索沃地区", ["YE"]= "也门", ["YT"]= "马约特", ["ZA"]= "南非", ["ZM"]= "赞比亚", ["ZW"]= "津巴布韦",
        [""]="其他", ["Unknown"]="未知", ["XX"]="未确定", ["XZ"]="国际水域", ["ZZ"]="未识别", ["International"]="国际",
    },

    -- 媒体所属的流派类型，tmdb的id编号->类型名 的对应
    ["media_genre"] = {
        [28] = "动作", [10759] = "动作冒险", [12] = "冒险", [16] = "动画",
        [35] = "喜剧", [80] = "犯罪", [99] = "纪录", [18] = "剧情",
        [10751] = "家庭", [14] = "奇幻", [36] = "历史", [27] = "恐怖", [10762] = "少儿",
        [10402] = "音乐", [9648] = "悬疑", [10763] = "新闻", [10764] = "真人", [10749] = "爱情",
        [10765] = "幻想", [878] = "科幻", [10766] = "连续剧", [10770] = "电视电影",
        [10767] = "访谈", [53] = "惊悚", [10752] = "战争", [10768] = "战争政治", [37] = "西部",
        [""]="其他", ["Unknown"]= "未知", ["Adult"]= "成人",
    },
    ["media_status"] = {
        ["Rumored"]= "传闻", ["Planned"]= "筹划",
        ["In Production"]= "开拍", ["TV In Production"]= "在摄制", ["Post Production"]= "后期制作",
        ["Pilot"]= "试播中", ["Returning Series"]= "更新中",
        ["Released"]= "已上映", ["Canceled"]="已取消", ["Ended"]="已完结",
        [""]="其他", ["Unknown"]= "未知",
    },
    ["media_type"] = {
        ["movie"]= "电影", ["tv"]= "剧集", ["Movie Video"]= "影像单篇",
        ["Scripted"]= "剧本类", ["Miniseries"]= "迷你剧类", ["Video"]= "影像合集",
        ["Reality"]= "真人节目", ["Talk Show"]="访谈节目", ["News"]= "新闻节目", ["Documentary"]= "纪录类",
        [""]= "其他", ["Unknown"]= "未知",
    },
    ["character_gsub"] = {
        {"^$","未知角色"}, {"^Self$","自己"}, {"^Voice$","配音"}, {"^Cameo$","客串"}, {"^Special Guest$","特邀嘉宾"}, {"^Guest$","嘉宾"}, {"^Host$","主持"}, {"^Contestant$","参赛"}, {"^Performer$","演出"}, {"^Judge$","评委"},
        {"Self %- ","自己 - "}, {" %(voice%)"," (配音)"}, {" %(cameo%)"," (客串)"}, {" %(special guest%)"," (特邀嘉宾)"}, {" %(guest%)"," (嘉宾)"}, {" %(host%)"," (主持)"},
        {" %- Self"," - 自己"}, {" %- Voice"," - 配音"}, {" %- Cameo"," - 客串"}, {" %- Special Guest"," - 特邀嘉宾"}, {" %- Guest"," - 嘉宾"}, {" %- Host"," - 主持"},
        {" %- Presenter"," - 主持"}, {" %- Various Characters"," - 各种角色"}, {" %- Participant"," - 参赛"}, {" %- Contestant"," - 参赛"}, {" %- Performer"," - 演出"}, {" %- Judge"," - 评委"},
    },
    ["department"] = {
        ["Acting"]= "表演", ["Actors"]= "参演", ["Art"]= "美术", ["Camera"]= "摄像", ["Costume & Make-Up"]= "服化", ["Creator"]= "创作", ["Directing"]= "执导",
        ["Editing"]= "剪辑", ["Lighting"]= "灯光", ["Production"]= "制片", ["Sound"]= "声音", ["Visual Effects"]= "视效", ["Writing"]= "剧作", ["Crew"]= "职员",
        [""]= "其他", ["Unknown"]= "未知",
    },
    ["credit_job"] = {
        ["24 Frame Playback"]= "24 帧播放", ["2D Artist"]= "2D 艺术家", ["2D Sequence Supervisor"]= "2D 序列管理", ["2D Supervisor"]= "2D 监督员", ["3D Animator"]= "3D 动画师", ["3D Artist"]= "3D 艺术家", ["3D Coordinator"]= "3D 协调员",
        ["3D Digital Colorist"]= "3D 数码调色师", ["3D Director"]= "3D 导演", ["3D Editor"]= "3D 编辑器", ["3D Generalist"]= "3D 多样化", ["3D Modeller"]= "3D 建模", ["3D Sequence Supervisor"]= "3D 序列管理", ["3D Supervisor"]= "3D 总监",
        ["3D Tracking Layout"]= "3D 追踪图层", ["ADR & Dubbing"]= "配音", ["ADR Coordinator"]= "ADR 协调", ["ADR Editor"]= "ADR 编辑", ["ADR Engineer"]= "ADR 工程师", ["ADR Mixer"]= "配音混音", ["ADR Post Producer"]= "配音后期制作",
        ["ADR Recording Engineer"]= "配音录音师", ["ADR Recordist"]= "配音录音员", ["ADR Supervisor"]= "配音指导", ["ADR Voice Casting"]= "配音演员", ["Accountant"]= "会计", ["Accounting Clerk Assistant"]= "助理会计师",
        ["Accounting Supervisor"]= "财务主管", ["Accounting Trainee"]= "会计师", ["Acting Double"]= "动作替身", ["Action Director"]= "动作导演", ["Actor"]= "演员", ["Actor's Assistant"]= "演员助理", ["Adaptation"]= "改编",
        ["Additional Camera"]= "副摄像", ["Additional Casting"]= "临时演员", ["Additional Colorist"]= "额外调色师", ["Additional Construction"]= "副建造", ["Additional Construction Grip"]= "副建造师", ["Additional Dialogue"]= "副对白",
        ["Additional Director of Photography"]= "副摄影指导", ["Additional Editing"]= "副剪辑", ["Additional Editor"]= "额外编辑人", ["Additional Editorial Assistant"]= "副剪辑助理", ["Additional Effects Development"]= "副效果部",
        ["Additional First Assistant Camera"]= "副第一摄影助理", ["Additional Gaffer"]= "额外领班", ["Additional Grip"]= "副器械工", ["Additional Hairstylist"]= "副发型师", ["Additional Key Construction Grip"]= "副器械建造师",
        ["Additional Key Grip"]= "副器械师", ["Additional Lighting Technician"]= "副灯光工", ["Additional Music"]= "副音乐", ["Additional Music Supervisor"]= "副音乐总监", ["Additional Post-Production Supervisor"]= "副制作总监",
        ["Additional Photography"]= "副摄影", ["Additional Production Assistant"]= "副制作助理", ["Additional Production Sound Mixer"]= "副制作混音师", ["Additional Script Supervisor"]= "副剧本监制", ["Additional Set Dresser"]= "临时服装师",
        ["Additional Second Assistant Camera"]= "副第二摄影助理", ["Additional Second Assistant Director"]= "第二副导演", ["Additional Soundtrack"]= "副原声", ["Additional Writing"]= "副编剧", ["Administration"]= "行政",
        ["Administrative Assistant"]= "首席助理", ["Aerial Camera"]= "航拍镜头", ["Aerial Camera Technician"]= "航拍镜头技术支持", ["Aerial Coordinator"]= "航拍协调", ["Animal Coordinator"]= "动物协调员",
        ["Aerial Director of Photography"]= "航拍摄像导演", ["Animation"]= "动画", ["Animation Coordinator"]= "动画协调", ["Animation Department Coordinator"]= "动画部协调", ["Animation Director"]= "动画导演",
        ["Animation Fix Coordinator"]= "动画修复协调", ["Animation Manager"]= "动画经理", ["Animation Production Assistant"]= "动画摄制助理", ["Animation Supervisor"]= "动画总监", ["Animation Technical Director"]= "动画技术导演",
        ["Animatronic and Prosthetic Effects"]= "电子动物和假肢特效", ["Animatronics Designer"]= "动画设计师", ["Animatronics Supervisor"]= "动画咨询师", ["Apprentice Sound Editor"]= "实习声音编辑器", ["Armorer"]= "军械员",
        ["Archival Footage Coordinator"]= "档案影像协调", ["Archival Footage Research"]= "档案影像研究", ["Armory Coordinator"]= "军械协调员", ["Art Department Assistant"]= "艺术部助理", ["Art Department Coordinator"]= "艺术部协调",
        ["Art Department Manager"]= "艺术部经理", ["Art Direction"]= "艺术指导", ["Assistant Art Director"]= "助理艺术指导", ["Assistant Costume Designer"]= "助理服装设计师", ["Assistant Director"]= "副导演",
        ["Assistant Editor"]= "助理剪辑师", ["Assistant Location Manager"]= "外景制片助理", ["Assistant Makeup Artist"]= "化妆助理", ["Assistant Music Supervisor"]= "音乐总监助理", ["Assistant Picture Editor"]= "图片编辑助理",
        ["Assistant Production Coordinator"]= "制片协调人助理", ["Assistant Production Manager"]= "制片经理助理", ["Assistant Property Master"]= "助理道具管理员", ["Assistant Script"]= "脚本助理", ["Associate Producer"]= "助理制片人",
        ["Associate Choreographer"]= "助理编导", ["Author"]= "作者", ["Background Designer"]= "布景", ["Battle Motion Coordinator"]= "动作指导", ["Best Boy Electric"]= "照明助手", ["Best Boy Electrician"]= "照明助手", ["Book"]= "原著",
        ["Boom Operator"]= "录音话筒操作员", ["CG Engineer"]= "CG 工程师", ["CG Painter"]= "CG 绘画", ["CG Supervisor"]= "CG 总监", ["CGI Supervisor"]= "CGI 总监", ["Cableman"]= "电缆员", ["Cameo"]= "浮雕", ["Camera Intern"]= "见习摄像师",
        ["Camera Department Manager"]= "摄像经理", ["Camera Operator"]= "摄像师", ["Camera Supervisor"]= "摄像总监", ["Camera Technician"]= "摄像技术员", ["Carpenter"]= "木工", ["Casting"]= "选角", ["Casting Associate"]= "演员部助理",
        ["Character Technical Supervisor"]= "角色技术总监", ["Characters"]= "角色", ["Chef"]= "厨师", ["Chief Technician / Stop-Motion Expert"]= "主任技师 / 定格动画专家", ["Choreographer"]= "编舞", ["Cinematography"]= "摄影",
        ["Cloth Setup"]= "服装设定", ["Co-Art Director"]= "联合艺术总监", ["Co-Costume Designer"]= "联合服装设计", ["Co-Executive Producer"]= "联合执行制片人", ["Co-Producer"]= "联合制片人", ["Co-Writer"]= "联合编剧",
        ["Color Designer"]= "色彩师", ["Color Timer"]= "配光员", ["Comic Book"]= "漫画书", ["Commissioning Editor"]= "组稿编辑", ["Compositor"]= "合成", ["Conceptual Design"]= "概念设计", ["Construction Coordinator"]= "建筑协调",
        ["Construction Foreman"]= "建筑工头", ["Consulting Producer"]= "制片顾问", ["Costume Design"]= "服装设计", ["Costume Supervisor"]= "服装总监", ["Craft Service"]= "膳食服务", ["Creative Consultant"]= "创意顾问",
        ["Creative Producer"]= "创意制作", ["Creator"]= "创作人", ["Creature Design"]= "生物设计", ["Department Administrator"]= "部门主管", ["Development Manager"]= "部门经理", ["Dialect Coach"]= "方言教练", ["Dialogue"]= "对白",
        ["Dialogue Editor"]= "对白编辑", ["Digital Compositor"]= "数字合成", ["Digital Effects Supervisor"]= "数字效果总监", ["Digital Intermediate"]= "数字中间片", ["Directing Lighting Artist"]= "照明艺术指导",
        ["Digital Producer"]= "数字制作", ["Director"]= "导演", ["Director of Photography"]= "摄影指导", ["Documentation & Support"]= "文稿支持", ["Dolby Consultant"]= "杜比顾问", ["Dramaturgy"]= "剧作理论", ["Driver"]= "司机",
        ["Editor"]= "剪辑", ["Editorial Coordinator"]= "剪辑协调", ["Editorial Manager"]= "编辑经理", ["Editorial Production Assistant"]= "剪辑制作助理", ["Editorial Services"]= "剪辑服务", ["Editorial Staff"]= "剪辑人员",
        ["Electrician"]= "电工", ["Executive Consultant"]= "执行顾问", ["Executive In Charge Of Post Production"]= "执行后期制作主管", ["Executive In Charge Of Production"]= "执行制片主管", ["Executive Music Producer"]= "执行音乐制作",
        ["Executive Producer"]= "执行制片人", ["Executive Visual Effects Producer"]= "执行视效制作", ["Executive in Charge of Finance"]= "执行财务主管", ["Facial Setup Artist"]= "面妆艺术", ["First Assistant Camera"]= "第一助理摄像",
        ["Finance"]= "财政", ["First Assistant Editor"]= "第一助理剪辑", ["First Assistant Sound Editor"]= "第一助理音响编辑", ["Fix Animator"]= "固定动画师", ["Foley"]= "特殊音效", ["Graphic Novel Illustrator"]= "图文小说插画",
        ["Gaffer"]= "电工", ["Greensman"]= "植物道具员", ["Grip"]= "场务", ["Gun Wrangler"]= "枪支管理", ["Hair Department Head"]= "发型部主管", ["Hair Designer"]= "发型设计师", ["Hair Setup"]= "发型设置", ["Hairstylist"]= "发型师",
        ["Helicopter Camera"]= "直升机摄像", ["I/O Manager"]= "I/O 经理", ["I/O Supervisor"]= "I/O 总监", ["Idea"]= "创意", ["Imaging Science"]= "影像科学", ["Information Systems Manager"]= "信息系统经理", ["Interior Designer"]= "室内设计",
        ["Key Hair Stylist"]= "关键发型师", ["Keyboard Programmer"]= "键盘程序员", ["Layout"]= "布局", ["Lead Painter"]= "画家长", ["Leadman"]= "工长", ["Legal Services"]= "法律服务", ["Lighting Artist"]= "灯光艺术", ["Lighting Camera"]= "灯光摄影",
        ["Lighting Coordinator"]= "灯光协调", ["Lighting Manager"]= "灯光经理", ["Lighting Production Assistant"]= "灯光制作助理", ["Lighting Supervisor"]= "灯光总监", ["Lighting Technician"]= "灯光师", ["Line Producer"]= "现场制片人",
        ["Loader"]= "搬运工", ["Location Manager"]= "场地管理经理", ["Location Scout"]= "场地寻找", ["Machinist"]= "机械师", ["Makeup Artist"]= "化妆师", ["Makeup Department Head"]= "化妆部主管", ["Makeup Designer"]= "化妆设计",
        ["Makeup Effects"]= "化妆效果", ["Manager of Operations"]= "运营经理", ["Martial Arts Choreographer"]= "武术指导", ["Master Lighting Artist"]= "主灯光师", ["Mechanical & Creature Designer"]= "机械与生物设计师",
        ["Mix Technician"]= "混音技术员", ["Mixing Engineer"]= "混音师", ["Modeling"]= "模型", ["Motion Actor"]= "动作演员", ["Motion Capture Artist"]= "动作捕捉师", ["Music"]= "音乐", ["Music Director"]= "音乐指导",
        ["Music Editor"]= "音乐编辑", ["Music Supervisor"]= "音乐总监", ["Musical"]= "音乐", ["Novel"]= "小说", ["Opera"]= "歌剧", ["Orchestrator"]= "配器师", ["Original Music Composer"]= "原创音乐作曲", ["Original Story"]= "原创小说",
        ["Other"]= "其他", ["Painter"]= "画家", ["Photoscience Manager"]= "Photoscience 经理", ["Picture Car Coordinator"]= "车辆场景协调员", ["Post Production Assistant"]= "后期制作助理", ["Post Production Consulting"]= "后期制作顾问",
        ["Poem"]= "诗歌", ["Post Production Supervisor"]= "后期制作总监", ["Post-Production Manager"]= "后期制作经理", ["Producer"]= "制片人", ["Production Accountant"]= "制片助理", ["Production Artist"]= "制片艺术",
        ["Production Controller"]= "制片控制", ["Production Coordinator"]= "制片协调", ["Production Design"]= "制片设计", ["Production Director"]= "制片指导", ["Production Illustrator"]= "插画制作", ["Production Intern"]= "见习制片人",
        ["Production Manager"]= "制片主任", ["Production Office Assistant"]= "制片办公室助理", ["Production Office Coordinator"]= "制片办公室协调人", ["Production Sound Mixer"]= "现场混音师", ["Production Supervisor"]= "制片总监",
        ["Projection"]= "投影", ["Prop Maker"]= "道具制作", ["Property Master"]= "道具管理员", ["Propmaker"]= "道具制作", ["Prosthetic Supervisor"]= "假肢总监", ["Public Relations"]= "公共关系", ["Publicist"]= "公关",
        ["Pyrotechnic Supervisor"]= "烟火总监", ["Quality Control Supervisor"]= "质量控制总监", ["Radio Play"]= "广播剧", ["Recording Supervision"]= "录像总监", ["Researcher"]= "研究员", ["Rigging Gaffer"]= "吊具领班",
        ["Rigging Grip"]= "吊具场务", ["Scenario Writer"]= "剧作家", ["Scenic Artist"]= "布景工", ["Schedule Coordinator"]= "计划协调员", ["Score Engineer"]= "配乐师", ["Scoring Mixer"]= "配乐录音师", ["Screenplay"]= "剧本",
        ["Screenstory"]= "情节策划", ["Script"]= "剧本", ["Script Coordinator"]= "剧本协调", ["Script Editor"]= "剧本编辑", ["Script Supervisor"]= "剧本指导", ["Sculptor"]= "雕塑", ["Second Film Editor"]= "第二剪辑", ["Seamstress"]= "裁缝",
        ["Second Unit"]= "第二剧组", ["Second Unit Cinematographer"]= "第二剧组摄影师", ["Security"]= "安全", ["Senior Executive Consultant"]= "高级执行顾问", ["Sequence Artist"]= "序列艺术家", ["Sequence Lead"]= "序列指挥",
        ["Sequence Supervisor"]= "序列指导", ["Series Composition"]= "剧集构思", ["Series Director"]= "剧集导演", ["Series Writer"]= "剧集编剧", ["Set Costumer"]= "布景供应", ["Set Decoration"]= "布景装饰", ["Set Decoration Buyer"]= "布景装饰采购",
        ["Set Designer"]= "布景设计", ["Set Dressing Artist"]= "布景艺术", ["Set Dressing Manager"]= "布景经理", ["Set Dressing Production Assistant"]= "布景制作助理", ["Set Dressing Supervisor"]= "布景总监", ["Set Medic"]= "医疗组",
        ["Set Production Assistant"]= "布景师助理", ["Set Production Intern"]= "见习布景师", ["Sets & Props Artist"]= "布景及道具艺术", ["Sets & Props Supervisor"]= "布景及道具总监", ["Settings"]= "设置", ["Shading"]= "着色处理",
        ["Shoe Design"]= "鞋设计", ["Short Story"]= "短篇小说", ["Sign Painter"]= "签约画家", ["Simulation & Effects Artist"]= "模拟和效果师", ["Simulation & Effects Production Assistant"]= "模拟和效果制作助理", ["Software Engineer"]= "软件工程师",
        ["Software Team Lead"]= "软件团队主管", ["Songs"]= "歌曲", ["Sound"]= "声音", ["Sound Design Assistant"]= "声音设计助理", ["Sound Designer"]= "声音设计", ["Sound Director"]= "声音指导", ["Sound Editor"]= "声音编辑",
        ["Sound Engineer"]= "声响师", ["Sound Effects Editor"]= "音效编辑", ["Sound Mixer"]= "调音", ["Sound Montage Associate"]= "声音蒙太奇助理", ["Sound Re-Recording Mixer"]= "声音混录师", ["Sound Recordist"]= "录音师",
        ["Special Effects Coordinator"]= "特效协调", ["Special Effects"]= "特效", ["Special Effects Supervisor"]= "特效总监", ["Special Guest"]= "特邀嘉宾", ["Special Guest Director"]= "特邀指导", ["Special Sound Effects"]= "特殊音效",
        ["Stand In"]= "支援", ["Standby Painter"]= "待机画家", ["Steadicam Operator"]= "摄影稳定操作", ["Steadycam"]= "摄影稳定装置", ["Still Photographer"]= "静态摄像师", ["Story"]= "故事", ["Storyboard"]= "分镜", ["Studio Teacher"]= "片厂教师",
        ["Stunt Coordinator"]= "特技协调", ["Stunts"]= "特技", ["Stunt Double"]= "特技替身", ["Stunts Coordinator"]= "特技协调", ["Supervising Animator"]= "动画总监", ["Supervising Art Director"]= "艺术指导总监", ["Supervising Producer"]= "监制",
        ["Supervising Film Editor"]= "影片剪辑总监", ["Supervising Sound Editor"]= "声音编辑总监", ["Supervising Sound Effects Editor"]= "音效编辑总监", ["Supervising Technical Director"]= "技术指导总监", ["Supervisor of Production Resources"]= "制片资源主管",
        ["Systems Administrators & Support"]= "系统管理员及支持", ["Tattooist"]= "纹身", ["Technical Supervisor"]= "技术总监", ["Telecine Colorist"]= "胶转磁调色师", ["Teleplay"]= "电视剧剧本", ["Temp Music Editor"]= "临时音乐编辑",
        ["Temp Sound Editor"]= "临时声音编辑", ["Thanks"]= "感谢", ["Theatre Play"]= "剧院播放", ["Title Graphics"]= "标题图形", ["Translator"]= "翻译", ["Transportation Captain"]= "运输队长", ["Transportation Co-Captain"]= "运输联合队长",
        ["Transportation Coordinator"]= "运输协调员", ["Treatment"]= "文学脚本", ["Underwater Camera"]= "水下摄像", ["Unit Manager"]= "剧组经理", ["Unit Production Manager"]= "剧组制片主任", ["Unit Publicist"]= "剧组公关",
        ["Utility Stunts"]= "剧组特技", ["VFX Artist"]= "VFX 艺术", ["VFX Editor"]= "VFX 编辑", ["VFX Production Coordinator"]= "VFX 制作协调", ["VFX Supervisor"]= "VFX 总监", ["Video Assist Operator"]= "录像辅助操作员",
        ["Video Game"]= "电子游戏", ["Visual Development"]= "视觉部", ["Visual Effects"]= "视觉效果", ["Visual Effects Art Director"]= "视觉效果艺术指导", ["Visual Effects Coordinator"]= "视觉效果协调", ["Visual Effects Editor"]= "视觉效果编辑",
        ["Visual Effects Design Consultant"]= "视觉效果设计顾问", ["Visual Effects Producer"]= "视效制作", ["Visual Effects Supervisor"]= "视觉效果总监", ["Vocal Coach"]= "声乐教练", ["Voice"]= "语音", ["Wigmaker"]= "假发制作", ["Writer"]= "编剧",
        ["Character Designer"]= "角色设计", ["Original Concept"]= "原始概念", ["Original Series Design"]= "原始系列设计", ["Key Animation"]= "原画", ["Special Effects Makeup Artist"]= "特效化妆师", ["Storyboard Artist"]= "分镜师", ["Art Designer"]= "美术设计",
        ["Production Executive"]= "制片主管", ["Casting Director"]= "选角导演", ["Casting Consultant"]= "选角顾问", ["First Assistant Director"]= "第一副导演", ["Staff Writer"]= "特约编剧", ["Second Unit Director"]= "第二组导演", ["Floor Runner"]= "场地管理",
        ["Theme Song Performance"]= "主题曲演唱", ["Music Producer"]= "音乐制作人", ["Foley Editor"]= "拟音编辑", ["Foley Artist"]= "拟音师", ["Sound Effects"]= "音效", ["In Memory Of"]= "以纪念", ["Assistant Director of Photography"]= "摄影副导演",
        ["Additional Storyboarding"]= "副分镜", ["Key Costumer"]= "关键服饰师",
        [""]= "其他", ["Unknown"]= "未知",
    },
    ["media_type_epgroup"] = { [1]= "原播出版", [2]= "绝对数版", [3]= "光盘版", [4]= "数字版", [5]= "故事线版", [6]= "制作版", [7]= "电视版", [""]= "其他", ["Unknown"]= "未知", },
}

--[[
-- 媒体信息<table>
Anime_data = {
    ["media_title"] = (mediai["media_title"]) or (mediai["media_name"]),        -- 标题
    ["interf_title"],
    ["original_title"] = (mediai["original_title"]) or (mediai["original_name"]),-- 原始语言标题
    ["media_id"] = tostring(mediai["id"]),          -- 媒体的 tmdb id
    ["media_imdbid"]            -- str:  ^tt[0-9]{7}$
    ["media_type"] = mediai["media_type"],          -- 媒体类型 movie tv person
    ["genre_ids"] = mediai["genre_ids"],            -- 流派类型的编号 table/Array
    ["genre_names"],            -- 流派类型 table/Array
    ["keyword_names"]
    ["release_date"] = mediai["release_date"] or mediai["air_date"] or mediai["first_air_date"], -- 首映/本季首播/发行日期
    ["overview"] = mediai["overview"],              -- 剧情梗概 str
    ["overview_season"]
    ["overview_epgroup"]
    ["tagline"]                 -- str
    ["vote_average"] = mediai["vote_average"],      -- 平均tmdb评分 num
    ["vote_count"]              -- 评分人数 num
    ["content_rating"]
    ["rate_mpaa"],              -- MPAA分级 str
    ["homepage_path"]           --主页网址 str
    ["status"]                  -- 发行状态 str
    ["popularity_num"]          -- 流行度 num
    ["runtime"]                 -- {num}
    ["imdb_id"]
    ["facebook_id"]
    ["instagram_id"]
    ["twitter_id"]
    ["tvdb_id"]

    ["original_language"] = mediai["original_language"], -- 原始语言 "en"
    ["spoken_language"]         -- {str:iso_639_1, str:name}
    ["tv_language"]            -- tv {"en"}
    ["origin_region"]       -- tv 原始首播国家地区 {"US"}
    ["production_region"]      -- {str:iso_3166_1, str:name}
    ["production_company"],     -- 出品公司 - {num:id, str:logo_path, str:name, str:origin_region}
    ["tv_network"],         -- 播映剧集的电视网 - {...}
    --["person_staff"],         -- "job1:name1;job2;name2;..."
    --["tv_creator"]              -- {num:id, str:credit_id, str:name, 1/2:gender, str:profile_path}
    ["person_crew"]
    --["person_character"],     -- { ["name"]=string,   --人物名称 ["actor"]=string,  --演员名称 ["link"]=string,   --人物资料页URL  ["imgurl"]=string --人物图片URL }
    ["person_cast"]

    ["mo_is_adult"]             -- bool
    ["mo_is_video"]             -- bool
    ["mo_belongs_to_collection"]-- {}
    ["mo_budget"]               -- 预算 num
    ["mo_revenue"]              -- 收入 num

    ["season_count"],           -- 剧集的 总季数 num - 含 S00/Specials/特别篇/S05/Season 5/第 5 季
    ["season_number"],          -- 本季的 季序数 /第几季 num - 0-specials
    ["season_title"],           -- 本季的 季名称 str - "季 2" "Season 2" "Specials"
    ["episode_count"],          -- 本季的 总集数 num
    ["episode_total"],          -- 剧集所有季的 总集数 num
    ["tv_first_air_date"] = ["first_air_date"],     -- 剧集首播/发行日期 str
    ["tv_in_production"]        -- bool
    ["tv_last_air_date"]        -- str
    ["tv_last_episode_to_air"]  -- {num:episode_number, int:season_number, int:id, str:name, str:overview,
                                 str:air_date, str:production_code, str/nil:still_path, num:vote_average, int:vote_count}
    ["tv_next_episode_to_air"]  -- null or {...}
    ["tv_type"]                 -- str
    ["tv_is_epgroup"]
    ["tv_epgroup_id"]
    ["epgroup_title"]
    ["overview_epgroup"]
    ["season_count_eg"]
    ["episode_total_eg"]
    ["epgroup_type"]

    -- Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. data["image_path"]
    ["tmdb_art_path"]= { [tmdb_type] = { [origin]={url,lang}, [interf]={}, },} -- movieposter tvposter seasonposter moviebackground tvbackground
    ["fanart_path"] ={ [fanart_type] = { [origin]={url,lang,disc_type,season}, [interf]={}, },} -- seasonX:"0"/all/others
    --
}]] --

---------------------
-- 资料脚本部分
-- copy (as template) from & thanks to "../library/bangumi.lua", "../danmu/bilibili.lua" in "KikoPlay/library"|KikoPlayScript
--

-- 完成搜索功能
-- keyword： string，搜索关键字
-- 返回：Array[AnimeLite]
function search(keyword,options)
    local settings_search_type=""
    if(options["search_type"] ~= "movie" and options["search_type"] ~= "tv") then
        settings_search_type="multi"
    else settings_search_type=options["search_type"]
    end
    local mediais={}
    if options["search_keyword_process"] =="0" then options["search_keyword_process"]="plain"
    elseif options["search_keyword_process"] =="1" then options["search_keyword_process"]="filename"
    end
    if options["search_type"] =="电影/剧集" then options["search_type"]="multi"
    elseif options["search_type"] =="电影" then options["search_type"]="movie"
    elseif options["search_type"] =="剧集" then options["search_type"]="tv"
    end

    if options["search_keyword_process"]=="plain" then
        if options["search_keyword_astitle"] =="0" then
            mediais= searchMediaInfo(keyword,options,settings_search_type)
        elseif options["search_keyword_astitle"] =="1" then
            mediais= searchMediaInfo(keyword,options,settings_search_type,keyword)
        end
    elseif true or options["search_keyword_process"]=="filename" then
        local mType = "multi"
        local mTitle,mSeason,mEp,mEpX,mTitleX,mEpType = "","","","","",""
        local resMirbf= Path.getMediaInfoRawByFilename(keyword..".mkv")
        mTitle=resMirbf[1] or ""
        mSeason=resMirbf[2] or ""
        mEp=resMirbf[3] or ""
        mEpX=resMirbf[4] or ""
        mTitleX=resMirbf[5] or ""
        mEpType=resMirbf[6] or ""
        local mIsSp=false -- 是否为特别篇
        if mEpType~="" and mEpType~="EP" then
            mIsSp=true
        end
        if mEp~="" or mSeason~="" then
            mType="tv"
        else
            mType="multi"
        end

        local resultSearch
        if options["search_keyword_astitle"] =="0" then
            resultSearch= searchMediaInfo(mTitle,options,
                ((settings_search_type=="multi")and{mType}or{settings_search_type})[1])
        elseif options["search_keyword_astitle"] =="1" then
            resultSearch= searchMediaInfo(mTitle,options,
                ((settings_search_type=="multi")and{mType}or{settings_search_type})[1],keyword)
        end
        local mSeasonTv = ""
        local tmpsSearchlSeasonall= options["search_list_season_all"]
        for _, value in ipairs(resultSearch or {}) do
            if mSeason =="" and value["media_type"] == "movie" then
                table.insert(mediais, value)
                goto continue_search_KMul_Mnfo
            elseif value["media_type"]=="tv" then
                if mSeason == "" then
                    if tmpsSearchlSeasonall=="0" then
                        mSeasonTv = ((mIsSp)and{0}or{1})[1]
                    elseif true or tmpsSearchlSeasonall=="1" then
                    end
                else mSeasonTv = math.floor(tonumber(mSeason))
                end
                if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                        table.insert(mediais, value)
                    goto continue_search_KMul_Mnfo
                elseif value["season_number"] == 0 or tostring(value["season_number"]) == tostring(0) or
                        value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) or
                        (string.isEmpty(mSeasonTv)) then
                    table.insert(mediais, value)
                    goto continue_search_KMul_Mnfo
                else
                    goto continue_search_KMul_Mnfo
                end
            end
            ::continue_search_KMul_Mnfo::--continue_match_OMul_Mnfo
        end
    end

    return mediais
end
function searchMediaInfo(keyword, options, settings_search_type, old_title)
    -- kiko.log("[INFO]  Searching <" .. keyword .. "> in " .. settings_search_type)
    -- 获取 是否 元数据使用原语言标题
    options = options or {}
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    -- http get 请求 参数
    local query = {
        ["api_key"] = settings["api_key"],
        ["language"] = settings["metadata_lang"],
        ["query"] = string.gsub(keyword,"/\\%?"," "),
        ["page"] = Metadata_search_page,
        ["include_adult"] = Metadata_search_adult
    }
    local header = {["Accept"] = "application/json"}
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的 TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    -- 获取 http get 请求 - 查询特定媒体类型 特定关键字 媒体信息的 搜索结果列表
    if(settings_search_type ~= "movie" and settings_search_type ~= "tv") then
        settings_search_type="multi"
    end
    -- tmdb_search_multi
    local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/search/" .. settings_search_type),
        query, header)
    if err ~= nil or (reply or{}).hasError then
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..".httpget: "..err..
                (((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1])
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err..(((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1])
    end
    --[[if reply["success"]=="false" or reply["success"]==false then
        err = reply["status_message"]
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..": ".. err)
        error(err)
    end    ]]--
    -- json:reply -> Table:obj 获取的结果
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..".json2table: ".. err)
        error(err)
    end
    -- Table:obj["results"] 搜索结果<table> -> Array:mediai
    local mediais = {}
    for _, mediai in pairs(obj['results'] or {}) do
        if (mediai["media_type"] ~= 'tv' and mediai["media_type"] ~= 'movie' and settings_search_type == "multi") then
            -- 跳过对 演员 的搜索 - 跳过 person
            goto continue_search_a
        end
        -- 显示的媒体标题 title/name
        local mediaName
        if (Metadata_info_origin_title) then
            mediaName = string.unescape(mediai["original_title"] or mediai["original_name"])
        else
            mediaName = string.unescape(mediai["title"] or mediai["name"])
        end
        -- local extra = {}
        local data = {} -- 媒体信息
        -- 媒体类型
        if settings_search_type == "multi" then
            data["media_type"] = mediai["media_type"] -- 媒体类型 movie tv person
        elseif settings_search_type == "movie" then
            data["media_type"] = "movie"
        elseif settings_search_type == "tv" then
            data["media_type"] = "tv"
        else
            data["media_type"] = mediai["media_type"] -- 媒体类型 movie tv person
        end
        data["media_title"] = string.unescape(mediai["title"]) or string.unescape(mediai["name"]) -- 标题
        data.interf_title = string.unescape(mediai["title"]) or string.unescape(mediai["name"]) -- 标题
        data["original_title"] = string.unescape(mediai["original_title"]) or string.unescape(mediai["original_name"]) -- 原始语言标题
        data["media_id"] = string.format("%d", mediai["id"]) -- 媒体的 tmdb id
        data["release_date"] = mediai["release_date"] or mediai["first_air_date"] -- 首映/首播/发行日期
        data["original_language"] = mediai["original_language"] -- 原始语言
        data["origin_region"] = table.deepCopy(mediai["origin_country"]) or{} -- 原始首映/首播国家地区
        if not string.isEmpty(mediai.overview) and mediai.overview~=mediai.title and mediai.overview~=mediai.original_title then
            data["overview"] = (string.isEmpty(mediai.overview) and{""} or{ string.gsub(mediai["overview"], "\r?\n\r?\n", "\n") })[1] -- 剧情梗概
        end
        data["vote_average"] = mediai["vote_average"] -- 平均tmdb评分
        -- 图片链接
        local tmpTmdbartImgpath= nil
        if not string.isEmpty(mediai.poster_path) then
            tmpTmdbartImgpath=(table.isEmpty(tmpTmdbartImgpath) and{ {} }or{ tmpTmdbartImgpath })[1]
            tmpTmdbartImgpath[data.media_type.."poster"]={}
            tmpTmdbartImgpath[data.media_type.."poster"].interf= {
                ["url"]= mediai.poster_path,
                ["lang"]= "und", --string.sub(settings["metadata_lang"],1,2),
            }
        end
        if not string.isEmpty(mediai.backdrop_path) then
            tmpTmdbartImgpath=(table.isEmpty(tmpTmdbartImgpath) and{ {} }or{ tmpTmdbartImgpath })[1]
            tmpTmdbartImgpath[data.media_type.."background"]={}
            tmpTmdbartImgpath[data.media_type.."background"].interf= {
                ["url"]= mediai.backdrop_path,
                ["lang"]= "und",
            }
        end
        data.tmdb_art_path = (table.isEmpty(tmpTmdbartImgpath) and{ nil }or{ tmpTmdbartImgpath })[1]
        --? OTHER_INFO
        -- data["vote_count"] = tonumber(mediai["vote_count"]or"")
        -- data["popularity_num"] = tonumber(mediai["popularity"]or"")
        data["mo_is_adult"]= (( mediai["adult"]==nil or mediai["adult"]=="" )and{ nil }or{ tostring(mediai["adult"])=="true" })[1]
        data["mo_is_video"]= (( mediai["video"]==nil or mediai["video"]=="" )and{ nil }or{ tostring(mediai["video"])=="true" })[1]

        data.update_info= {}
        data.update_info.version= info.version
        data.update_info.timestamp= os.time()
        data.update_info.level_detail= "scrape"

        -- season_number, episode_count,
        if data["media_type"] == "movie" then
            -- movie - 此条搜索结果是电影
            -- 把电影视为单集电视剧
            data["season_number"] = 1
            data["episode_count"] = 1
            data["season_count"] = 1
            data["episode_total"] = 1
            data["season_title"] = data["original_title"]

            local queryMo = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            -- info
            local objMo= Kikoplus.httpgetMediaId(queryMo,data["media_type"].."/"..data["media_id"])
            
            --? OTHER_INFO m&t of mo
            -- genre_ids -> genre_names
            data["genre_names"] = {} -- 流派类型 table/Array
            -- 流派类型 id ->名称
            for key, value in pairs(mediai["genres"] or {}) do -- key-index value-id
                if not string.isEmpty(value.name) then
                    table.insert(data["genre_names"],((Translation[settings["metadata_lang"]] or{}).media_genre or{})[value.id] or value.name)
                end
            end
            data["runtime"] = ( objMo["runtime"]==nil or objMo["runtime"]=="" )and{ nil }or{ tostring(objMo["runtime"]) }
            data["homepage_path"]= (( objMo["homepage"]==nil or objMo["homepage"]=="" )and{ nil }or{ objMo["homepage"] })[1]
            for index, value in ipairs(objMo["production_companies"] or {}) do
                data["production_company"]=data["production_company"]or{}
                table.insert(data["production_company"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_region"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            for index, value in ipairs(objMo["production_countries"] or {}) do
                data["production_region"]=data["production_region"]or {}
                table.insert(data["production_region"],{
                    ["iso_3166_1"]= (( value["iso_3166_1"]==nil or value["iso_3166_1"]=="" )and{ nil }or{ value["iso_3166_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                })
            end
            for index, value in ipairs(objMo["spoken_languages"] or {}) do
                data["spoken_language"]=data["spoken_language"]or {}
                if not string.isEmpty(value.iso_639_1) then
                    table.insert(data["spoken_language"],{
                        ["iso_639_1"]= (( value["iso_639_1"]==nil or value["iso_639_1"]=="" )and{ nil }or{ value["iso_639_1"] })[1],
                        -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                        -- ["english_name"]= (( value["english_name"]==nil or value["english_name"]=="" )and{ nil }or{ value["english_name"] })[1],
                    })
                end
            end
            if string.isEmpty(data.original_language) then
                data.original_language = ((data.spoken_language or{})[1] or{}).iso_639_1
            end
            data.status= ( string.isEmpty(objMo.status) and{ "Unknown" }or{ objMo.status })[1]
            --? OTHER_INFO mo
            data["mo_belongs_to_collection"] = table.deepCopy(objMo["belongs_to_collection"]) or{}
            data["mo_budget"] = tonumber(objMo["budget"]or"")
            data["media_imdbid"]= (( objMo["imdb_id"]==nil or objMo["imdb_id"]=="" )and{ nil }or{ objMo["imdb_id"] })[1]
            data["mo_revenue"] = tonumber(objMo["revenue"]or"")

            objMo.tagline= string.gsub(objMo.tagline or"", "[\n\r]", "")
            if string.isEmpty(objMo.tagline) or objMo.tagline==objMo.title or objMo.tagline==objMo.original_title then
                data.tagline= nil
            elseif true then
                data.tagline= string.gsub(objMo.tagline or"", "[\n\r]", "")
            end
            
            local media_data_json
            -- 把媒体信息<table>转为json的字符串
            err, media_data_json = kiko.table2json(table.deepCopy(data) or{})
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, table.toStringBlock(data)));

            -- get "Movie Name (YYYY)"
            if data["release_date"] ~= nil and data["release_date"] ~= "" then
                mediaName = mediaName .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
            end
            local mediaLang={data["original_language"]}
            Array.extendUnique(mediaLang,data["spoken_language"],"iso_639_1")
            Array.extendUnique(mediaLang,data["tv_language"])
            local mediaRegion=table.deepCopy(data["origin_region"]) or{}
            Array.extendUnique(mediaRegion,data["production_region"],"iso_3166_1")
            mediaLang={mediaLang[1] or nil}
            mediaRegion={mediaRegion[1] or nil}
            for index, value in ipairs(mediaLang) do
                mediaLang[index]= ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value
            end
            for index, value in ipairs(mediaRegion) do
                mediaRegion[index]= ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value
            end

            table.insert(mediais, {
                ["name"] = (( string.isEmpty(old_title) )and{ mediaName }or{ old_title })[1],
                ["data"] = media_data_json,
                ["extra"] = "类型：" .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[data.media_type] or data.media_type or (Translation["und-XX"]).media_type["Unknown"] or"") ..
                        ((data.mo_is_video==true or data.mo_is_video=="true") and{ ", ".. (((Translation[settings["metadata_lang"]] or{}).media_type or{})["Movie Video"] or"Video Movie") }or{ "" })[1] ..
                    "  |  首映：" .. ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) ..
                        "  |  语言：" .. Array.toStringLine(mediaLang) .. "; " .. Array.toStringLine(mediaRegion) ..
                    "  |  状态：" .. (((Translation[settings["metadata_lang"]] or{}).media_status or{})[data.status] or data.status or (Translation["und-XX"] or{}).media_status["Unknown"] or "") ..
                    "\r\n简介：" .. string.gsub(data.overview or"", "\r?\n", " ")..
                    (( string.isEmpty(old_title) )and{ "" }or{ "\r\n弃用的标题：" ..mediaName })[1],
                ["scriptId"] = "Kikyou.l.TMDb",
                ["media_type"] = data["media_type"],
            })
        elseif data["media_type"] == "tv" then
            -- tv
            local queryTv = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"],
                ["append_to_response"] = ((options["search_list_season_epgroup"]=="1") and{"episode_groups"}or{""})[1],
            }
            local objTv=Kikoplus.httpgetMediaId(queryTv,data["media_type"] .. "/" .. data["media_id"])
            -- info
            
            data["tv_first_air_date"] = data["release_date"]
            data["season_count"] = objTv["number_of_seasons"]
            data["episode_total"] = objTv["number_of_episodes"]
            if tonumber(data.season_count) then
                data.season_count= math.floor(tonumber(data.season_count))
            end
            if tonumber(data.episode_total) then
                data.episode_total= math.floor(tonumber(data.episode_total))
            end

            --? OTHER_INFO m&t of tv
            -- genre_ids -> genre_names
            data["genre_names"] = {} -- 流派类型 table/Array
            -- 流派类型 id ->名称
            for key, value in pairs(mediai["genres"] or {}) do -- key-index value-id
                if not string.isEmpty(value.name) then
                    table.insert(data["genre_names"],((Translation[settings["metadata_lang"]] or{}).media_genre or{})[value.id] or value.name)
                end
            end
            data["runtime"] = table.deepCopy(objTv["episode_run_time"]) or{}
            data["homepage_path"]= (( objTv["homepage"]==nil or objTv["homepage"]=="" )and{ nil }or{ objTv["homepage"] })[1]
            for index, value in ipairs(objTv["production_companies"] or {}) do
                data["production_company"]=data["production_company"] or {}
                table.insert(data["production_company"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_region"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            for index, value in ipairs(objTv["production_countries"] or {}) do
                data["production_region"]=data["production_region"] or {}
                table.insert(data["production_region"],{
                    ["iso_3166_1"]= (( value["iso_3166_1"]==nil or value["iso_3166_1"]=="" )and{ nil }or{ value["iso_3166_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                })
            end
            for index, value in ipairs(objTv["spoken_languages"] or {}) do
                data["spoken_language"]=data["spoken_language"] or {}
                table.insert(data["spoken_language"],{
                    ["iso_639_1"]= (( value["iso_639_1"]==nil or value["iso_639_1"]=="" )and{ nil }or{ value["iso_639_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    -- ["english_name"]= (( value["english_name"]==nil or value["english_name"]=="" )and{ nil }or{ value["english_name"] })[1],
                })
            end
            data.status= ( string.isEmpty(objTv.status) and{ "Unknown" }or{ objTv.status })[1]
            --? OTHER_INFO tv
            for _, value in ipairs(objTv["created_by"] or {}) do
                data["person_crew"]=data["person_crew"] or {}
                table.insert(data["person_crew"],{
                    -- ["gender"]= (( tonumber(value["gender"])==1 or tonumber(value["gender"])==2 )and{ tonumber(value["gender"]) }or{ nil })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["original_name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["profile_path"]= (( value["profile_path"]==nil or value["profile_path"]=="" )and{ nil }or{ value["profile_path"] })[1],
                    ["department"]= "Writing",
                    ["job"]={"Creator"},
                
                    ["id"] = tonumber(value["id"]or""),
                    -- ["credit_id"]= (( value["credit_id"]==nil or value["credit_id"]=="" )and{ nil }or{ value["credit_id"] })[1],
                })
            end
            data["tv_in_production"]= (( objTv["in_production"]==nil or objTv["in_production"]=="" )and{ nil }or{ tostring(objTv["in_production"])=="true" })[1]
            data["tv_language"] = table.deepCopy(objTv["languages"]) or{}
            data["tv_last_air_date"]= (( objTv["last_air_date"]==nil or objTv["last_air_date"]=="" )and{ nil }or{ objTv["last_air_date"] })[1]
            -- data["tv_last_episode_to_air"] = table.deepCopy(objTv["last_episode_to_air"]) or{}
            -- data["tv_next_episode_to_air"]= table.deepCopy(objTv["next_episode_to_air"]) or{}
            for index, value in ipairs(objTv["networks"] or {}) do
                data["tv_network"]=data["tv_network"] or {}
                table.insert(data["tv_network"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_region"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            data["tv_type"]= (( objTv["type"]==nil or objTv["type"]=="" )and{ "Unknown" }or{ objTv["type"] })[1]

            objTv.tagline= string.gsub(objTv.tagline or"", "[\n\r]", "")
            if string.isEmpty(objTv.tagline) or objTv.tagline==objTv.title or objTv.tagline==objTv.original_title then
                data.tagline= nil
            elseif true then
                data.tagline= string.gsub(objTv.tagline or"", "\n", "")
            end
            
            -- Table:obj -> Array:mediai
            -- local tvSeasonsIxs = {}
            for _, tvSeasonsIx in pairs(objTv['seasons'] or {}) do
                data["tv_season_id"] = tonumber(tvSeasonsIx.id or"")
                if tonumber(data.tv_season_id) then
                    data.tv_season_id= math.floor(tonumber(data.tv_season_id))
                end
                data.tv_is_epgroup = false

                local mediaNameSeason = mediaName -- 形如 "剧集名"
                data["release_date"] = tvSeasonsIx["air_date"] -- 首播日期
                data["season_title"] = tvSeasonsIx["name"]
                if not string.isEmpty(tvSeasonsIx.overview) and tvSeasonsIx.overview~=data.overview and
                        tvSeasonsIx.overview~=mediai.title and tvSeasonsIx.overview~=mediai.original_title then
                    data.overview_season = string.gsub(tvSeasonsIx.overview, "\r?\n\r?\n", "\n")
                end
                tmpTmdbartImgpath= nil
                if not string.isEmpty(tvSeasonsIx.poster_path) then
                    tmpTmdbartImgpath= {}
                    tmpTmdbartImgpath.seasonposter={}
                    tmpTmdbartImgpath.seasonposter.interf= {
                        ["url"]= tvSeasonsIx.poster_path,
                        ["lang"]= "und", --string.sub(settings["metadata_lang"],1,2),
                    }
                end
                if not table.isEmpty(tmpTmdbartImgpath) then
                    Array.extend(data.tmdb_art_path,tmpTmdbartImgpath)
                end

                data["season_number"] = math.floor(tvSeasonsIx["season_number"])
                data["episode_count"] = math.floor(tvSeasonsIx["episode_count"]) -- of this season
                if tonumber(data.season_number) then
                    data.season_number= math.floor(tonumber(data.season_number))
                end
                if tonumber(data.episode_count) then
                    data.episode_count= math.floor(tonumber(data.episode_count))
                end

                local seasonNameNormal -- 是否为 普通的季名称 S00/Specials/特别篇/S05/Season 5/第 5 季
                seasonNameNormal = (data["season_title"] == string.format("Season %d", data["season_number"])) or
                                       (data["season_title"] == "Specials")
                seasonNameNormal = (data["season_title"] == string.format("第 %d 季", data["season_number"])) or
                                       (data["season_title"] == "特别篇") or seasonNameNormal
                seasonNameNormal = (data["season_title"] == string.format("第%d季", data["season_number"])) or
                                       (data["season_title"] == (string.format('S%02d', data["season_number"]))) or
                                       seasonNameNormal
                if seasonNameNormal then
                    if not (Metadata_info_origin_title) and settings["metadata_lang"]=="zh-CN" then
                        if tonumber(data["season_number"]) ~= 0 then
                                data.season_title= string.format('第%d季', data["season_number"])
                        else data.season_title= '特别篇'
                        end
                    else
                        if tonumber(data["season_number"]) ~= 0 then
                            data.season_title= string.format('S%02d', data["season_number"])
                        else
                            data.season_title= 'Specials'
                        end
                    end
                else
                end
                mediaNameSeason = mediaNameSeason .. " " .. data.season_title
                -- 形如 "剧集名 第2季 (2010)"
                if data["release_date"] ~= nil and data["release_date"] ~= "" then
                    mediaNameSeason = mediaNameSeason .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
                end

                local media_data_json
                err, media_data_json = kiko.table2json(table.deepCopy(data) or{})
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, table.toStringBlock(data)));
                local seasonTextNormal = ""
                if data["season_number"] ~= 0 then
                    seasonTextNormal = string.format("第%02d季", data["season_number"] or "")
                else
                    seasonTextNormal = "特别篇"
                end
                local mediaLang={data["original_language"]}
                Array.extendUnique(mediaLang,data["spoken_language"],"iso_639_1")
                Array.extendUnique(mediaLang,data["tv_language"])
                local mediaRegion=table.deepCopy(data["origin_region"]) or{}
                Array.extendUnique(mediaRegion,data["production_region"],"iso_3166_1")
                mediaLang={mediaLang[1] or nil}
                mediaRegion={mediaRegion[1] or nil}
                for index, value in ipairs(mediaLang) do
                    mediaLang[index]= ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value
                end
                for index, value in ipairs(mediaRegion) do
                    mediaRegion[index]= ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value
                end

                table.insert(mediais, {
                    ["name"] = (( string.isEmpty(old_title) )and{ mediaNameSeason }or{ old_title })[1] ,
                    ["data"] = media_data_json,
                    ["extra"] = "类型：" .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[data.media_type] or data.media_type or (Translation["und-XX"] or{}).media_type["Unknown"] or"") ..
                            (string.isEmpty(data.tv_type) and{ "" }or{ ", ".. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[data.tv_type] or data.tv_type or (Translation["und-XX"] or{}).media_type[""] or"") })[1] ..
                        "  |  首播：" .. ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) ..
                        "  |  语言：" .. Array.toStringLine(mediaLang) .. "; " .. Array.toStringLine(mediaRegion) ..
                        "  |  " .. seasonTextNormal .. string.format(" %2d集", data["episode_count"] or "0") .. string.format(" (共%2d季)", data["season_count"] or "0") ..
                        "  |  状态：" .. (((Translation[settings["metadata_lang"]] or{}).media_status or{})[data.status] or data.status or (Translation["und-XX"] or{}).media_status["Unknown"] or"") ..
                                (( data.tv_in_production==true or data.tv_in_production=="true")and
                                        { ", "..(((Translation[settings["metadata_lang"]] or{}).media_status or{})["TV In Production"] or"In Production TV")}or{ "" })[1] ..
                        "\r\n简介：" .. ( string.isEmpty(data.overview_season) and{ "" }or
                                { string.gsub(data.overview_season or"", "\r?\n", " ") .."\r\n" })[1] ..
                            (string.gsub(data.overview or"", "\r?\n", " ") or "")..
                        (( string.isEmpty(old_title) )and{ "" }or{ "\r\n弃用的标题：" ..mediaNameSeason })[1],
                    ["scriptId"] = "Kikyou.l.TMDb",
                    ["media_type"] = data["media_type"],
                    ["season_number"] = data["season_number"],
                })
            end

            if options["search_list_season_epgroup"]=="1" then
                local hGetBatchTableEg={ ["url"]= {}, ["query"]= {}, ["header"]= {}, ["redirect"]= true, }
                local replyEg,contentEg, objEg=nil,nil, {}
                local urlPrefix= "http://api.themoviedb.org/3/"
                local queryEg = {
                    ["api_key"] = settings["api_key"],
                    ["language"] = settings["metadata_lang"],
                }
                for _, tvEpgroupsIx in pairs((objTv.episode_groups or{}).results or {}) do

                    table.insert(hGetBatchTableEg.url, urlPrefix.."tv/episode_group/".. tvEpgroupsIx.id)
                    table.insert(hGetBatchTableEg.query, table.deepCopy(queryEg) or{})
                    table.insert(hGetBatchTableEg.header, table.deepCopy(header) or{})
                end
                err,replyEg= kiko.httpgetbatch(hGetBatchTableEg.url,hGetBatchTableEg.query,hGetBatchTableEg.header)
                if err ~= nil then
                    kiko.log("[ERROR] TMDb.API.reply-tv/episode_group/eg_id."..(settings["metadata_lang"] or"").."."..".httpget: " .. err)
                    if tostring(err) == ("Host requires authentication") then
                        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                    end
                    error(err)
                end
                for replyEgI, replyEgV in ipairs(replyEg) do
                    contentEg = replyEgV["content"]
                    if (replyEgV or{}).hasError then
                        kiko.log("[ERROR] TMDb.API.reply-tv/episode_group/eg_id."..(settings["metadata_lang"] or"").."."..".httpget: " .. err..
                                (((replyEgV or{}).hasError) and{" <"..math.floor((replyEgV or{}).statusCode).."> "..(replyEgV or{}).errInfo} or{""})[1])
                        if (((replyEgV or{}).hasError) and{" <"..math.floor((replyEgV or{}).statusCode).."> "..(replyEgV or{}).errInfo} or{""})[1] == ("Host requires authentication") then
                            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                        end
                        error(err..(((replyEgV or{}).hasError) and{" <"..math.floor((replyEgV or{}).statusCode).."> "..(replyEgV or{}).errInfo} or{""})[1])
                    end
                    local objEgi= {}
                    err, objEgi = kiko.json2table(contentEg)
                    if err ~= nil then
                        kiko.log("[ERROR] TMDb.API.reply-tv/episode_group/eg_id."..replyEgI.."."..(settings["metadata_lang"] or"")..".json2table: " ..err)
                        -- error(err)
                    elseif table.isEmpty(objEgi) then
                        kiko.log("[ERROR] TMDb.API.reply-tv/episode_group/eg_id."..replyEgI.."."..(settings["metadata_lang"] or"")..".json2table: Empty table.")
                        -- error(err)
                    elseif true then
                        table.insert(objEg,objEgi)
                    end
                end
                for egI,tvEgIx in ipairs(objEg) do
                    data.tv_epgroup_id = tvEgIx.id or""
                    data.tv_is_epgroup = true

                    -- data.release_date = data.tv_first_air_date
                    data.epgroup_title = (string.isEmpty(tvEgIx.name) and{""} or{" "..tvEgIx.name})[1]
                    if not string.isEmpty(tvEgIx.description) and tvEgIx.description~=data.overview and
                            tvEgIx.description~=mediai.title and tvEgIx.description~=mediai.original_title then
                        data.overview_epgroup = string.gsub(tvEgIx.description, "\r?\n\r?\n", "\n")
                    end
                    data.season_count_eg = tvEgIx.group_count
                    data.episode_total_eg = tvEgIx.episode_count
                    if tonumber(data.season_count_eg) then
                        data.season_count_eg= math.floor(tonumber(data.season_count_eg))
                    end
                    if tonumber(data.episode_total_eg) then
                        data.episode_total_eg= math.floor(tonumber(data.episode_total_eg))
                    end
                    if not table.isEmpty(tvEgIx.network) then
                        data.tv_network= {}
                        -- data.network= table.deepCopy(tvEgIx.network)
                        for index, value in ipairs(table.isEmpty(tvEgIx.network) and{} or{tvEgIx.network}) do
                            data.tv_network= data.tv_network or {}
                            table.insert(data["tv_network"],{
                                -- ["id"]= tonumber(value["id"]or""),
                                -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                                ["name"]= (string.isEmpty(value.name) and{nil} or{value.name})[1],
                                ["origin_region"] = (string.isEmpty(value.origin_country) and{nil} or{value.origin_country})[1],
                            })
                        end
                    end
                    if tonumber(tvEgIx.type) then
                        data.epgroup_type= (math.floor(tonumber(tvEgIx.type)))
                    else
                        data.epgroup_type= "Unknown"
                    end
                    for egSeasonI, egSeasonV in ipairs(tvEgIx.groups) do
                        data.tv_season_id = egSeasonV.id or""

                        local mediaNameSeason = mediaName
                        data.release_date = data.tv_first_air_date
                        data.season_title = egSeasonV.name
                        if not string.isEmpty(egSeasonV.overview) and egSeasonV.overview~=data.overview and egSeasonV.overview~=data.overview_epgroup and
                                egSeasonV.overview~=mediai.title and egSeasonV.overview~=mediai.original_title then
                            data.overview_season = string.gsub(egSeasonV.overview, "\r?\n\r?\n", "\n")
                        else data.overview_season = nil
                        end
                        
                        data.season_number = math.floor(egSeasonV.order)
                        data.episode_count = #(egSeasonV.episodes)
                        if tonumber(data.season_number) then
                            data.season_number= math.floor(tonumber(data.season_number))
                        end
                        if tonumber(data.episode_count) then
                            data.episode_count= math.floor(tonumber(data.episode_count))
                        end

                        local seasonNameNormal -- 是否为 普通的季名称 S00/Specials/特别篇/S05/Season 5/第 5 季
                        seasonNameNormal = (data["season_title"] == string.format("Season %d", data["season_number"])) or
                                            (data["season_title"] == string.format("Series %d", data["season_number"])) or
                                            (data["season_title"] == "Specials")
                        seasonNameNormal = (data["season_title"] == string.format("第 %d 季", data["season_number"])) or
                                            (data["season_title"] == "特别篇") or seasonNameNormal
                        seasonNameNormal = (data["season_title"] == string.format("第%d季", data["season_number"])) or
                                            (data["season_title"] == (string.format('S%02d', data["season_number"]))) or
                                            seasonNameNormal
                        if seasonNameNormal then
                            if not (Metadata_info_origin_title) and settings["metadata_lang"]=="zh-CN" then
                                if tonumber(data["season_number"]) ~= 0 then
                                        data.season_title= string.format('第%d季', data["season_number"])
                                else data.season_title= '特别篇'
                                end
                            else
                                if tonumber(data["season_number"]) ~= 0 then
                                    data.season_title= string.format('S%02d', data["season_number"])
                                else
                                    data.season_title= 'Specials'
                                end
                            end
                        else
                        end
                        mediaNameSeason = mediaNameSeason .. " " .. data.season_title
                        -- 形如 "剧集名 第2季 (2010) 剧集组名"
                        if not string.isEmpty(data.release_date) then
                            mediaNameSeason = mediaNameSeason .. string.format(' (%s)', string.sub(data.release_date, 1, 4))
                        end
                        mediaNameSeason = mediaNameSeason.. (string.isEmpty(tvEgIx.name) and{""} or{" "..tvEgIx.name})[1]

                        local media_data_json
                        err, media_data_json = kiko.table2json(table.deepCopy(data) or{})
                        if err ~= nil then
                            kiko.log(string.format("[ERROR] table2json: %s", err))
                        end
                        -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, table.toStringBlock(data)));
                        local seasonTextNormal = ""
                        if data.season_number ~= 0 then
                            seasonTextNormal = string.format("第%02d季", data.season_number or "")
                        else
                            seasonTextNormal = "特别篇"
                        end
                        local mediaLang={data.original_language}
                        Array.extendUnique(mediaLang,data.spoken_language,"iso_639_1")
                        Array.extendUnique(mediaLang,data.tv_language)
                        local mediaRegion=table.deepCopy(data.origin_region) or{}
                        Array.extendUnique(mediaRegion,data.production_region,"iso_3166_1")
                        mediaLang={mediaLang[1] or nil}
                        mediaRegion={mediaRegion[1] or nil}
                        for index, value in ipairs(mediaLang) do
                            mediaLang[index]= ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value
                        end
                        for index, value in ipairs(mediaRegion) do
                            mediaRegion[index]= ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value
                        end

                        table.insert(mediais, {
                            ["name"] = (( string.isEmpty(old_title) )and{ mediaNameSeason }or{ old_title })[1] ,
                            ["data"] = media_data_json,
                            ["extra"] = "类型：" .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[data.media_type] or data.media_type or (Translation["und-XX"] or{}).media_type["Unknown"] or"") ..
                                    (string.isEmpty(data.tv_type) and{ "" }or{ ", ".. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[data.tv_type] or data.tv_type or (Translation["und-XX"] or{}).media_type[""] or"") })[1] ..
                                    (string.isEmpty(data.epgroup_type) and{ "" }or{ ", ".. (((Translation[settings["metadata_lang"]] or{}).media_type_epgroup or{})[data.epgroup_type] or data.epgroup_type or (Translation["und-XX"] or{}).media_type_epgroup[""] or"") })[1] ..
                                "  |  首播：" .. ((data.release_date or "") .. " " .. (data.first_air_date or "")) ..
                                "  |  语言：" .. Array.toStringLine(mediaLang) .. "; " .. Array.toStringLine(mediaRegion) ..
                                "  |  " .. seasonTextNormal .. string.format(" %2d集", data.episode_count or "0") .. string.format(" (共%2d季)", data.season_count_eg or "0") ..
                                "  |  状态：" .. (((Translation[settings["metadata_lang"]] or{}).media_status or{})[data.status] or data.status or (Translation["und-XX"] or{}).media_status["Unknown"] or"") ..
                                        (( data.tv_in_production==true or data.tv_in_production=="true")and
                                                { ", "..(((Translation[settings["metadata_lang"]] or{}).media_status or{})["TV In Production"] or"In Production TV")}or{ "" })[1] ..
                                "\r\n简介：" .. ( string.isEmpty(data.overview_season) and{ "" }or
                                            { string.gsub(data.overview_season or"", "\r?\n", " ") .."\r\n" })[1] ..
                                        ( string.isEmpty(data.overview_epgroup) and{ "" }or
                                            { string.gsub(data.overview_epgroup or"", "\r?\n", " ") .."\r\n" })[1] ..
                                        (string.gsub(data.overview or"", "\r?\n", " ") or "")..
                                        (( string.isEmpty(old_title) )and{ "" }or{ "\r\n弃用的标题：" ..mediaNameSeason })[1],
                            ["scriptId"] = "Kikyou.l.TMDb",
                            ["media_type"] = data["media_type"],
                            ["season_number"] = data["season_number"],
                        })
                    end
                end
            end
        end

        ::continue_search_a::
    end
    kiko.log("[INFO]  Finished searching <" .. keyword .. "> with " .. #(obj['results']) .. " results in "..settings_search_type)
    -- kiko.log("[INFO]  Reults:\t" .. table.toStringBlock(mediais))
    return mediais
end

-- 获取动画的剧集信息。在调用这个函数时，anime的信息可能不全，但至少会包含name，data这两个字段。
-- anime： Anime
-- 返回： Array[EpInfo]
function getep(anime)
    --分集类型包括 EP, SP, OP, ED, Trailer, MAD, Other 七种，分别用1-7表示， 默认情况下为1（即EP，本篇）

    -- kiko.log("[INFO]  Getting episodes of <" .. anime["name"] .. ">")
    -- 获取 是否 元数据使用原语言标题
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- number:季序数
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
        local function isNormalTitle(seasonEpsI)
            if table.isEmpty(seasonEpsI) then return true end
            seasonEpsI.episode_number = math.floor(tonumber(seasonEpsI.episode_number))
            if (seasonEpsI.name == "第 " .. seasonEpsI.episode_number .. " 集" or
                seasonEpsI.name == "第" .. seasonEpsI.episode_number .. "集" or seasonEpsI.name == "第" ..
                seasonEpsI.episode_number .. "話" or seasonEpsI.name == "Episode " .. seasonEpsI.episode_number) then
                return true
            else return false
            end
        end

        if anime_data.tv_is_epgroup == "true" or anime_data.tv_is_epgroup == true then
            local objTgll= Kikoplus.httpgetMediaId({
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"],
            },"tv/episode_group/"..anime_data.tv_epgroup_id)
            
            local objTgllEg = {}
            for egSeasonI, egSeasonV in ipairs(objTgll.groups or{}) do
                if anime_data.season_number == math.floor(egSeasonV.order) then
                    objTgllEg= egSeasonV.episodes
                    break
                end
            end
            if (table.isEmpty(objTgllEg) or #objTgllEg == 0) then
                return eps
            end
            
            local normalEplTitle = false -- at least one normal
            for _, seasonEpsI in ipairs(objTgllEg) do
                normalEplTitle = normalEplTitle or isNormalTitle(seasonEpsI)
            end
            local objTgolEg = nil
            if normalEplTitle and (settings["metadata_lang"] ~= (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]) then
                local objTgol= Kikoplus.httpgetMediaId({
                    ["api_key"] = settings["api_key"],
                    ["language"] = (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1],
                },"tv/episode_group/"..anime_data.tv_epgroup_id)

                objTgolEg = ((objTgol.groups or{})[anime_data.season_number] or{}).episodes
                local normalEpoTitle = true -- each one is normal
                for _, seasonEpsI in ipairs(objTgolEg) do
                    normalEpoTitle = normalEpoTitle and isNormalTitle(seasonEpsI)
                end
                if (normalEpoTitle == true) then
                    objTgolEg= nil
                end
            end

            local orderOffsetTmp= 1- objTgllEg[1].order
            for seasonEpsK, seasonEpsV in pairs(objTgllEg or {}) do
                if isNormalTitle(seasonEpsV) and not table.isEmpty(objTgolEg) and
                        not table.isEmpty((objTgolEg or{})[seasonEpsK]) and not isNormalTitle((objTgolEg or{})[seasonEpsK]) then
                    epName = (objTgolEg or{})[seasonEpsK].name
                    epIndex = math.floor(tonumber(seasonEpsV.order)) +orderOffsetTmp
                else
                    epName = seasonEpsV.name
                    epIndex = math.floor(tonumber(seasonEpsV.order)) +orderOffsetTmp
                end

                if anime_data.season_number == 0 then
                    epType = 2
                else
                    epType = 1
                end
                table.insert(eps, {
                    ["name"] = epName,
                    ["index"] = epIndex,
                    ["type"] = epType
                })
            end
        elseif true then
            -- http get 请求 参数
            local query = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            local header = {["Accept"] = "application/json"}
            if settings["api_key"] == "<<API_Key_Here>>" then
                kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
                kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
            end
            -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 特定季序数的 媒体信息
            local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                    "/season/" .. (anime_data["season_number"])), query, header)

            if err ~= nil or (reply or{}).hasError then
                kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.httpget: " .. err..
                        (((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1])
                if tostring(err) == ("Host requires authentication") then
                    kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                    kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                end
                error(err.. (((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1])
            end
            -- json:reply -> Table:obj
            local content = reply["content"]
            local err, objS = kiko.json2table(content)
            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-getep.json2table: " .. err)
                error(err)
            end
            if (objS["episodes"] == nil or #(objS["episodes"]) == 0) then
                return eps
            end
            
            local normalEplTitle = false -- at least one normal
            for _, seasonEpsI in ipairs(objS.episodes) do
                normalEplTitle = normalEplTitle or isNormalTitle(seasonEpsI)
            end
            local objSO = nil
            if (normalEplTitle and string.sub(query["language"], 1, 2) ~= anime_data["original_language"]) then
                -- 获取集标题
                query["language"] = anime_data["original_language"]
                -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 特定季序数的 原语言的 媒体信息
                local err, replyO = kiko.httpget(string.format( "http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                            "/season/" .. anime_data["season_number"]), query, header)
                if err ~= nil or (replyO or{}).hasError then
                    kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.lang.httpget: " .. err..
                            (((replyO or{}).hasError) and{" <"..math.floor((replyO or{}).statusCode).."> "..(replyO or{}).errInfo} or{""})[1])
                    if tostring(err) == ("Host requires authentication") then
                        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                    end
                    error(err..(((replyO or{}).hasError) and{" <"..math.floor((replyO or{}).statusCode).."> "..(replyO or{}).errInfo} or{""})[1])
                end
                -- json:reply -> Table:obj
                local contentO = replyO["content"]
                err, objSO = kiko.json2table(contentO)
                if err ~= nil then
                    kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.lang.json2table: " .. err)
                    error(err)
                end
                local normalEpoTitle = true -- each one is normal
                for _, seasonEpsI in ipairs(objSO.episodes) do
                    normalEpoTitle = normalEpoTitle and isNormalTitle(seasonEpsI)
                end
                if (normalEpoTitle == true) then
                    objSO= nil
                end
            end
            -- local orderOffsetTmp= 1- objS.episodes[1].order
            for seasonEpsK, seasonEpsV in pairs(objS.episodes or {}) do
                if isNormalTitle(seasonEpsV) and not table.isEmpty((objSO or{}).episodes) and
                        not table.isEmpty(((objSO or{}).episodes or{})[seasonEpsK]) and not isNormalTitle(((objSO or{}).episodes or{})[seasonEpsK]) then
                    epName = ((objSO or{}).episodes or{})[seasonEpsK].name
                    epIndex = math.floor(tonumber(seasonEpsV.episode_number)) -- +orderOffsetTmp
                else
                    epName = seasonEpsV.name
                    epIndex = math.floor(tonumber(seasonEpsV.episode_number)) -- +orderOffsetTmp
                end
                
                -- seasonEpsV["air_date"]
                -- seasonEpsV["overview"]
                -- seasonEpsV["vote_average"]
                -- seasonEpsV["crew"] --array
                -- seasonEpsV["guest_stars"] --array

                -- 集类型
                if anime_data["season_number"] == 0 then
                    -- 特别篇/Specials/Season 0
                    epType = 2
                else
                    -- 普通
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
        end
        if anime_data["media_type"] == "movie" then
            kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                    anime_data["original_title"] .. ") >")

        elseif anime_data["media_type"] == "tv" then
            kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                    anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. " >")
        end
    end
    return eps
end

-- 获取动画详细信息
-- anime： AnimeLite
-- 返回：Anime
function detail(anime)
    -- kiko.log("[INFO]  Getting detail of <" .. anime["name"] .. ">")
    -- table.toStringLog(anime) -- kiko.log()
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        -- 无媒体信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
        return anime
    end
    -- table.toStringLog(anime_data) -- kiko.log("")
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end

    if tonumber(anime_data.season_number) then
        anime_data.season_number= math.floor(tonumber(anime_data.season_number))
    end
    if tonumber(anime_data.episode_count) then
        anime_data.episode_count= math.floor(tonumber(anime_data.episode_count))
    end

    if anime_data.season_title == string.format("第 %d 季", anime_data.season_number) then
        anime_data.season_title= string.format("第%d季", anime_data.season_number)
    end
    --
    local creditTsall= ((settings["metadata_castcrew_season_aggregate"]=="1") and{ true }or{ false })[1]
    if anime_data.media_type=="movie" then creditTsall=false end
    local objMoll,objTvll,objTsll,objMell,objTgll= {},{},{},{},{}
    if anime_data.media_type=="movie" then
        objMoll=Kikoplus.httpgetMediaId({
            ["api_key"] = settings["api_key"],
            ["language"] = settings["metadata_lang"],
            ["append_to_response"] = "credits,release_dates,keywords,external_ids,translations,images", -- collections
            ["include_image_language"] = string.sub(settings["metadata_lang"],1,2)..","..
                    (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]..",en,null", -- collections
        },anime_data.media_type.."/"..anime_data.media_id)
        objMell= objMoll
    elseif anime_data.media_type=="tv" then
        objTvll=Kikoplus.httpgetMediaId({
            ["api_key"] = settings["api_key"],
            ["language"] = settings["metadata_lang"],
            ["append_to_response"] = "content_ratings,keywords,external_ids,translations,images"..
                    ((anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true) and{""} or{",aggregate_credits"})[1],
            ["include_image_language"] = string.sub(settings["metadata_lang"],1,2)..","..
                    (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]..",en,null", -- collections
        },anime_data.media_type.."/"..anime_data.media_id)
        objMell=objTvll
        if anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
            objTsll=Kikoplus.httpgetMediaId({
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"],
                ["append_to_response"] = ((creditTsall) and{"aggregate_credits"}or{"credits"})[1]..",external_ids,translations,images",
                ["include_image_language"] = string.sub(settings["metadata_lang"],1,2)..","..
                        (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]..",en,null", -- collections
            },anime_data.media_type.."/"..anime_data.media_id .. "/season/" .. anime_data.season_number)
        else
            objTgll= Kikoplus.httpgetMediaId({
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"],
            },"tv/episode_group/"..anime_data.tv_epgroup_id)
        end
    end

    if anime_data.media_type=="movie" or anime_data.media_type=="tv" then
        -- anime_data["media_id"] = string.format("%d", objMell["id"])
        anime_data.interf_title = string.unescape(objMell["title"]) or string.unescape(objMell["name"]) -- 标题
        anime_data["release_date"] = objMell["release_date"] or objMell["first_air_date"]
        anime_data["original_language"] = objMell["original_language"]
        anime_data["origin_country"]= nil
        anime_data["origin_region"] = table.deepCopy(objMell["origin_country"] or {}) or{}
        if not string.isEmpty(objMell.overview) and objMell.overview~=objMell.title and objMell.overview~=objMell.original_title then
            anime_data["overview"] = (string.isEmpty(objMell.overview) and{""} or{ string.gsub(objMell["overview"], "\r?\n\r?\n", "\n") })[1]
        else anime_data.overview =nil
        end
        anime_data["vote_average"] = objMell["vote_average"]
        anime_data["genre_names"] = {}
        for key, value in pairs(objMell["genres"] or {}) do
            if not string.isEmpty(value.name) then
                table.insert(anime_data["genre_names"],((Translation[settings["metadata_lang"]] or{}).media_genre or{})[value.id] or value.name)
            end
        end
        anime_data.tmdb_art_path={}
        local tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})[anime_data.media_type.."poster"] or{} ).interf
        if (not string.isEmpty(objMell.poster_path)) then
            anime_data.tmdb_art_path= (table.isEmpty(anime_data.tmdb_art_path) and{ {} }or{ anime_data.tmdb_art_path })[1]
            anime_data.tmdb_art_path[anime_data.media_type.."poster"]= (table.isEmpty(anime_data.tmdb_art_path[anime_data.media_type.."poster"]) and
                    { {} }or{ anime_data.tmdb_art_path[anime_data.media_type.."poster"] })[1]
            anime_data.tmdb_art_path[anime_data.media_type.."poster"].interf= {
                ["url"]= objMell.poster_path,
                ["lang"]= "und", --string.sub(settings["metadata_lang"],1,2),
            }
        else ((anime_data.tmdb_art_path or{})[anime_data.media_type.."poster"] or{}).interf={}
        end
        tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})[anime_data.media_type.."background"] or{} ).interf
        if (not string.isEmpty(objMell.backdrop_path)) then
            anime_data.tmdb_art_path= (table.isEmpty(anime_data.tmdb_art_path) and{ {} }or{ anime_data.tmdb_art_path })[1]
            anime_data.tmdb_art_path[anime_data.media_type.."background"]= (table.isEmpty(anime_data.tmdb_art_path[anime_data.media_type.."background"]) and
                    { {} }or{ anime_data.tmdb_art_path[anime_data.media_type.."background"] })[1]
            anime_data.tmdb_art_path[anime_data.media_type.."background"].interf= {
                ["url"]= objMell.backdrop_path,
                ["lang"]= "und",
            }
        else ((anime_data.tmdb_art_path or{})[anime_data.media_type.."background"] or{}).interf={}
        end
        -- anime_data["vote_count"] = tonumber(objMell["vote_count"]or"")
        -- anime_data["popularity_num"] = tonumber(objMell["popularity"]or"")
        
        anime_data["homepage_path"]= (( objMell["homepage"]==nil or objMell["homepage"]=="" )and{ nil }or{ objMell["homepage"] })[1]
        anime_data.status= ( string.isEmpty(objMell.status) and{ "Unknown" }or{ objMell.status })[1]
        objMell.tagline= string.gsub(objMell.tagline or"", "[\n\r]", "")
        if string.isEmpty(objMell.tagline) or objMell.tagline==objMell.title or objMell.tagline==objMell.original_title then
            anime_data.tagline= nil
        elseif true then
            anime_data.tagline= string.gsub(objMell.tagline or"", "[\n\r]", "")
        end
        anime_data["production_company"]= {}
        anime_data["production_country"]= nil
        anime_data["production_region"]= {}
        anime_data["spoken_language"]= {}
        for index, value in ipairs(objMell["production_companies"] or {}) do
            table.insert(anime_data["production_company"],{
                -- ["id"]= tonumber(value["id"]or""),
                -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                ["origin_region"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
            })
        end
        for index, value in ipairs(objMell["production_countries"] or {}) do
            table.insert(anime_data["production_region"],{
                ["iso_3166_1"]= (( value["iso_3166_1"]==nil or value["iso_3166_1"]=="" )and{ nil }or{ value["iso_3166_1"] })[1],
                -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
            })
        end
        for index, value in ipairs(objMell["spoken_languages"] or {}) do
            if not string.isEmpty(value.iso_639_1) then
                table.insert(anime_data["spoken_language"],{
                    ["iso_639_1"]= (( value["iso_639_1"]==nil or value["iso_639_1"]=="" )and{ nil }or{ value["iso_639_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    -- ["english_name"]= (( value["english_name"]==nil or value["english_name"]=="" )and{ nil }or{ value["english_name"] })[1],
                })
            end
        end
        if string.isEmpty(anime_data.original_language) then
            anime_data.original_language = ((anime_data.spoken_language or{})[1] or{}).iso_639_1
        end

        if table.isEmpty(anime_data.update_info) then
            anime_data.update_info= {}
            anime_data.update_info.version= info.version
            anime_data.update_info.timestamp= os.time()
            anime_data.update_info.level_detail= "scrape"
        else
            if string.isEmpty(anime_data.update_info.version) or anime_data.update_info.version < info.version then
                -- from lower version
                anime_data.update_info.version= info.version
            elseif anime_data.update_info.version > info.version then
                -- from higher version
                anime_data.update_info.version= info.version
            else
                -- from same version
                local tmp_ac = nil
                -- anime_data.update_info.version= info.version
            end
            -- 7*24*3600=604800
            if string.isEmpty(anime_data.update_info.timestamp) or os.time() - anime_data.update_info.timestamp > 604800 then
                -- updated more than 1 week ago
                anime_data.update_info.timestamp= os.time()
            elseif os.time() - anime_data.update_info.timestamp < 0 then
                -- updated in the future
                anime_data.update_info.timestamp= os.time()
            else
                -- updated in the past 1 week
                local tmp_ac = nil
                -- anime_data.update_info.timestamp= os.time()
            end
            if anime_data.update_info.level_detail == "scrape" then
                -- from reult of search
                anime_data.update_info.level_detail= "detail"
            elseif anime_data.update_info.level_detail == "detail" then
                -- from reult of detail
                local tmp_ac = nil
                -- anime_data.update_info.level_detail= "detail"
            else
                -- from reult of others
                anime_data.update_info.level_detail= "detail"
            end
        end
    end
    if anime_data.media_type=="movie" then
        anime_data["mo_is_adult"]= (( objMoll["adult"]==nil or objMoll["adult"]=="" )and{ nil }or{ tostring(objMoll["adult"])=="true" })[1]
        anime_data["mo_is_video"]= (( objMoll["video"]==nil or objMoll["video"]=="" )and{ nil }or{ tostring(objMoll["video"])=="true" })[1]

        anime_data["runtime"] = ( objMoll["runtime"]==nil or objMoll["runtime"]=="" )and{ nil }or{ tostring(objMoll["runtime"]) }
        
        --? OTHER_INFO mo
        anime_data["mo_belongs_to_collection"] = table.deepCopy(objMoll["belongs_to_collection"]) or{}
        anime_data["mo_budget"] = tonumber(objMoll["budget"]or"")
        anime_data["mo_revenue"] = tonumber(objMoll["revenue"]or"")
        anime_data["person_cast"]= {}
        anime_data["person_crew"]= {}
    elseif anime_data.media_type=="tv" then
        anime_data["tv_first_air_date"] = anime_data["release_date"]
        anime_data["season_count"] = objTvll["number_of_seasons"]
        anime_data["episode_total"] = objTvll["number_of_episodes"]
        if tonumber(anime_data.season_count) then
            anime_data.season_count= math.floor(tonumber(anime_data.season_count))
        end
        if tonumber(anime_data.episode_total) then
            anime_data.episode_total= math.floor(tonumber(anime_data.episode_total))
        end
        --? OTHER_INFO m&t of tv
        anime_data["runtime"] = table.deepCopy(objTvll["episode_run_time"]) or{}
        if not string.isEmpty(objTvll.overview) and objTvll.overview~=objTvll.title and objTvll.overview~=objTvll.original_title then
            anime_data.overview = (string.isEmpty(objTvll.overview) and{""} or{ string.gsub(objTvll.overview, "\r?\n\r?\n", "\n") })[1]
        else anime_data.overview =nil
        end
        objTvll.tagline= string.gsub(objTvll.tagline or"", "[\n\r]", "")
        if string.isEmpty(objTvll.tagline) or objTvll.tagline==objTvll.title or objTvll.tagline==objTvll.original_title then
            anime_data.tagline= nil
        elseif true then
            anime_data.tagline= string.gsub(objTvll.tagline or"", "[\n\r]", "")
        end
        
        --? OTHER_INFO tv
        anime_data["person_cast"]= {}
        anime_data["person_crew"]= {}
        for _, value in ipairs(objTvll["created_by"] or {}) do
            table.insert(anime_data["person_crew"],{
                -- ["gender"]= (( tonumber(value["gender"])==1 or tonumber(value["gender"])==2 )and{ tonumber(value["gender"]) }or{ nil })[1],
                ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                ["original_name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                ["profile_path"]= (( value["profile_path"]==nil or value["profile_path"]=="" )and{ nil }or{ value["profile_path"] })[1],
                ["department"]= "Writing",
                ["job"]={"Creator"},
            
                ["id"] = tonumber(value["id"]or""),
                -- ["credit_id"]= (( value["credit_id"]==nil or value["credit_id"]=="" )and{ nil }or{ value["credit_id"] })[1],
            })
        end
        anime_data["tv_in_production"]= (( objTvll["in_production"]==nil or objTvll["in_production"]=="" )and{ nil }or{ tostring(objTvll["in_production"])=="true" })[1]
        anime_data["tv_language"] = table.deepCopy(objTvll["languages"]) or{}
        anime_data["tv_last_air_date"]= (( objTvll["last_air_date"]==nil or objTvll["last_air_date"]=="" )and{ nil }or{ objTvll["last_air_date"] })[1]
        -- anime_data["tv_last_episode_to_air"] = table.deepCopy(objTvll["last_episode_to_air"]) or{}
        -- anime_data["tv_next_episode_to_air"]= table.deepCopy(objTvll["next_episode_to_air"]) or{}
        anime_data["tv_network"]= {}
        for index, value in ipairs(objTvll["networks"] or {}) do
            table.insert(anime_data["tv_network"],{
                -- ["id"]= tonumber(value["id"]or""),
                -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                ["origin_region"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
            })
        end
        anime_data["tv_type"]= (( objTvll["type"]==nil or objTvll["type"]=="" )and{ "Unknown" }or{ objTvll["type"] })[1]

        if anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
            anime_data["release_date"] = objTsll["air_date"] -- 首播日期7
            anime_data.tv_season_id = ((tonumber(objTsll.id) ==nil)and{nil}or{tostring(math.floor(tonumber(objTsll.id)))})[1]
            if not string.isEmpty(objTsll.overview) and objTsll.overview~=anime_data.overview and
                    objTsll.overview~=anime_data.title and objTsll.overview~=anime_data.original_title then
                anime_data.overview_season = string.gsub(objTsll.overview, "\r?\n\r?\n", "\n")
            else anime_data.overview_season = nil
            end
            
            local tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})["seasonposter"] or{} ).interf
            if (not string.isEmpty(objTsll.poster_path)) then
                anime_data.tmdb_art_path= (table.isEmpty(anime_data.tmdb_art_path) and{ {} }or{ anime_data.tmdb_art_path })[1]
                anime_data.tmdb_art_path["seasonposter"]= (table.isEmpty(anime_data.tmdb_art_path["seasonposter"]) and
                        { {} }or{ anime_data.tmdb_art_path["seasonposter"] })[1]
                anime_data.tmdb_art_path["seasonposter"].interf= {
                    ["url"]= objTsll.poster_path,
                    ["lang"]= "und", --string.sub(settings["metadata_lang"],1,2),
                }
            else ((anime_data.tmdb_art_path or{})["seasonposter"] or{}).interf={}
            end
        else
            if not string.isEmpty(objTgll.description) and objTgll.description~=anime_data.overview and
                    objTgll.description~=anime_data.title and objTgll.description~=anime_data.original_title then
                anime_data.overview_epgroup = string.gsub(objTgll.description, "\r?\n\r?\n", "\n")
            else anime_data.overview_epgroup = nil
            end
            anime_data.season_count_eg = objTgll.group_count
            anime_data.episode_total_eg = objTgll.episode_count
            if tonumber(anime_data.season_count_eg) then
                anime_data.season_count_eg= math.floor(tonumber(anime_data.season_count_eg))
            end
            if tonumber(anime_data.episode_total_eg) then
                anime_data.episode_total_eg= math.floor(tonumber(anime_data.episode_total_eg))
            end
            if not table.isEmpty(objTgll.network) then
                anime_data.tv_network= {}
                -- anime_data.network= table.deepCopy(objTgll.network)
                for index, value in ipairs(table.isEmpty(objTgll.network) and{} or{objTgll.network}) do
                    anime_data.tv_network= anime_data.tv_network or {}
                    table.insert(anime_data["tv_network"],{
                        -- ["id"]= tonumber(value["id"]or""),
                        -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                        ["name"]= (string.isEmpty(value.name) and{nil} or{value.name})[1],
                        ["origin_region"] = (string.isEmpty(value.origin_country) and{nil} or{value.origin_country})[1],
                    })
                end
            end
            if tonumber(objTgll.type) then
                anime_data.epgroup_type= (math.floor(tonumber(objTgll.type)))
            else
                anime_data.epgroup_type= "Unknown"
            end
            for egSeasonI, egSeasonV in ipairs(objTgll.groups or{}) do
                if anime_data.season_number == math.floor(egSeasonV.order) then
                    if not string.isEmpty(egSeasonV.overview) and egSeasonV.overview~=anime_data.overview and egSeasonV.overview~=anime_data.overview_epgroup and
                            egSeasonV.overview~=anime_data.title and egSeasonV.overview~=anime_data.original_title then
                        anime_data.overview_season = string.gsub(egSeasonV.overview, "\r?\n\r?\n", "\n")
                    end
                end
            end
        end
    end

    if string.isEmpty(anime_data.tagline) or anime_data.tagline==anime_data.title or anime_data.tagline==anime_data.original_title then
        anime_data.tagline= nil
    end
    if string.isEmpty(anime_data.overview) or anime_data.overview==anime_data.title or anime_data.overview==anime_data.original_title then
        anime_data.overview=nil
    end
    for _,vtr in ipairs(objMell.translations.translations) do
        -- if vtr.iso_639_1== string.sub(settings["metadata_lang"],1,2) then
        -- end
        if vtr.iso_639_1== (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1] then
            if not table.isEmpty(vtr.data) then
                if (not string.isEmpty(vtr.data.tagline)) and
                        vtr.data.tagline~=anime_data.title and vtr.data.tagline~=anime_data.original_title then
                    anime_data.tagline_origin= string.gsub(vtr.data.tagline or"", "\r?\n\r?\n", "\n")
                else anime_data.tagline_origin= nil
                end
                if (not string.isEmpty(vtr.data.overview)) and
                        vtr.data.overview~=anime_data.title and vtr.data.overview~=anime_data.original_title then
                    anime_data.overview_origin= string.gsub(vtr.data.overview or"", "\r?\n\r?\n", "\n")
                else anime_data.overview_origin= nil
                end
                if (not string.isEmpty(vtr.data.homepage)) then
                    anime_data.homepage_origin= vtr.data.homepage
                else anime_data.homepage_origin= nil
                end
            end
        end
    end
    if string.isEmpty(anime_data.overview_season) or anime_data.overview_season==anime_data.overview or
            anime_data.overview_season==anime_data.title or anime_data.overview_season==anime_data.original_title then
        anime_data.overview_season=nil
    end
    if (anime_data.media_type~="movie") and anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
        for _,vtr in ipairs(objTsll.translations.translations) do
            if vtr.iso_639_1== (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1] then
                if not table.isEmpty(vtr.data) then
                    vtr.data.overview= string.gsub(vtr.data.overview or"", "\r?\n\r?\n", "\n")
                    if (not string.isEmpty(vtr.data.overview)) and
                            vtr.data.overview~=(anime_data.overview or"") and vtr.data.overview~=(anime_data.overview_origin or"") and
                            vtr.data.overview~=anime_data.title and vtr.data.overview~=anime_data.original_title then
                        anime_data.overview_season_origin= vtr.data.overview
                    else anime_data.overview_season_origin= nil
                    end
                end
            end
        end
    end
    local tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})[anime_data.media_type.."poster"] or{} ).origin
    local imgTypePairTmdb = {{"backdrops","background"}, {"logos","logo"}, {"posters","poster"}}
    local imgLangPriority = {} -- larger===priorer
    local langOTmp= (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]
    langOTmp= ((langOTmp==string.sub(settings["metadata_lang"],1,2)) and{langOTmp.."_"} or{langOTmp})[1]
    if settings["metadata_info_origin_image"] =="2" then
        imgLangPriority= {
            [""]=4, ["und"]=4, ["zxx"]=4, ["xx"]=4, ["en"]=1, [string.sub(settings["metadata_lang"],1,2)]=1, [langOTmp]=3,
        }
    elseif settings["metadata_info_origin_image"] =="0" then
        imgLangPriority= {
            [""]=2, ["und"]=2, ["zxx"]=2, ["xx"]=2, ["en"]=1, [string.sub(settings["metadata_lang"],1,2)]=1, [langOTmp]=4,
        }
    else
        imgLangPriority= {
            [""]=2, ["und"]=2, ["zxx"]=2, ["xx"]=2, ["en"]=2, [string.sub(settings["metadata_lang"],1,2)]=2, [langOTmp]=4,
        }
    end
    langOTmp=nil
    for _,vitp in ipairs(imgTypePairTmdb) do
        for _,vim in ipairs(objMell.images[vitp[1]] or{}) do
            tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})[anime_data.media_type..vitp[2]] or{} ).origin
            if (not string.isEmpty(vim.file_path)) and
                    not( not table.isEmpty(tmpTmdbartImgpath) and (imgLangPriority[tmpTmdbartImgpath.lang] >= (imgLangPriority[(vim.iso_639_1 or"und")] or 1))) then
                anime_data.tmdb_art_path= (table.isEmpty(anime_data.tmdb_art_path) and{ {} }or{ anime_data.tmdb_art_path })[1]
                anime_data.tmdb_art_path[anime_data.media_type..vitp[2]]= (table.isEmpty(anime_data.tmdb_art_path[anime_data.media_type..vitp[2]]) and
                        { {} }or{ anime_data.tmdb_art_path[anime_data.media_type..vitp[2]] })[1]
                anime_data.tmdb_art_path[anime_data.media_type..vitp[2]].origin= {
                    ["url"]= vim.file_path,
                    ["lang"]= (string.isEmpty(vim.iso_639_1)and{"und"}or{ vim.iso_639_1 or "und"})[1],
                }
                if settings["metadata_info_origin_image"]=="2" then
                    if (vim.iso_639_1 == nil) or (vim.iso_639_1 == "und") then
                        break
                    end
                else
                    if vim.iso_639_1 == (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1] then
                        break
                    end
                end
            end
        end
        -- if vitp[2] == "logo" and not table.isEmpty(((anime_data.tmdb_art_path or{})[anime_data.media_type..vitp[2]] or{}).origin) then
        --     (anime_data.tmdb_art_path or{})[anime_data.media_type..vitp[2]].interf= table.deepCopy(
        --             (anime_data.tmdb_art_path or{})[anime_data.media_type..vitp[2]].origin)
        -- end
        if anime_data.media_type~="movie" and anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
            for _,vim in ipairs(objTsll.images[vitp[1]] or{}) do
                tmpTmdbartImgpath= ((anime_data.tmdb_art_path or{})["season"..vitp[2]] or{} ).origin
                if (not string.isEmpty(vim.file_path)) and
                        not( not table.isEmpty(tmpTmdbartImgpath) and (imgLangPriority[tmpTmdbartImgpath.lang] >= (imgLangPriority[(vim.iso_639_1 or"und")] or 1))) then
                    anime_data.tmdb_art_path= (table.isEmpty(anime_data.tmdb_art_path) and{ {} }or{ anime_data.tmdb_art_path })[1]
                    anime_data.tmdb_art_path["season"..vitp[2]]= (table.isEmpty(anime_data.tmdb_art_path["season"..vitp[2]]) and
                            { {} }or{ anime_data.tmdb_art_path["season"..vitp[2]] })[1]
                    anime_data.tmdb_art_path["season"..vitp[2]].origin= {
                        ["url"]= vim.file_path,
                        ["lang"]= (string.isEmpty(vim.iso_639_1)and{"und"}or{ vim.iso_639_1 or "und"})[1],
                    }
                    if settings["metadata_info_origin_image"]=="2" then
                        if (vim.iso_639_1 == nil) or (vim.iso_639_1 == "und") then
                            break
                        end
                    else
                        if vim.iso_639_1 == (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1] then
                            break
                        end
                    end
                end
            end
        end
    end

    local objEi=  table.deepCopy(((anime_data.media_type=="movie")and{ objMoll.external_ids }or{ objTvll.external_ids })[1]) or{}
    anime_data.imdb_id= ( string.isEmpty(objEi.imdb_id) and{ nil }or{ objEi.imdb_id })[1]
    anime_data.facebook_id= ( string.isEmpty(objEi.facebook_id) and{ nil }or{ objEi.facebook_id })[1]
    anime_data.instagram_id= ( string.isEmpty(objEi.instagram_id) and{ nil }or{ objEi.instagram_id })[1]
    anime_data.twitter_id= ( string.isEmpty(objEi.twitter_id) and{ nil }or{ objEi.twitter_id })[1]
    if anime_data.media_type=="tv" and anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
        anime_data.tvdb_id= ((objEi.tvdb_id ==nil)and{nil}or{tostring(math.floor(tonumber(objEi.tvdb_id)))})[1]
        anime_data.tvdb_id_season= (((objTsll.external_ids or{}).tvdb_id ==nil)and{nil}or{
                tostring(math.floor(tonumber((objTsll.external_ids or{}).tvdb_id)))})[1]
    end
    objEi={}

    local objCr= {}
    if anime_data.media_type=="movie" then
        objCr= table.deepCopy(objMoll.credits)
    elseif anime_data.tv_is_epgroup~="true" and anime_data.tv_is_epgroup ~=true then
        objCr= table.deepCopy( objTsll[( (creditTsall) and{"aggregate_credits"}or{"credits"} )[1]] )
    else
        creditTsall= true
        objCr= table.deepCopy(objTvll.aggregate_credits)
    end
    local tmpAnimeCharacter, tmpMcCast,tmpMcCrew={}, 0,0
    tmpMcCast= math.floor(tonumber( settings["metadata_castcrew_castcount"] ) or Metadata_person_max_cast)
    if tmpMcCast<0 then tmpMcCast=math.maxinteger end
    Metadata_person_max_cast = math.max( tmpMcCast , math.floor(Metadata_person_max_cast))
    tmpMcCrew= math.floor(tonumber( settings["metadata_castcrew_crewcount"] ) or Metadata_person_max_crew)
    if tmpMcCrew<0 then tmpMcCrew=math.maxinteger end
    Metadata_person_max_crew = math.max( tmpMcCrew , math.floor(Metadata_person_max_crew))
    anime_data["person_cast"]={}
    -- anime_data["person_cast"]=anime_data["person_cast"] or {}
    for _, value in ipairs(objCr.cast or {}) do
        if #(anime_data["person_cast"])>=Metadata_person_max_cast then break end
        local crtText = ((creditTsall)and
                { Array.extendUnique({},value.roles,"character") or{} } or
                { string.isEmpty(value.character) and{ "" }or{ value.character } })[1]
        table.insert(anime_data["person_cast"],{
            -- ["gender"]= (( tonumber(value.gender)==1 or tonumber(value.gender)==2 )and{ tonumber(value.gender) }or{ nil })[1],
            ["name"]= (( string.isEmpty(value.name) )and{
                (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1] }or{ value.name })[1],
            ["original_name"]= (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1],
            ["profile_path"]= (( string.isEmpty(value.profile_path))and{ nil }or{ value.profile_path })[1],
            ["character"]= table.deepCopy(crtText) or{""},
            ["department"]= "Actors",
            ["job"]={"Actor"},
        
            ["adult"]= (( string.isEmpty(value.adult) )and{ nil }or{ value.adult })[1],
            ["id"] = tonumber(value.id or""),
            -- ["known_for_department"]= (( string.isEmpty(value.known_for_department)) and{ nil }or{ value.known_for_department })[1],
            -- ["popularity"]= tonumber(value.popularity or""),
            ["cast_id"]= tonumber(value.cast_id or""),
            -- ["credit_id"]= (( string.isEmpty(value.credit_id))and{ nil }or{ value.credit_id })[1],
            ["order"]= tonumber(value.order or""),
        })
        
        if #(anime_data["person_cast"])>tmpMcCast then goto continue_detail_ccc_cast end
        for crtI, crtV in ipairs(crtText) do
            for _, crtGpair in ipairs((Translation[settings["metadata_lang"]] or{}).character_gsub or{}) do
                crtText[crtI] = string.gsub(crtText[crtI] or"",crtGpair[1] or"",crtGpair[2] or crtGpair[1] or"")
            end
        end
        local tmpAnimeCharacterName=""
        if Metadata_info_origin_title then
            tmpAnimeCharacterName= ( string.isEmpty(value.original_name) and{ (string.isEmpty(value.name) and
            { nil }or{ value.name })[1] }or{ value.original_name})[1]
        else
            tmpAnimeCharacterName= ( string.isEmpty(value.name) and{ (string.isEmpty(value.original_name) and
                    { nil }or{ value.original_name })[1] }or{ value.name })[1]
        end
        table.insert(tmpAnimeCharacter,{
            ["name"]= ((#crtText)~=0 and{Array.toStringLine(crtText,"|")} or{"-"})[1],
            ["actor"]=(string.isEmpty(tmpAnimeCharacterName) and{"-"} or{tmpAnimeCharacterName})[1],
            ["link"]="https://www.themoviedb.org/person/"..value.id,
            ["imgurl"]= (( string.isEmpty(value.profile_path))and{ nil }or{
                    Image_tmdb.prefix..Image_tmdb.profile[Image_tmdb.max_ix] .. value.profile_path })[1],
        })
        ::continue_detail_ccc_cast::
    end
    Array.extendUniqueFields(tmpAnimeCharacter,anime.crt,{"name","actor"},true,false)
    tmpAnimeCharacter= tmpAnimeCharacter or{} -- anime_data.person_cast.id = objCr.id
    local tmpAnimeStaff=""
    for _, value in ipairs(anime_data.person_crew or {}) do
        tmpAnimeStaff=tmpAnimeStaff ..( string.isEmpty(value.name) and{ "" }or{
                ((((Translation[settings["metadata_lang"]] or{}).department or{})[value.department] or value.department).."-"..(((Translation[settings["metadata_lang"]] or{}).credit_job or{})[value.job[1]] or (" "..value.job[1]))) ..":"..
                ( string.isEmpty(value.original_name) and{ value.name }or{value.original_name })[1] ..";" })[1]
    end
    anime_data["person_crew"]=anime_data.person_crew or {}
    -- anime_data["person_crew"]=anime_data["person_crew"] or {}
    for _, value in ipairs(objCr.crew or {}) do
        if #(anime_data["person_crew"])>=Metadata_person_max_crew then break end
        local jobText= ((creditTsall)and
                    { Array.extendUnique({},value.jobs,"job") or{} } or
                    { {( string.isEmpty(value.job) and{ nil }or{ value.job })[1]} })[1]
        table.insert(anime_data["person_crew"],{
            -- ["gender"]= (( tonumber(value.gender)==1 or tonumber(value.gender)==2 )and{ tonumber(value.gender) }or{ nil })[1],
            ["name"]= (( string.isEmpty(value.name) )and{
                (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1] }or{ value.name })[1],
            ["original_name"]= (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1],
            ["profile_path"]= (( string.isEmpty(value.profile_path))and{ nil }or{ value.profile_path })[1],
            ["department"]= (( string.isEmpty(value.department))and{ nil }or{ value.department })[1],
            ["job"]= table.deepCopy(jobText),
            ["adult"]= (( string.isEmpty(value.adult) )and{ nil }or{ value.adult })[1],
            ["id"] = tonumber(value.id or""),
            -- ["known_for_department"]= (( string.isEmpty(value.known_for_department)) and{ nil }or{ value.known_for_department })[1],
            -- ["popularity"]= tonumber(value.popularity or""),
            -- ["credit_id"]= (( string.isEmpty(value.credit_id))and{ nil }or{ value.credit_id })[1],
        })
        
        if #(anime_data["person_crew"])>tmpMcCrew then goto continue_detail_ccc_crew end
        for jobI, jobV in ipairs(jobText) do
            -- for jobKw, jobTr in ipairs((Translation[settings["metadata_lang"]] or{}).job or{}) do
            --     jobJ.character = string.gsub(jobJ.character,jobKw or"",jobTr or jobKw or"",1)
            -- end
            jobText[jobI]= ((Translation[settings["metadata_lang"]] or{}).credit_job or{})[jobV] or (""..jobV)
        end
        local tmpAnimeStaffName=""
        if Metadata_info_origin_title then
            tmpAnimeStaffName= ( string.isEmpty(value.original_name) and{ (string.isEmpty(value.name) and
            { nil }or{ value.name })[1] }or{ value.original_name})[1]
        else
            tmpAnimeStaffName= ( string.isEmpty(value.name) and{ (string.isEmpty(value.original_name) and
                    { nil }or{ value.original_name })[1] }or{ value.name })[1]
        end
        tmpAnimeStaff= tmpAnimeStaff ..(((Translation[settings["metadata_lang"]] or{}).department or{})[value.department or""] or value.department or"").."-"..
                    (Array.toStringLine(jobText,",") or"") ..":".. ((string.isEmpty(tmpAnimeStaffName) and{"-"} or{tmpAnimeStaffName})[1]) ..";"
        ::continue_detail_ccc_crew::
    end
    tmpAnimeStaff= tmpAnimeStaff or "" -- anime_data.person_crew.id = objCr.id
    objCr={}
    if anime_data["media_type"]=="tv" and settings["metadata_castcrew_source_cast"]== "TVmaze_show" and not string.isEmpty(anime_data.imdb_id) then
        if tonumber(anime_data.tvmaze_id)==nil then
            local queryTvmz = {}
            local header = {["Accept"] = "application/json"}
            local replyTvmz
            err, replyTvmz = kiko.httpget(string.format("https://api.tvmaze.com/lookup/shows?imdb=" ..
                    anime_data.imdb_id), queryTvmz, header)
            if err ~= nil or (replyTvmz or{}).hasError then
                kiko.log("[ERROR] TVmaze.API.reply-details."..anime_data["media_type"] .. ".cast.httpget: " .. err..
                        (((replyTvmz or{}).hasError) and{" <"..math.floor((replyTvmz or{}).statusCode).."> "..(replyTvmz or{}).errInfo} or{""})[1])
                goto continue_detail_id_tvmz
            end
            local contentTvmz = replyTvmz["content"]
            local err, objTvmz = kiko.json2table(contentTvmz)
            if err ~= nil then
                kiko.log("[ERROR] TVmaze.API.reply-details."..anime_data["media_type"] .. ".cast.json2table: " .. err)
                -- error(err)
                goto continue_detail_id_tvmz
            end
            anime_data.tvmaze_id= ((tonumber(objTvmz.id) ==nil) and{nil} or{tostring(math.floor(tonumber(objTvmz.id)))})[1]
            ::continue_detail_id_tvmz::
        end
        if tonumber(anime_data.tvmaze_id)~=nil then
            local queryTvmz = {}
            local header = {["Accept"] = "application/json"}
            local replyTvmz
            err, replyTvmz = kiko.httpget(string.format("https://api.tvmaze.com/shows/" ..
                    anime_data.tvmaze_id .."/cast"), queryTvmz, header)
            if err ~= nil or (replyTvmz or{}).hasError then
                kiko.log("[ERROR] TVmaze.API.reply-details."..anime_data["media_type"] .. ".cast.httpget: " .. err..
                        (((replyTvmz or{}).hasError) and{" <"..math.floor((replyTvmz or{}).statusCode).."> "..(replyTvmz or{}).errInfo} or{""})[1])
                goto continue_detail_ccc_cast_tvmz
            end
            local contentTvmz = replyTvmz["content"]
            local err, objTvmz = kiko.json2table(contentTvmz)
            if err ~= nil then
                kiko.log("[ERROR] TVmaze.API.reply-details."..anime_data["media_type"] .. ".cast.json2table: " .. err)
                error(err)
                goto continue_detail_ccc_cast_tvmz
            end
            local tmpAnimeCharacterTm= {}
            for _, value in ipairs(objTvmz) do
                value.person=  (table.isEmpty(value.person) and{{}} or{value.person})[1]
                value.character= (table.isEmpty(value.character) and{{}} or{value.character})[1]
                value.person.name=(string.isEmpty(value.person.name) and{"-"} or{value.person.name})[1]
                value.character.name=(string.isEmpty(value.character.name) and{"-"} or{value.character.name})[1]
                for _, crtGpair in ipairs((Translation[settings["metadata_lang"]] or{}).character_gsub or{}) do
                    value.character.name = string.gsub(value.character.name or"",crtGpair[1] or"",crtGpair[2] or crtGpair[1] or"")
                end
                table.insert(tmpAnimeCharacterTm,{
                    ["name"]= (string.isEmpty(value.person.name) and{"-"} or{value.person.name})[1],
                    ["actor"]= (string.isEmpty(value.character.name) and{"-"} or{value.character.name})[1],
                    ["link"]= (( string.isEmpty(value.character.url)) and{ ((string.isEmpty(value.person.url))
                            and{nil} or{value.person.url})[1] } or{value.character.url})[1],
                    ["imgurl"]= (( string.isEmpty((value.character.image or{}).original)) and{ ((string.isEmpty((value.person.image or{}).original))
                            and{nil} or{(value.person.image or{}).original})[1] } or{(value.character.image or{}).original})[1],
                })
            end
            if not table.isEmpty(tmpAnimeCharacterTm) then
                Array.extendUniqueFields(tmpAnimeCharacterTm,anime.crt,{"name","actor"},true,false)
                tmpAnimeCharacter= tmpAnimeCharacterTm or tmpAnimeCharacter or{} -- anime_data.person_cast.id = objCr.id
                -- tmpAnimeCharacterTm= {}
            end
            ::continue_detail_ccc_cast_tvmz::
        end
    end

    local objMc={}
    anime_data.content_rating= {}
    local tmp_content_rating= {}
    if anime_data.media_type=="movie" then
        objMc= table.deepCopy( objMoll.release_dates or{}) or{}
        for _, value in ipairs(objMc.results or{}) do
            local tmp_cr0, tmp_cr3=nil,nil
            for _, vr in ipairs(value.release_dates or{}) do
                if string.isEmpty(tmp_cr0) and not string.isEmpty(vr.certification) then
                    tmp_cr0=vr.certification
                end
                if string.isEmpty(tmp_cr3) and ((tonumber(vr.type) and{ math.floor(tonumber(vr.type))==math.floor(3) }or{ false })[1]) and
                        not string.isEmpty(vr.certification) then
                    tmp_cr3=vr.certification
                end
            end
            if not string.isEmpty(tmp_cr3) or not string.isEmpty(tmp_cr0) then
                table.insert(tmp_content_rating,{
                        ["rating"]= tmp_cr3 or tmp_cr0 or "?",
                        ["origin_region"]=value.iso_3166_1,})
            end
        end
    elseif anime_data.media_type=="tv" then
        objMc= table.deepCopy( objTvll.content_ratings ) or{}
        for _, value in ipairs(objMc.results or{}) do
            if not string.isEmpty(value.rating) then
                table.insert(tmp_content_rating,{
                        ["rating"]=value.rating or"?",
                        ["origin_region"]=value.iso_3166_1,})
            end
        end
    end
    Array.extendUniqueFields(anime_data.content_rating,tmp_content_rating,{"rating","origin_region"},true,false)
    objMc={}

    local objMk,tmp_keyword_names= {},{}
    anime_data.keyword_names= anime_data.keyword_names or{}
    if anime_data.media_type=="movie" or anime_data.media_type=="tv" then
        objMk=  table.deepCopy(((anime_data.media_type=="movie")and{ objMoll.keywords }or{ objTvll.keywords })[1]) or{}
        for _, value in ipairs(objMk[ ((anime_data.media_type=="movie")and{"keywords"}or{"results"})[1] ] or{}) do
            if not string.isEmpty(value.name) then
                table.insert(tmp_keyword_names,{
                        ["id"]=value.id,
                        ["name"]=value.name,})
            end
        end
    end
    Array.extendUniqueFields(anime_data.keyword_names,tmp_keyword_names,{"id","name"},true,false)
    objMk, tmp_keyword_names= {},{}

    local mImgPTmp = "TMDb_only"
    if settings["metadata_image_priority"]=="fanart_prior"
        or settings["metadata_image_priority"]=="TMDb_only"
        or settings["metadata_image_priority"]=="TMDb_prior" then
        mImgPTmp= settings["metadata_image_priority"]
    end
    if mImgPTmp=="fanart_prior" or mImgPTmp=="TMDb_prior" then
        local queryFan = {
            ["api_key"] = settings["api_key_fanart"]
        }
        local header = {["Accept"] = "application/json"}
        if settings["api_key_fanart"] == "<<API_Key_Here>>" then
            kiko.log("Wrong api_key! 请在脚本设置中填写正确的 `fanart的API密钥`。")
            kiko.message("[错误] 请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                    "或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            goto jumpover_fanart_scraping
        end
        local replyFan
        if anime_data["media_type"]=="movie" then
            -- tmdb_id_mo_cr
            err, replyFan = kiko.httpget(string.format("https://webservice.fanart.tv/v3/movies/" ..
                anime_data["media_id"]), queryFan, header)
        elseif anime_data["media_type"]=="tv" and (not string.isEmpty(anime_data["tvdb_id"])) then
            -- tmdb_id_tv_s_cr
            err, replyFan = kiko.httpget(string.format("https://webservice.fanart.tv/v3/tv/" ..
                anime_data["tvdb_id"]), queryFan, header)
        else
            goto jumpover_fanart_scraping
        end
        if err ~= nil or (replyFan or{}).hasError then
            kiko.log("[ERROR] fanart.API.reply-details."..anime_data["media_type"] .. ".httpget: " .. err..
                    (((replyFan or{}).hasError) and{" <"..math.floor((replyFan or{}).statusCode).."> "..(replyFan or{}).errInfo} or{""})[1])
            if tostring(err) == ("Host requires authentication") then
                kiko.message("[错误] 请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                        "或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。",1|8)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            end
            goto jumpover_fanart_scraping
        end
        local contentFan = replyFan["content"]
        local err, objFan = kiko.json2table(contentFan)
        if err ~= nil then
            kiko.log("[ERROR] fanart.API.reply-details."..anime_data["media_type"] .. ".json2table: " .. err)
            error(err)
        end

        local originLang=anime_data.original_language
        if string.isEmpty(originLang) then
            originLang= (table.isEmpty(anime_data.spoken_language) and{originLang}or{anime_data.spoken_language[1]["iso_639_1"]})[1]
        end
        if string.isEmpty(originLang) and anime_data.media_type=="tv" then
            originLang= (table.isEmpty(anime_data.tv_language) and{originLang}or{anime_data.tv_language[1]})[1]
        end
        originLang= (string.isEmpty(originLang) and{""}or{originLang})[1]
        local interfLang=string.sub(settings["metadata_lang"],1,2)
        -- [""]= ( string.isEmpty(value.) and{ nil }or{ value. })[1],
        -- [""]= ( string.isEmpty(value.) and{ nil }or{ tostring(value.)=="true" })[1],
        -- [""]= tonumber(value. or""),
        anime_data["fanart_path"]={}
        local imgPathVoine={}
        local function getFti(value)
            if string.isEmpty(value.url) then
                return nil
            end
            return {
            -- ["id"]= ( string.isEmpty(value.id) and{ nil }or{ value.id })[1],
            ["url"]= ( string.isEmpty(value.url) and{ nil }or{
                string.sub(value.url,Image_fanart.len_preix_size,-1) })[1],
            ["lang"]= ( string.isEmpty(value.lang) and{ nil }or{
                    ( (value.lang=="00") and{ "und" }or{ value.lang })[1], })[1],
            -- ["likes"]= ( string.isEmpty(value.likes) and{ nil }or{ value.likes })[1],
            -- ["disc"]= ( string.isEmpty(value.disc) and{ nil }or{ value.disc })[1],
            ["disc_type"]= ( string.isEmpty(value.disc_type) and{ nil }or{ value.disc_type })[1],
            ["season"]= ( string.isEmpty(value.season) and{ nil }or{ value.season })[1],
        } end
        -- origin-origin  interf-interface  noLang-no.lang  en-en
        local mioiTmp = settings['metadata_info_origin_image']
        if (mioiTmp == '0') then
            Metadata_info_origin_image = false
        elseif (mioiTmp == '1' or mioiTmp == '2') then
            Metadata_info_origin_image = true
        end
        for _,fti in ipairs(Image_fanart[anime_data.media_type]) do
            imgPathVoine={}
            for _, value in ipairs(objFan[fti] or{}) do
                if #imgPathVoine>=4 then
                    break
                end
                if string.isEmpty(value.url) or tonumber(value.season or "")~=nil then
                    goto continue_detail_fan_mfti
                end
                if(imgPathVoine.origin==nil and value.lang==originLang) then
                    imgPathVoine.origin= getFti(value)
                end
                if(imgPathVoine.interf==nil and value.lang==interfLang) then
                    imgPathVoine.interf= getFti(value)
                end
                if(imgPathVoine.noLang==nil and (value.lang=="00" or string.isEmpty(value.lang))) then
                    imgPathVoine.noLang= getFti(value)
                end
                if(imgPathVoine.en==nil and value.lang=="en") then
                    imgPathVoine.en= getFti(value)
                end
                ::continue_detail_fan_mfti::
            end
            anime_data.fanart_path = anime_data.fanart_path or {}
            anime_data.fanart_path[fti] = {}
            anime_data.fanart_path[fti]["origin"] = imgPathVoine.origin or imgPathVoine.noLang
            if Metadata_info_origin_image==true then
                if settings["metadata_info_origin_image"]=="2" then
                    (anime_data.fanart_path or{})[fti]["interf"]= imgPathVoine.noLang or
                            imgPathVoine.origin or imgPathVoine.interf or imgPathVoine.en
                else
                    (anime_data.fanart_path or{})[fti]["interf"]= imgPathVoine.origin or
                            imgPathVoine.noLang or imgPathVoine.interf or imgPathVoine.en
                end
            else
                (anime_data.fanart_path or{})[fti]["interf"]= imgPathVoine.interf or
                        imgPathVoine.origin or imgPathVoine.noLang or imgPathVoine.en
            end
        end
        local imgPathSoine={}
        if anime_data.media_type=="tv" then
            for _,fti in ipairs(Image_fanart.season) do
                imgPathSoine={}
                for _, value in ipairs(objFan[fti] or{}) do
                    if #imgPathSoine>=4 then
                        break
                    end
                    if string.isEmpty(value.url) or not (tonumber(value.season)~=nil
                            and tonumber(value.season)== tonumber(anime_data.season_number)) then
                        goto continue_detail_fan_tfti
                    end
                    if string.isEmpty(value.season) then
                        value.season=""
                    end
                    if(imgPathSoine.origin==nil and value.lang==originLang) then
                        imgPathSoine.origin= table.deepCopy(getFti(value)) or{}
                    end
                    if(imgPathSoine.interf==nil and value.lang==interfLang) then
                        imgPathSoine.interf= table.deepCopy(getFti(value)) or{}
                    end
                    if(imgPathSoine.noLang==nil and (value.lang=="00" or string.isEmpty(value.lang))) then
                        imgPathSoine.noLang= table.deepCopy(getFti(value)) or{}
                    end
                    if(imgPathSoine.en==nil and value.lang=="en") then
                        imgPathSoine.en= table.deepCopy(getFti(value)) or{}
                    end
                    ::continue_detail_fan_tfti::
                end
                anime_data.fanart_path = anime_data.fanart_path or {}
                anime_data.fanart_path[fti] = {}
                anime_data.fanart_path[fti]["origin"] = table.deepCopy(imgPathSoine.origin or imgPathSoine.noLang) or{}
                if Metadata_info_origin_image==true then
                    (anime_data.fanart_path or{})[fti]["interf"]= table.deepCopy(imgPathSoine.origin or
                            imgPathSoine.noLang or imgPathSoine.interf or imgPathSoine.en) or{}
                else
                    (anime_data.fanart_path or{})[fti]["interf"]=
                            table.deepCopy(imgPathSoine.interf or imgPathSoine.noLang or imgPathSoine.en) or{}
                end
            end
        end
    end
    ::jumpover_fanart_scraping::
    local imgLangPri={"origin","interf"}
    if settings["metadata_info_origin_image"]=="1" or settings["metadata_info_origin_image"]=="2" then
        imgLangPri={"origin","interf"}
    elseif settings["metadata_info_origin_image"]=="0" then
        imgLangPri={"interf","origin"}
    end
    local posterUrlTmp,posterUrlT,posterUrlF = nil,nil,nil
    local posterUrlTmpT= (anime_data.tmdb_art_path or{})[anime_data.media_type.."poster"]
    if not table.isEmpty(posterUrlTmpT) then
        if anime_data.media_type=="movie" then
            posterUrlTmpT = posterUrlTmpT[imgLangPri[1]] or posterUrlTmpT[imgLangPri[2]]
        elseif anime_data.media_type=="tv" then
            posterUrlTmpT = posterUrlTmpT[imgLangPri[1]] or posterUrlTmpT[imgLangPri[2]]
            local posterUrlTmpS=(anime_data.tmdb_art_path or{}).seasonposter
            if not table.isEmpty(posterUrlTmpS) then
                posterUrlTmpT = posterUrlTmpS[imgLangPri[1]] or posterUrlTmpS[imgLangPri[1]] or posterUrlTmpT
            end
        end
        if not table.isEmpty(posterUrlTmpT) and not string.isEmpty(posterUrlTmpT.url) then
            posterUrlT = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. posterUrlTmpT.url
        end
    end
    if mImgPTmp=="fanart_prior" or (string.isEmpty(posterUrlT) and mImgPTmp=="TMDb_prior") then
        if anime_data.media_type=="tv" then
            posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][1]] or{})[imgLangPri[1]] or{}).url or"")
        end
        if not string.isEmpty(posterUrlTmp) then
            posterUrlF = Image_fanart.prefix..Image_fanart.size[2]..posterUrlTmp
        else
            posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type][1]] or{})[imgLangPri[1]] or{}).url or"")
            if not string.isEmpty(posterUrlTmp) then
                posterUrlF = Image_fanart.prefix..Image_fanart.size[2]..posterUrlTmp
            elseif mImgPTmp=="fanart_prior" then
                if not string.isEmpty(posterUrlT) then
                    posterUrlF = posterUrlT
                end
            end
        end
    end
    posterUrlF= posterUrlF or posterUrlT

    local titleTmp = "" -- 形如 "media_title (original_title)"
    if not string.isEmpty(anime_data.interf_title) or not string.isEmpty(anime_data.media_title) then
        titleTmp = titleTmp .. (anime_data.interf_title or anime_data.media_title)
        if anime_data["original_title"] then
            titleTmp = titleTmp .. " (" .. anime_data.original_title .. ")"
        end
    else
        if not string.isEmpty(anime_data.original_title) then
            titleTmp = titleTmp .. anime_data.original_title
        end
    end
    -- kiko.log(table.toStringBlock(anime_data))
    local err, media_data_json = kiko.table2json(table.deepCopy(anime_data) or{})
    if err ~= nil then
        kiko.log(string.format("[ERROR] table2json: %s", err))
    end
    -- kiko.log("[TEST]  "..posterUrlTmp)
    local animePlus = {
        ["name"] = anime["name"],
        ["data"] = media_data_json,
        ["url"] = ((not string.isEmpty(anime_data["media_type"])) and {"https://www.themoviedb.org/" ..
                 anime_data["media_type"] .. "/" .. anime_data["media_id"]} or {""})[1], -- 条目页面URL
        ["desc"] = (( string.isEmpty(anime_data.tagline) )and{ (string.isEmpty(anime_data.tagline_origin)and{ "" }
                        or{ anime_data.tagline_origin .."\n\n" })[1] }or { anime_data.tagline .."\n\n" })[1] ..
                    (( string.isEmpty(anime_data.overview_season) )and{ (string.isEmpty(anime_data.overview_season_origin)and{ "" }
                        or{ anime_data.overview_season_origin .."\n\n" })[1] }or { anime_data.overview_season .."\n\n" })[1] ..
                    (( string.isEmpty(anime_data.overview_epgroup) )and{ (string.isEmpty(anime_data.overview_epgroup_origin)and{ "" }
                        or{ anime_data.overview_epgroup_origin .."\n\n" })[1] }or { anime_data.overview_epgroup .."\n\n" })[1] ..
                    (( string.isEmpty(anime_data.overview) )and{ (string.isEmpty(anime_data.overview_origin)and{ "" }
                        or{ anime_data.overview_origin .."\n\n" })[1] }or { anime_data.overview .."\n\n" })[1] ..
                    titleTmp, -- 描述
        ["airdate"] = ((anime_data["release_date"]) and {
                 anime_data["release_date"]} or {anime_data["tv_first_air_date"]})[1] or "", -- 发行日期，格式为yyyy-mm-dd 
        ["epcount"] = anime_data["episode_count"], -- 分集数
        ["coverurl"] = posterUrlF,
        ["staff"] = tmpAnimeStaff, -- staff - "job1:staff1;job2:staff2;..."
        ["crt"] = tmpAnimeCharacter, -- 人物
        ["scriptId"] = "Kikyou.l.TMDb"
    }
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] ..
                     " (" .. anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. ">")
    end
    -- kiko.log("[INFO]  Anime = " .. table.toStringBlock(animePlus))
    return animePlus
end

-- 获取标签
-- anime： Anime
-- 返回： Array[string]，Tag列表
function gettags(anime)
    -- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
    -- kiko.log("[INFO]  Starting getting tags of <" .. anime["name"]..">")
    -- table.toStringLog(anime) -- kiko.log()
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        -- 无媒体信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    -- table.toStringLog(anime_data) -- kiko.log("")
    
    local mtag = {} -- 标签数组
    local genre_name_tmp -- 暂存字符串
    for _, value in pairs(anime_data["genre_names"] or {}) do
        if not string.isEmpty(value) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "流派/".. string.gsub( genre_name_tmp ,"[/]","∕"))
        end
    end
    if anime_data["mo_is_adult"]==true or anime_data["mo_is_adult"]=="true" then
        table.insert(mtag, "流派/成人")
    end
    local mediaKeyword= {}
    Array.extendUnique(mediaKeyword,anime_data.keyword_names,"name")
    for _, value in ipairs(mediaKeyword or {}) do
        if not string.isEmpty(value) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "标签/".. string.gsub( genre_name_tmp ,"[/]","∕"))
        end
    end
    mediaKeyword= {}

    if anime_data.media_type=="movie" and not table.isEmpty(anime_data.mo_belongs_to_collection) and
            not string.isEmpty((anime_data.mo_belongs_to_collection or{}).name) then
        table.insert(mtag, "系列/电影/".. string.gsub( string.gsub(
                anime_data.mo_belongs_to_collection.name,"[ ]*（系列）",""),"[/]","∕"))
    elseif anime_data.media_type=="tv" and tonumber(anime_data.season_count)~=nil and
            math.floor(tonumber(anime_data.season_count))>math.floor(1) then
        table.insert(mtag, "系列/剧集/".. string.gsub( anime_data.media_title ..
                string.format(' (%s)', string.sub(anime_data.tv_first_air_date, 1, 4)),"[/]","∕"))
    end

    if anime_data["media_type"] == "movie" or anime_data["media_type"] == "tv" then
        table.insert(mtag, "类型/".. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[anime_data.media_type] or anime_data.media_type))
    else
        table.insert(mtag, "类型/".. (anime_data.media_type or (Translation["und-XX"] or{}).media_type["Unknown"]))
    end
    if anime_data["tv_type"]~=nil and anime_data["tv_type"]~="" then
        table.insert(mtag, "类型/" .. string.gsub(
                (((Translation[settings["metadata_lang"]] or{}).media_type or{})[anime_data.tv_type or""] or
                (Translation["und-XX"] or{}).media_type[anime_data.tv_type or""]) or anime_data.tv_type ,"[/]","∕"))
    end
    if anime_data.tv_is_epgroup=="true" or anime_data.tv_is_epgroup ==true then
        table.insert(mtag, "类型/" .. string.gsub(
                (((Translation[settings["metadata_lang"]] or{}).media_type_epgroup or{})[anime_data.epgroup_type or""] or
                (Translation["und-XX"] or{}).media_type[anime_data.epgroup_type] or"") or anime_data.epgroup_type,"[/]","∕"))
    end
    if anime_data.mo_is_video==true or anime_data.mo_is_video=="true" then
        table.insert(mtag, "类型/" .. string.gsub(
                (((Translation[settings["metadata_lang"]] or{}).media_type or{})["Movie Video"] or"Video Movie") ,"[/]","∕"))
    end
    if not string.isEmpty(anime_data.status) then
        table.insert(mtag, "状态/" ..  string.gsub( ((Translation[settings["metadata_lang"]] or{}).media_status or{})[anime_data.status] or
                anime_data.status or (Translation["und-XX"] or{}).media_status["Unknown"],"[/]","∕"))
    end
    if anime_data["tv_in_production"]==true or anime_data["tv_in_production"]=="true" then
        table.insert(mtag, "状态/".. (((Translation[settings["metadata_lang"]] or{}).media_status or{})["TV In Production"] or"In Production TV"))
    end
    local mediaLang= {anime_data["original_language"]}
    Array.extendUnique(mediaLang,anime_data["spoken_language"],"iso_639_1")
    Array.extendUnique(mediaLang,anime_data["tv_language"])
    local mediaRegion= table.deepCopy(anime_data["origin_region"]) or{}
    Array.extendUnique(mediaRegion,anime_data["production_region"],"iso_3166_1")
    local mediaCompany={}
    Array.extendUniqueFields(mediaCompany,anime_data["production_company"],{"name","origin_region"},true,false)
    -- Array.extendUnique(mediaCompany,anime_data["tv_network"],"name")
    local mediaNetwork={}
    Array.extendUniqueFields(mediaNetwork,anime_data["tv_network"],{"name","origin_region"},true,false)
    local mediaCRating={}
    Array.extendUniqueFields(mediaCRating,anime_data.content_rating,{"rating","origin_region"},true,false)

    for index, value in ipairs(mediaLang or {}) do
        if not string.isEmpty(value) then
            if index == 1 then
                table.insert(mtag, "语言/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value or (Translation["und-XX"] or{}).language[""] ,"[/]","∕"))
            else
                table.insert(mtag, "语言/+/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value or (Translation["und-XX"] or{}).language[""] ,"[/]","∕"))
            end
        end
    end
    if #(mediaLang or{})==0 then
        table.insert(mtag, "语言/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).language or{})[""] or (Translation["und-XX"] or{}).language[""] ,"[/]","∕"))
    end
    mediaLang={}
    for index, value in ipairs(mediaRegion or {}) do
        if not string.isEmpty(value) then
            -- if index == 1 or index == 2 then
            -- end
            table.insert(mtag, "地区/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value or (Translation["und-XX"] or{}).region[""] ,"[/]","∕"))
            -- table.insert(mtag, "地区/+/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value or (Translation["und-XX"] or{}).region[""] ,"[/]","∕"))
        end
    end
    if #(mediaRegion or{})==0 then
        table.insert(mtag, "地区/".. string.gsub( ((Translation[settings["metadata_lang"]] or{}).region or{})[""] or (Translation["und-XX"] or{}).region[""] ,"[/]","∕"))
    end
    -- mediaRegion={}

    for _, value in ipairs(mediaCRating or {}) do
        if (not string.isEmpty(value.rating)) then
            genre_name_tmp = ( string.isEmpty(value.origin_region) and{ (Translation["und-XX"] or{}).region["Unknown"] }or
                    { string.gsub(((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region or (Translation["und-XX"] or{}).region["Unknown"] ,"[/]","∕") })[1] ..
                            "/".. string.gsub( value.rating ,"[/]","∕")
            local isRon= false
            for _, ron in ipairs(Tag_rating_on_region) do
                if ron== value.origin_region then
                    isRon= true
                    break
                end
            end
            table.insert(mtag, "分级/"..((isRon) and{ "" }or{ "+/" })[1].. genre_name_tmp)
        end
    end
    mediaCRating={}
    for _, value in ipairs(mediaCompany or {}) do
        if (not string.isEmpty(value.name)) then
            genre_name_tmp = ( string.isEmpty(value.origin_region) and{ (Translation[settings["metadata_lang"]] or{}).region[""] or (Translation["und-XX"] or{}).region[""] }or
                    { string.gsub(((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region or (Translation["und-XX"] or{}).region[""],"[/]","∕") })[1] ..
                    "/".. string.gsub( value.name ,"[/]","∕")
            local flagInRegion=false
            if not string.isEmpty(value.origin_region) then
                for _,v in ipairs(mediaRegion) do
                    if v==value.origin_region then
                        flagInRegion=true
                        break
                    end
                end
            end
            if flagInRegion or string.isEmpty(value.origin_region) then
                table.insert(mtag, "公司/".. genre_name_tmp)
            else
                table.insert(mtag, "公司/+/".. genre_name_tmp)
            end
        end
    end
    mediaCompany={}
    for _, value in ipairs(mediaNetwork or {}) do
        if (not string.isEmpty(value.name)) then
            genre_name_tmp = ( string.isEmpty(value.origin_region) and{ (Translation[settings["metadata_lang"]] or{}).region[""] or (Translation["und-XX"] or{}).region[""] }or
                    { string.gsub(((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region or (Translation["und-XX"] or{}).region[""],"[/]","∕") })[1] ..
                    "/".. string.gsub( value.name ,"[/]","∕")
            local flagInRegion=false
            if not string.isEmpty(value.origin_region) then
                for _,v in ipairs(mediaRegion) do
                    if v==value.origin_region then
                        flagInRegion=true
                        break
                    end
                end
            end
            if flagInRegion or string.isEmpty(value.origin_region) then
                table.insert(mtag, "平台/".. genre_name_tmp)
            else
                table.insert(mtag, "平台/+/".. genre_name_tmp)
            end
        end
    end
    mediaNetwork={}

    kiko.log("[INFO]  Finished getting " .. #mtag .. " tags of < " .. anime["name"] .. ">")
    return mtag
end

-- 实现自动关联功能。提供此函数的脚本会被加入到播放列表的“关联”菜单中)
-- path：视频文件全路径 -  path/to/video.ext
-- 返回：MatchResult
-- 读取 Emby 在媒体文件夹存储的 媒体信息文件 -  path/to/video.nfo
--     与媒体文件同目录同名的文本文档，文本格式为 .xml
function match(path)
    -- local err, fileHash = kiko.hashdata(path, true, 16*1024*1024)
    kiko.log('[INFO]  Matching path - <' .. path .. '> - ' .. #path)
    -- 获取 是否 元数据使用原语言标题
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end

    local mediainfo, epinfo = {}, {} -- 返回的媒体信息、分集信息 AnimeLite:mediainfo EpInfo:epinfo
    --- 判断关联匹配的信息来源类型
    if settings["match_source"] == "online_TMDb_filename" then
        if (kiko.regex) == nil then
            kiko.message("错误! 版本过旧或不支持，请更换KikoPlay至合适的版本。",1|8)
            kiko.log("[Error] Using outdated or unsupported version!")
            kiko.execute(true, "cmd", {"/c", "start", "https://github.com/KikoPlayProject/KikoPlay#%E4%B8%8B%E8%BD%BD"})
            error("[Error] Using outdated or unsupported version!")
        end
        local mType = "" -- 媒体类型
        -- 模糊媒体信息：标题，季序数，集序数,集序数拓展,标题拓展,集类型
        local mTitle,mSeason,mEp,mEpX,mTitleX,mEpType = "","","","","",""
        local mPriority=1 -- x选取搜索结果
        local resultSearch,resultGetep = {},{} -- 影剧搜索结果、集识别
        local epTypeMap = {["EP"]=1, ["SP"]=2, ["OP"]=3, ["ED"]=4, ["TR"]=5, ["MA"]=6, ["OT"]=7,[""]=1} --仅针对特别篇的InfoRaw
        local epTypeName = {"正片", "特别篇", "片头", "片尾", "预告", "MAD", "其他片段"} --仅针对特别篇的Info展示

        --获取模糊媒体标题
        mTitle = string.gsub(path,"","")
        mType = ""

        -- 从文件名获取获取模糊媒体信息
        -- path: tv\season\video.ext | movie\video.ext
        local path_folder_sign, _ = string.findre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        local path_file_name = string.sub(path, path_folder_sign + 1) -- 媒体文件名称.拓展名 - video.ext
        local resMirbf=Path.getMediaInfoRawByFilename(path_file_name)
        -- 获取 文件名粗识别 结果
        mTitle=resMirbf[1] or ""
        mSeason=resMirbf[2] or ""
        mEp=resMirbf[3] or ""
        mEpX=resMirbf[4] or ""
        mTitleX=resMirbf[5] or ""
        mEpType=resMirbf[6] or ""

        --判断媒体类型
        local mIsSp=false -- 是否为特别篇
        if mEpType~="" and mEpType~="EP" then
            mIsSp=true
        end
        if mEp~="" or mSeason~="" then
            mType="tv"
        -- 其他的，按照 设置项"匹配 - 备用媒体类型"。 -- 无集序数，无集类型
        elseif settings["match_priority"]=="movie" then
            mType="movie" -- 电影
        elseif settings["match_priority"]=="tv" then
            mType="tv" -- 剧集
        elseif settings["match_priority"]=="multi" then
            mType="multi" -- 排序靠前的影/剧
        elseif settings["match_priority"]=="single" then
            local resDiaTF, _ = kiko.dialog({
                ["title"] = "是否确定此媒体属于 <电影> ？",
                ["tip"] = "<" .. mTitle .. ">： 确认->电影。 取消->剧集。",
            })
            -- 从对话框确定媒体类型
            if resDiaTF == "accept" or resDiaTF == true then
                mType="movie"
            elseif resDiaTF == "reject" or resDiaTF == false then
                mType="tv"
                mIsSp=true
            else
                mType="multi"
            end
        else
            mType="multi"
        end

        if mType == "movie" then
            mSeason=1 -- 电影默认 S01E01 (EP)
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,nil,mType)
            if #resultSearch < mPriority then
                kiko.log("[ERROR] Failed to find movie <"..mTitle..">.")
                kiko.message("无法找到电影 <"..mTitle..">。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end
            mediainfo=resultSearch[mPriority]
            
            -- epInfo
            if mIsSp == false then
                local mEpTmp=1
                resultGetep = getep(mediainfo)
                if #resultGetep < mEpTmp then
                    kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                    kiko.message("无法找到电影 <"..mTitle..">。", 1)
                    return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                end
                epinfo=resultGetep[mEpTmp]
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    kiko.log("[ERROR] Failed to find movie <"..mTitle.."> " .. ": " .. epTypeName[epinfo["type"]] ..
                                (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。")
                    kiko.message("无法找到电影 <"..mTitle.."> " .. "的 " .. epTypeName[epinfo["type"]] ..
                                (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1)
                    return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                end
            end
        elseif mType == "tv" then
            -- Season=="" -> S00/S01。
            local mSeasonTv = ""
            if mSeason == "" then
                mSeasonTv = ((mIsSp)and{0}or{1})[1]
            else mSeasonTv = math.floor(tonumber(mSeason))
            end
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,nil,mType)
            for _, value in ipairs(resultSearch or {}) do
                if mSeasonTv ~= 0 then
                    if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                        mediainfo=value
                        mType=mediainfo["media_type"]
                        break
                    end
                else
                    -- Specials
                    if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) or
                        value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) then
                        mediainfo=value
                        mType=mediainfo["media_type"]
                        break
                    end
                end
            end
            if table.isEmpty(mediainfo) then
                kiko.log("[ERROR] Failed to find tv <"..mTitle.."> ".. (((mSeason=="")and{""}or{" < Season"..mSeason.." >"})[1]).."。")
                kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end

            -- EpX：提示，并弃用
            if mEpX ~= "" then
                mEpX=math.floor(tonumber(mEpX))
                kiko.log("[INFO]  Recognized redundant episode number <"..(mEpX or "").."> in tv <"..(mTitle or "")..">, which is ignored here.")
                kiko.message("识别到 <"..((mTitle.."> 的") or "").."拓展集序号: <"..(mEpX or "")..">。\n" ..
                            "此处弃用，请稍后确认此剧集的集序号是否正确", 1)
            end
            -- epInfo
            local mEpTmp = nil
            if mEp == "" then
                mEpTmp=1
            else mEpTmp=math.floor(tonumber(mEp))
            end
            if mIsSp == false then
                resultGetep = getep(mediainfo)
                for _, value in ipairs(resultGetep or {}) do
                    if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                        epinfo=value
                        break
                    end
                end
                if table.isEmpty(epinfo) then
                    kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season"..mSeason})[1])..">" ..
                                (((mEp=="")and{""}or{" <Episode "..mEp..">"})[1]).."。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1)
                    return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"] = math.floor(tonumber(mEpTmp)),["type"]=1,},}
                end
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    kiko.log("[ERROR] Failed to find  <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> "..
                            " in " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                            (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> "..
                            "的 " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format("%02d",mEp)})[1])..
                            (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1)
                    -- kiko.log("[TEST]  "..type(os.time2EpiodeNum()).." - "..os.time2EpiodeNum())
                    return {["success"] = true, ["anime"] = mediainfo,
                            ["ep"] = {["name"]= (string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1] ,
                                    ["index"]=os.time2EpiodeNum(),
                                    ["type"]=math.floor(((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType] or 7})[1])},}
                end
            end
        else
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,nil,"multi")
            if #resultSearch < mPriority then
                kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                kiko.message("无法找到媒体 <"..mTitle..">。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end
            local mSeasonTv = ""
            for _, value in ipairs(resultSearch or {}) do
                if mSeason =="" and value["media_type"] == "movie" then
                    if mIsSp == false and mEp ~= "" then
                        goto continue_match_OMul_Mnfo
                    end
                    mSeason=1
                    mediainfo=value
                    mType=mediainfo["media_type"]
                    break
                elseif value["media_type"]=="tv" then
                    if mSeason == "" then
                        mSeasonTv = ((mIsSp)and{0}or{1})[1]
                    else mSeasonTv = math.floor(tonumber(mSeason))
                    end
                    if mSeasonTv ~= 0 then
                        if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                            mediainfo=value
                            mType=mediainfo["media_type"]
                            break
                        else goto continue_match_OMul_Mnfo
                        end
                    else
                        -- Specials
                        if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) or
                            value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) then
                            mediainfo=value
                            mType=mediainfo["media_type"]
                            break
                        else goto continue_match_OMul_Mnfo
                        end
                    end
                end
                ::continue_match_OMul_Mnfo::
            end
            if table.isEmpty(mediainfo) then
                if mSeason ~="" or (mEp ~= "" and mIsSp ==false)  then
                    kiko.log("[ERROR] Failed to find tv <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <Season "..mSeason..">"})[1]).."。")
                    kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1)
                else
                    kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                    kiko.message("无法找到媒体 <"..mTitle..">。", 1)
                end
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"] = math.floor(tonumber(mEp)) or os.time2EpiodeNum()},["type"]=7,}
            end

            -- mEpX=math.floor(tonumber(mEpX))
            if mEpX ~= "" then
                kiko.log("Recognized redundant episode number <"..(mEpX or "").."> of"..(mTitle or "")..", which is ignored here.")
                kiko.message("识别到 <"..((mTitle.."> 的") or "").."拓展集序号: <"..(mEpX or "")..">。\n" ..
                            "此处弃用，请稍后确认此剧集的集序号是否正确", 1)
            end
            -- epInfo
            if mIsSp == false then
                if mType == "tv" then
                    local mEpTmp = nil
                    if mEp == "" then
                        mEpTmp=1
                    else mEpTmp=math.floor(tonumber(mEp))
                    end
                    resultGetep = getep(mediainfo)
                    for _, value in ipairs(resultGetep or {}) do
                        if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                            epinfo=value
                            break
                        end
                    end
                    if table.isEmpty(epinfo) then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1])..">" ..
                                    (((mEp=="")and{""}or{" <Episode"..mEp..">"})[1]).."。")
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                    (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1)
                        return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                    end
                elseif mType == "movie" then
                    mEp=1
                    resultGetep = getep(mediainfo)
                    if #resultGetep < mEp then
                        kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                        kiko.message("无法找到电影 <"..mTitle..">。", 1)
                        return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                    end
                    epinfo=resultGetep[mEp]
                end
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    local tmpLogStr = "的 " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format("%02d",mEp)})[1])..
                                        (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。"
                    if epinfo["type"] == "movie" then
                        kiko.log("[ERROR] Failed to find movie <"..mTitle.."> " .. tmpLogStr)
                        kiko.message("无法找到电影 <"..mTitle.."> " .. tmpLogStr, 1)
                    elseif epinfo["type"] == "tv" then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> ".. tmpLogStr)
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> ".. tmpLogStr, 1)
                    else
                        kiko.log("[ERROR] Failed to find media <"..mTitle.."> " .. tmpLogStr)
                        kiko.message("无法找到媒体 <"..mTitle.."> " .. tmpLogStr, 1)
                    end
                    return {["success"] = true, ["anime"] = mediainfo,
                            ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1], ["index"]=os.time2EpiodeNum(),["type"]=math.floor(((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1])},}
                end
            end
        end

        kiko.log("(" .. (mType or "") .. ") " .. (mediainfo["name"] or "") .. "  -  " ..
                 "(" .. (epTypeName[epinfo["type"]] or "") .. ") " .. (epinfo["index"] or "") .. (epinfo["name"] or ""))
        kiko.log("Finished matching online succeeded.")

        mediainfo.scriptId = "Kikyou.l.TMDb"
        return {
            ["success"] = true,
            ["anime"] = mediainfo,
            ["ep"] = epinfo,
        }
    elseif settings["match_source"] == "local_Emby_nfo" then

        -- 获取需要的各级目录
        -- string.gmatch(path,"\\[%S ^\\]+",-1)
        -- path: tv\season\video.ext  lff\lf\l  Emby 存储剧集的目录 -  tv/tvshow.nfo  tv/season/season.nfo
        -- path: movie\video.ext      l\        Emby 存储电影的目录 -  movie/video.nfo
        local path_file_sign, _ = string.findre(path, ".", -1) -- 路径索引 文件拓展名前'.' path/to/video[.]ext
        local path_folder_sign, _ = string.findre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        -- kiko.log('TEST  - '..path_file_sign)
        -- kiko.log('TEST  - '..path_folder_sign)
        local path_file_name = string.sub(path, path_folder_sign + 1,
                                        path_file_sign - 1) -- 媒体文件名称 不含拓展名 - video
        local path_folder_l = string.sub(path, 1, path_folder_sign) -- 父文件夹路径 含结尾'/' -  tv/season/   movie/
        path_folder_sign, _ = string.findre(path, "/", path_folder_sign - 1) -- 路径索引 父父文件夹尾'/' path[/]to/video.ext
        local path_folder_lf = string.sub(path, 1, path_folder_sign) -- 父父文件夹路径 含结尾'/' -  tv/

        -- 读取媒体信息.nfo文件 (.xml文本)
        local xml_file_path = path_folder_l .. path_file_name .. '.nfo' -- 媒体信息文档全路径 path/to/video.nfo 文本为 .xml 格式
        local xml_v_nfo = Path.readxmlfile(xml_file_path) -- 获取媒体信息文档
        if xml_v_nfo == nil then
            -- 文件读取失败
            kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
            error("Fail to read xml content from <" .. xml_file_path .. ' >.')
            -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
            -- 返回
            return {["success"] = false};
        end

        -- xml_v_nfo
        -- 读取的媒体信息文本暂存在这里
        -- local mname, mdata, murl, mdesc, mairdate, mepcount, mcoverurl, mstaff, mcrt = nil, {}, nil, nil, nil, nil, nil,
        local mname, mdata, mepcount = nil, {}, nil
        local myear = nil
        -- 读取的分集信息文本暂存在这里
        local ename, eindex, etype, eseason = nil, nil, nil, nil
        -- 读取的分季信息文本暂存在这里
        -- tstitle = season title
        local tstitle = nil
        -- 读取的 .xml 信息文本暂存在这里
        local tmpElem -- 临时存 xml_v_nfo:elemtext()
        while not xml_v_nfo:atend() do
            -- 循环，直到读取到末尾
            if xml_v_nfo:startelem() then
                -- 如果是开始标签，就获取 媒体类型信息，分类电影/剧集
                -- movie
                if xml_v_nfo:name() == "movie" then
                    -- 是电影
                    kiko.log('[INFO]  \t Reading movie nfo')
                    mdata["media_type"] = "movie" -- 媒体类型
                    -- mdata["poster_path"] = "" .. path_folder_l .. "poster.jpg" -- Emby存储的电影 海报路径
                    -- mdata["background_path"] = "" .. path_folder_l .. "fanart.jpg" -- Emby存储的电影 背景路径
                    kiko.log('[INFO]  Reading movie nfo')

                    -- 读取下一个标签
                    xml_v_nfo:readnext()
                    while not xml_v_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_v_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            -- read metadata
                            if xml_v_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_v_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_v_nfo:name() == "title" then
                                -- "标题"标签
                                mdata["media_title"] = tmpElem
                                -- if not (Metadata_info_origin_title) then
                                --     mname = mdata["media_title"]
                                -- end
                            elseif xml_v_nfo:name() == "originaltitle" then
                                -- "原始标题"标签
                                mdata["original_title"] = tmpElem
                                -- if Metadata_info_origin_title then
                                --     mname = mdata["original_title"]
                                -- end
                            elseif xml_v_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                -- mdesc = tmpElem
                                mdata["overview"] = string.gsub(tmpElem, "\r?\n\r?\n", "\n") -- 去除空行
                            elseif xml_v_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                -- 处理职员表字符串信息
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= {"Director"},
                                    })
                                end
                            elseif xml_v_nfo:name() == "rating" then
                                -- "评分"标签
                                mdata["vote_average"] = tmpElem
                            elseif xml_v_nfo:name() == "year" then
                                -- "播映年份"标签
                                if tmpElem ~= nil and tmpElem ~= "" then
                                    -- 无标签内容
                                    myear = tmpElem
                                elseif mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                                    -- 读取首映/发行日期的年份
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                                -- elseif xml_v_nfo:name()=="content" then
                                -- mcoverurl = tmpElem
                                -- elseif xml_v_nfo:name() == "sorttitle" then
                                --     mdata["sort_title"] = tmpElem
                            elseif xml_v_nfo:name() == "mpaa" then
                                -- "媒体分级/mpaa"标签
                                mdata["rate_mpaa"] = tmpElem
                            elseif xml_v_nfo:name() == "tmdbid" then
                                -- "tmdb的ID"标签
                                mdata["media_id"] = string.format("%d", tmpElem)
                                -- if mdata["media_id"] ~= nil then
                                --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                                -- end
                            elseif xml_v_nfo:name() == "imdbid" then
                                -- "imdb的id"标签
                                mdata["media_imdbid"] = tmpElem
                            elseif xml_v_nfo:name() == "premiered" then -- 首映
                                -- "首映日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                            elseif xml_v_nfo:name() == "releasedate" then -- 发行
                                -- "发行日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                            elseif xml_v_nfo:name() == "country" then
                                -- "国家"标签
                                if mdata["origin_region"] == nil then
                                    mdata["origin_region"] = {}
                                end
                                table.insert(mdata["origin_region"], tmpElem)
                            elseif xml_v_nfo:name() == "genre" then
                                -- "流派类型-名称"标签
                                if mdata["genre_names"] == nil then
                                    mdata["genre_names"] = {}
                                end
                                table.insert(mdata["genre_names"], tmpElem)
                            elseif xml_v_nfo:name() == "studio" then
                                -- "出品 公司/工作室"标签
                                if mdata["production_company"] == nil then
                                    mdata["production_company"] = {}
                                end
                                table.insert(mdata["production_company"], tmpElem)
                            elseif xml_v_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    -- 初始化table
                                    mdata["person_cast"] = {}
                                end
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- 读取下一个标签
                                xml_v_nfo:readnext()
                                -- read actors in .nfo
                                while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_v_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_v_nfo:elemtext() .. ""
                                        if xml_v_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_v_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_v_nfo:name() == "tmdbid" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            -- elseif xml_v_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
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
                                -- 向演员信息<table>插入一个演员的信息
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["actor"] = cactor, -- 演员名称
                                    ["url"] = clink -- 人物资料页URL
                                    -- ["imgurl"]=cimgurl,  --人物图片URL
                                })
                                -- xml_v_nfo_crt=nil
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_v_nfo:readnext()
                    end
                    -- xml_v_nfo:clear()

                    -- 把电影视为单集电视剧，初始化单集信息，
                    mepcount, ename, eindex, etype = 1, "", 1, 1

                    -- 获取电影标题，是否原语言标题
                    if Metadata_info_origin_title then
                        mname = mdata["original_title"]
                        -- kiko.log("T " .. mname)
                    else
                        mname = mdata["media_title"]
                        -- kiko.log("F " .. mname)
                    end
                    -- kiko.log("OOO " .. mname .. "\t" .. tostring(Metadata_info_origin_title))
                    -- 单集标题
                    ename = mdata["media_title"]

                    -- 把媒体信息<table>转为json的字符串
                    local err, movie_data_json = kiko.table2json(table.deepCopy(mdata) or{})
                    if err ~= nil then
                        -- 转换错误
                        kiko.log(string.format("[ERROR] table2json: %s", err))
                    end
                    -- 媒体信息表
                    mediainfo = {
                        ["name"] = mname, -- 电影标题
                        ["data"] = movie_data_json, -- 脚本可以自行存放一些数据，table转为json的字符串
                        -- ["url"] = murl, -- 条目页面再tmdb的URL
                        -- ["desc"] = mdesc, -- 剧集剧情描述
                        -- ["airdate"] = mairdate, -- 发行日期，格式为yyyy-mm-dd
                        ["epcount"] = mepcount -- 分集数
                        -- ["coverurl"]=mcoverurl,      --封面图URL
                        -- ["staff"] = mstaff, -- 职员表，格式的字符串
                        -- ["crt"] = mcrt -- 人物/演员表 <table>
                    }
                    -- 从 媒体信息的发行日期/年份 获取年份字符串，加到电影名后，以防重名导致kiko数据库错误。形如 "电影名 (2010)"
                    -- get "Movie Name (YEAR)"
                    if mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                        mediainfo["name"] = mname .. string.format(' (%s)', string.sub(mdata["release_date"], 1, 4))
                    elseif myear ~= nil and myear ~= "" then
                        mediainfo["name"] = mname .. string.format(' (%s)', myear)
                    end
                    -- 单集信息表
                    epinfo = {
                        ["name"] = ename, -- 分集名称
                        ["index"] = eindex, -- 分集编号（索引）
                        ["type"] = etype -- 分集类型
                    }
                    -- 跳出标签读取循环
                    break

                    -- tv_show
                elseif xml_v_nfo:name() == "episodedetails" then
                    -- 是剧集
                    mdata["media_type"] = "tv" -- 媒体类型
                    kiko.log('[INFO]  \t Reading tv episode nfo')

                    -- xml_v_nfo:startelem()
                    -- 读取下一个标签
                    xml_v_nfo:readnext()
                    -- read metadata
                    while not xml_v_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_v_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_v_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_v_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            -- kiko.log("GE "..xml_v_nfo:name().."\t"..tmpElem)
                            if xml_v_nfo:name() == "title" then
                                -- "单集标题"标签
                                ename = tmpElem
                            elseif xml_v_nfo:name() == "episode" then
                                -- "本集序数"标签
                                eindex = tonumber(tmpElem)
                            elseif xml_v_nfo:name() == "season" then
                                -- "本季序数"标签
                                if (tmpElem ~= nil and tmpElem ~= '') then
                                    mdata["season_number"] = tonumber(tmpElem) -- 本季序数转为数字
                                    -- S00 == Specials
                                    -- 分集类型: EP, SP, OP, ED, Trailer, MAD, Other 分别用1-7表示，默认为1（即EP，本篇）
                                    if mdata["season_number"] == 0 then
                                        -- 0季/特别篇/SP
                                        etype = 2
                                    else
                                        -- 普通集/本篇/EP
                                        etype = 1
                                    end
                                end

                            elseif xml_v_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                -- 处理职员表字符串信息
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= {"Director"},
                                    })
                                end
                            elseif xml_v_nfo:name() == "actor" then
                                -- xml_v_nfo:readnext()
                                -- ignore actors
                                -- while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                --     -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>'..tmpElem)
                                --     xml_v_nfo:readnext()

                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    mdata["person_cast"] = {}
                                end
                                -- kiko.log("TEST  - Actor tag"..tmpElem)
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- 读取下一个标签
                                xml_v_nfo:readnext()
                                -- read actors in .nfo
                                while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_v_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_v_nfo:elemtext() .. ""
                                        if xml_v_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_v_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_v_nfo:name() == "tmdbId" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            -- clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            clink = tmpElem
                                            -- elseif xml_v_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_v_nfo:readnext()
                                end
                                -- 向演员信息<table>插入一个演员的信息
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["original_name"] = cname, -- 人物名称
                                    ["character"] = cactor, -- 演员名称
                                    ["department"]= "Actors",
                                    ["job"]={"Actor"},
                                    ["id"] = tonumber(clink or""),
                                })
                                -- kiko.log(table.toStringLine(mdata["person_cast"]))
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_v_nfo:readnext()
                    end
                    -- xml_v_nfo:clear()

                    kiko.log('[INFO]  \t Reading tv season nfo')
                    -- 读取单季信息.nfo文件 (.xml文本)
                    local xml_ts_path = path_folder_l .. 'season.nfo' -- 单季信息.nfo文件路径
                    local xml_ts_nfo = Path.readxmlfile(xml_ts_path) -- 读取.xml格式文本
                    if xml_ts_nfo == nil then
                        -- 文件读取失败
                        kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
                        error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                        -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                        return {["success"] = false};
                    end
                    while (xml_ts_nfo:endelem()) or xml_ts_nfo:name() ~= "season" do
                        xml_ts_nfo:readnext()
                    end
                    -- read metadata
                    xml_ts_nfo:readnext()
                    while not xml_ts_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_ts_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_ts_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_ts_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_ts_nfo:name() == "title" then
                                -- "标题"标签
                                tstitle = tmpElem
                            elseif xml_ts_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                mdata["overview"] = string.gsub(tmpElem, "\r?\n\r?\n", "\n") -- 去除空行
                            elseif xml_ts_nfo:name() == "premiered" then
                                -- "首播日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                                if (myear == nil or myear == "") and mdata["release_date"] ~= nil and
                                    mdata["release_date"] ~="" then
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                            elseif xml_ts_nfo:name() == "releasedate" then
                                -- "发行日期"标签
                                local elemtext_tmp = tmpElem
                                if (mdata["release_date"] == nil or mdata["release_date"] == "") and elemtext_tmp ~= nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                                -- 获取年份
                                if (myear == nil or myear == "") and mdata["release_date"] ~= nil and mdata["release_date"] ~="" then
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                            elseif xml_ts_nfo:name() == "seasonnumber" then
                                -- "本季序数"标签
                                if (mdata["season_number"] == nil and tmpElem ~= nil and tmpElem ~= '') then
                                    mdata["season_number"] = tonumber(tmpElem)
                                    if mdata["season_number"] == 0 then
                                        -- 0季/特别篇/SP
                                        etype = 2
                                    else
                                        -- 普通集/本篇/EP
                                        etype = 1
                                    end
                                end
                                -- elseif xml_ts_nfo:name()=="content" then
                                -- mepcount = tmpElem

                            elseif xml_ts_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    mdata["person_cast"] = {}
                                end
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                xml_ts_nfo:readnext()
                                -- read actors in .nfo
                                while xml_ts_nfo:name() ~= "actor" or not (not xml_ts_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_ts_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_ts_nfo:elemtext() .. ""
                                        if xml_ts_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_ts_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_ts_nfo:name() == "tmdbId" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            -- elseif xml_ts_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_ts_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_ts_nfo:readnext()
                                end
                                -- 未去重
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["original_name"] = cname, -- 人物名称
                                    ["character"] = cactor, -- 演员名称
                                    ["department"]= "Actors",
                                    ["job"]={"Actor"},
                                    ["id"] = tonumber(clink or""),
                                })
                                -- kiko.log(table.toStringLine(mdata["person_cast"]))
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_ts_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_ts_nfo:readnext()
                    end
                    xml_ts_nfo:clear()

                    kiko.log('[INFO]  \t Reading tv nfo')
                    local xml_tv_path = path_folder_lf .. 'tvshow.nfo' -- 单季信息.nfo文件路径
                    local xml_tv_nfo = Path.readxmlfile(xml_tv_path) -- 读取.xml格式文本
                    if xml_tv_nfo == nil then
                        -- 文件读取失败
                        kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
                        error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                        -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                        return {["success"] = false};
                    end
                    while (xml_tv_nfo:endelem()) or xml_tv_nfo:name() ~= "tvshow" do
                        xml_tv_nfo:readnext()
                        end
                    -- read metadata
                    xml_tv_nfo:readnext()
                    while not xml_tv_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_tv_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_tv_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_tv_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_tv_nfo:name() == "title" then
                                -- "标题"标签
                                mdata["media_title"] = tmpElem
                                -- if not (Metadata_info_origin_title) then
                                --     mname = mdata["media_title"]
                                -- end
                            elseif xml_tv_nfo:name() == "originaltitle" then
                                -- "原语言标题"标签
                                mdata["original_title"] = tmpElem
                                -- if Metadata_info_origin_title then
                                --     mname = mdata["original_title"]
                                -- end
                            elseif xml_tv_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                -- mdesc = tmpElem
                                if mdata["overview"] ~= nil then
                                mdata["overview"] = string.gsub(mdata["overview"], "\r?\n\r?\n", "\n") .. "\r\n" -- 去除空行
                                else
                                    mdata["overview"] = ""
                                end
                            mdata["overview"] = mdata["overview"] .. string.gsub(tmpElem, "\r?\n\r?\n", "\n")
                                -- elseif xml_tv_nfo:name()=="content" then
                                -- mcoverurl = tmpElem
                            elseif xml_tv_nfo:name() == "rating" then
                                -- "评分"标签
                                mdata["vote_average"] = tmpElem
                                -- elseif xml_tv_nfo:name() == "sorttitle" then
                                --     mdata["sort_title"] = tmpElem
                            elseif xml_tv_nfo:name() == "mpaa" then
                                -- "媒体分级/mpaa"标签
                                mdata["rate_mpaa"] = tmpElem
                            elseif xml_tv_nfo:name() == "tmdbid" then
                                -- "tmdb的ID"标签
                            mdata["media_id"] = string.format("%d", tonumber(tmpElem))
                                -- if mdata["media_id"] ~= nil then
                                --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                                -- end
                            elseif xml_tv_nfo:name() == "imdbid" then
                                -- "imdb的id"标签
                                mdata["media_imdbid"] = tmpElem
                            elseif xml_tv_nfo:name() == "country" then
                                -- "国家"标签
                                if mdata["origin_region"] == nil then
                                    mdata["origin_region"] = {}
                                end
                                table.insert(mdata["origin_region"], tmpElem)
                            elseif xml_tv_nfo:name() == "genre" then
                                -- "流派类型-名称"标签
                                if mdata["genre_names"] == nil then
                                    mdata["genre_names"] = {}
                                end
                                table.insert(mdata["genre_names"], tmpElem)
                            elseif xml_tv_nfo:name() == "studio" then
                                -- "出品 公司/工作室"标签
                                if mdata["production_company"] == nil then
                                    mdata["production_company"] = {}
                                end
                                table.insert(mdata["production_company"], tmpElem)
                            elseif xml_tv_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= {"Director"},
                                    })
                                end
                            mdata["person_staff"] = mdata["person_staff"] .. "Director:" .. tmpElem .. ';' -- Director-zh
                            elseif xml_tv_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    -- 初始化table
                                    mdata["person_cast"] = {}
                                end
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- read actors of tv
                                xml_tv_nfo:readnext()
                            while xml_tv_nfo:name() ~= "actor" or not (not xml_tv_nfo:startelem()) do
                                -- 循环，直到读取到"演员"的结束标签
                                if xml_tv_nfo:startelem() then
                                    tmpElem = xml_tv_nfo:elemtext() .. ""
                                    if xml_tv_nfo:name() == "role" then
                                        -- "角色名"标签
                                        cname = tmpElem
                                    elseif xml_tv_nfo:name() == "name" then
                                        -- "演员名"标签
                                        cactor = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_tv_nfo:name()..'>'..tmpElem)
                                end
                                xml_tv_nfo:readnext()
                            end
                            table.insert(mdata["person_cast"], {
                                ["name"] = cname, -- 人物名称
                                ["original_name"] = cname, -- 人物名称
                                ["character"] = cactor, -- 演员名称
                                ["department"]= "Actors",
                                ["job"]={"Actor"},
                            })
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_tv_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_tv_nfo:readnext()
                end
                xml_tv_nfo:clear()

                -- 添加本地海报/背景图片
                -- TODO 此处功能无效：传入的是 "D:/.../poster.jpg"
                --[[
                local file_exist_test, file_exist_test_err, path_file_image_tmp
                    if mdata["season_number"] ~= nil then
                        if mdata["season_number"] ~= "0" then
                            -- 普通季
                            path_file_image_tmp = path_folder_lf .. "season" ..
                                 string.format('S%02d', mdata["season_number"]) .. "-poster.jpg" -- season08-poster.jpg
                        else
                            -- 特别篇
                            path_file_image_tmp = path_folder_lf .. "season" ..
                                                  string.format('-specials', mdata["season_number"]) .. "-poster.jpg" -- season-specials-poster.jpg
                        end
                    file_exist_test, file_exist_test_err = io.open(path_file_image_tmp)
                        if file_exist_test_err == nil then
                            -- 文件存在
                            io.close(file_exist_test)
                            mdata["poster_path"] = path_file_image_tmp
                        else
                            mdata["poster_path"] = path_folder_lf .. "poster.jpg"
                        end
                        mdata["background_path"] = path_folder_lf .. "fanart.jpg"
                    end
                    -- kiko.log("match - poster_path > ".. mdata["poster_path"])
                    ]]--
                    -- 把媒体信息<table>转为json的字符串
                local err, ts_data_json = kiko.table2json(table.deepCopy(mdata) or{})
                    if err ~= nil then
                        kiko.log(string.format("[ERROR] table2json: %s", err))
                    end
                    -- get "TV Name S01"
                    if mdata["season_number"] ~= nil then
                        -- 不处理 tstitle 里的特殊 季标题
                        if not (Metadata_info_origin_title) then
                            -- 目标语言标题
                        mname = mdata["media_title"] .. ' 第' .. mdata["season_number"] .. "季"
                        else
                            -- 原语言标题
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
                    -- 媒体信息表
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
                    -- 从 媒体信息的发行日期/年份 获取年份字符串，加到剧集名称+季序数后，以防重名导致kiko数据库错误。形如 "剧集名 第2季 (2010)"
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
        --[[
        -- kiko.log("[INFO]  <mediainfo>")
        -- kiko.log(table.toStringBlock(mediainfo))
        -- kiko.log("[INFO]  <epinfo>")
        -- kiko.log(table.toStringBlock(epinfo))
        -- kiko.log("TEST  - others")
        -- kiko.log("| mname, mdata, murl, mairdate, myear | ename, eindex, etype, | mdata["season_number"], tstitle |")
        -- kiko.log("| mname, mdata, myear | ename, eindex, etype, | eseason, tstitle |")
        -- kiko.log('|', mname, '*', mdata, '*', murl, '*', mairdate, '*', myear)
        -- kiko.log('|', mname, '*', table.toStringLine(mdata), '*', myear)
        -- kiko.log('|', ename, '*', tostring(eindex), '*', tostring(etype))
        -- kiko.log('|', tostring(eseason), '*', tstitle, '|')
        ]]--

        -- 返回 MatchResult格式
        return {
            ["success"] = true,
            ["anime"] = mediainfo,
            ["ep"] = epinfo
        }
    end

    kiko.log("Failed to match.")
    return {
        ["success"] = false,
        ["anime"] = {},
        ["ep"] = {},
    }
    -- ::continue_match_a::
end

-- Table，类型为 Array[LibraryMenu]
-- 如果资料库条目的scriptId和当前脚本的id相同，条目的右键菜单中会添加menus包含的菜单项，用户点击后会通过menuclick函数通知脚本
menus = {{
        ["title"] = "打开媒体主页",
        ["id"] = "open_webpage_media_home",
    },{
        ["title"] = "打开TMDb/IMDb页面",
        ["id"] = "open_webpage_media_page",
    },{
        ["title"] = "使用豆瓣/贴吧搜索",
        ["id"] = "open_webpage_media_search",
    },{
        ["title"] = "使用Bagumi搜索",
        ["id"] = "open_webpage_media_anime",
    },{
        ["title"] = "打开fanart页面",
        ["id"] = "open_webpage_media_artwork",
    },{
        ["title"] = "使用字幕搜索",
        ["id"] = "open_webpage_subtitle_multiple",
    },{
        ["title"] = "显示媒体元数据",
        ["id"] = "show_media_matadata",
    -- },{
    --     ["title"] = "显示媒体元数据表",
    --     ["id"] = "show_media_matadata_table",
    -- },{
    --     ["title"] = "标记为 /已看过",
    --     ["id"] = "account_sync_history",
    -- },{
    --     ["title"] = "标记为 /已收集",
    --     ["id"] = "account_sync_collection",
    -- },{
    --     ["title"] = "标记为 /稍后看",
    --     ["id"] = "account_sync_watchlist",
    -- },{
    --     ["title"] = "标记为 /评分",
    --     ["id"] = "account_sync_rating",
}}

-- 用户点击条目的右键菜单中的menus菜单后，会通过menuclick函数通知脚本
function menuclick(menuid, anime)
    -- menuid： string，点击的菜单ID
    -- anime： Anime， 条目信息
    -- 返回：无
    kiko.log("Menu Click: ", menuid)
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    if anime_data.season_title == string.format("第 %d 季", anime_data.season_number) then
        anime_data.season_title= string.format("第%d季", anime_data.season_number)
    end

    if menuid == "open_webpage_media_page" then
        kiko.log("Open library page of <"..anime["name"]..">.")
        kiko.message("打开 <"..anime["name"].."> 的TMDb/IMDb/Trakt资料页，\n使用TVmaze搜索", NM_HIDE)
        if not string.isEmpty(anime["url"]) then
            kiko.execute(true, "cmd", {"/c", "start", anime["url"]})
        else
            kiko.message("未找到 <"..anime["name"].."> 的TMDb页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        if not string.isEmpty(anime_data.imdb_id) then
            kiko.execute(true, "cmd", {"/c", "start", "https://www.imdb.com/title/"..anime_data.imdb_id})
            kiko.execute(true, "cmd", {"/c", "start", "https://trakt.tv/shows/"..anime_data.imdb_id})
        else
            kiko.message("未找到 <"..anime["name"].."> 的IMDb页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        if not string.isEmpty(anime_data.media_title) then
            kiko.execute(true, "cmd", {"/c", "start", "https://www.tvmaze.com/search?q=".. string.gsub(anime_data.original_title, "[ %c%p\'\"%^%&%|<>]","+")})
        else
            kiko.message("未找到 <"..anime["name"].."> 的相关搜索页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        local textPb= anime_data.media_title.." "..(anime_data.original_title or "").. (string.isEmpty(anime_data.season_title) and{ "" }or{ " "..anime_data.season_title })[1]
        Kikoplus.systemAddToPasteboard(textPb,"< "..textPb.." >")
    elseif menuid == "open_webpage_media_search" then
        kiko.log("Open searching page of <"..anime["name"]..">.")
        kiko.message("使用豆瓣/贴吧/B站搜索 <"..anime["name"]..">", NM_HIDE)
        if not string.isEmpty(anime_data.media_title) then
            kiko.execute(true, "cmd", {"/c", "start", "https://tieba.baidu.com/f/search/fm?ie=UTF-8^&qw=".. string.gsub(anime_data.media_title, "[ %c%p%^%&%|<>]", "%%20")})
            kiko.execute(true, "cmd", {"/c", "start", "https://www.douban.com/search?cat=1002^&q=".. string.gsub(anime_data.media_title
                    -- .." "..(((anime_data.media_type=="movie" or (anime_data.season_count or anime_data.season_number)==1) and{""} or{anime_data.season_title or""})[1])
                    ,"[ %c%p\'\"%^%&%|<>]","%%20")})
            kiko.execute(true, "cmd", {"/c", "start", "https://search.bilibili.com/all?keyword=".. string.gsub(anime_data.media_title.." ".. (anime_data.season_title or""),
                    "[ %c%p\'\"%^%&%|<>]","+")})
        else
            kiko.message("未找到 <"..anime["name"].."> 的相关搜索页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        local textPb= anime_data.media_title.." "..(anime_data.original_title or "").. (string.isEmpty(anime_data.season_title) and{ "" }or{ " "..anime_data.season_title })[1]
        Kikoplus.systemAddToPasteboard(textPb,"< "..textPb.." >")
    elseif menuid == "open_webpage_media_anime" then
        kiko.log("Open anime page of <"..anime["name"]..">.")
        kiko.message("使用Bangumi/AniDb/AniList搜索 <"..anime["name"]..">", NM_HIDE)
        if not string.isEmpty(anime_data.media_title) then
            kiko.execute(true, "cmd", {"/c", "start", "https://bgm.tv/subject_search/".. string.gsub(anime_data.media_title,
                    "[ %c%p\'\"%^%&%|<>]","+") .."?cat=all"})
        else
            kiko.message("未找到 <"..anime["name"].."> 的Bangumi搜索页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        if not string.isEmpty(anime_data.original_title) then
            kiko.execute(true, "cmd", {"/c", "start", "https://anidb.net/search/fulltext/?adb.search=".. string.gsub(anime_data.original_title,
                    "[ %c%p\'\"%^%&%|<>]","%%20") .."&do.search=1&entity.animetb=1&entity.collectiontb=1&field.titles=1"})
            kiko.execute(true, "cmd", {"/c", "start", "https://anilist.co/search/anime?search=".. string.gsub(anime_data.original_title,
                    "[ %c%p\'\"%^%&%|<>]","%%20")})
        else
            kiko.message("未找到 <"..anime["name"].."> 的相关搜索页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
        local textPb= anime_data.media_title.." "..(anime_data.original_title or "").. (string.isEmpty(anime_data.season_title) and{ "" }or{ " "..anime_data.season_title })[1]
        Kikoplus.systemAddToPasteboard(textPb,"< "..textPb.." >")
    elseif menuid == "open_webpage_media_home" then
        kiko.log("Open home page of <"..anime["name"]..">.")
        if not string.isEmpty(anime_data.homepage_path) then
            kiko.message("打开 <"..anime["name"].."> 的媒体主页", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", string.gsub(anime_data.homepage_path, "([%^%&%|<>])", "^%1") })
        else
            kiko.message("未找到 <"..anime["name"].."> 的媒体主页。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_media_artwork" then
        kiko.log("Open fanart page of <"..anime["name"]..">.")
        if anime_data.media_type=="movie" then
            if not string.isEmpty(anime_data.media_id) then
                kiko.message("打开 <"..anime["name"].."> 的fanart页面", NM_HIDE)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/movie/"..anime_data.media_id})
            else
                kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
            end
        elseif anime_data.media_type=="tv" then
            if not string.isEmpty(anime_data.tvdb_id) then
                kiko.message("打开 <"..anime["name"].."> 的fanart页面", NM_HIDE)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/series/"..anime_data.tvdb_id})
            else
                kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
            end
        else
            kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_subtitle_multiple" then
        kiko.log("Open multiple subtitle page of <"..anime["name"].."> by IMDb id.")
        kiko.message("打开 <"..anime["name"].."> 的字幕搜索页面", NM_HIDE)
        
        local tmpLangO, tmpSeasont, tmpTitleO, tmpTitleM = "","","", ""
        tmpLangO= (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]
        if not string.isEmpty(anime_data.original_title or anime_data.original_title) then
            if anime_data.media_type=="tv" and not string.isEmpty(anime_data.season_number) and tonumber(anime_data.season_number)~=nil then
                tmpSeasont=tmpSeasont.."%20S"..string.format("%02d",math.floor(tonumber( anime_data.season_number )))
            end
            tmpTitleM= string.gsub(anime_data.media_title or"" ,"[ %c%p%^%&%|<>]","+")
            if tmpLangO=="en" then
                tmpTitleO= (string.isEmpty(anime_data.original_title)and{anime_data.media_title}or{anime_data.original_title})[1]
                tmpTitleO= string.gsub(tmpTitleO,"[ %c%p%^%&%|<>]","+")
            else
                tmpTitleO= tmpTitleM
            end
            
            kiko.execute(true, "cmd", {"/c", "start", "https://zmk.pw"})
            -- kiko.execute(true, "cmd", {"/c", "start", "https://zmk.pw/search?q="..tmpTitleO})
            kiko.execute(true, "cmd", {"/c", "start", "https://subhd.tv/search/"..string.gsub(tmpTitleO,"[ %c%p%^%&%|<>]","%%20")})
            kiko.execute(true, "cmd", {"/c", "start", "https://www.yysub.net/search/index?keyword="..tmpTitleO.."^&search_type="})
            kiko.execute(true, "cmd", {"/c", "start",
                    "https://bbs.acgrip.com/search.php?mod=forum^&searchid=^&orderby=lastpost^&ascdesc=desc^&searchsubmit=yes^&kw="..tmpTitleM})
        end
        if not string.isEmpty(anime_data.imdb_id) then
            kiko.execute(true, "cmd", {"/c", "start", "https://www.opensubtitles.com/zh-CN/zh-CN,zh-TW,"..tmpLangO..
                        "/search-all/q-".. anime_data.imdb_id.. "/hearing_impaired-include/machine_translated-include/trusted_sources-"})
        else
            kiko.message("未找到 <"..anime["name"].."> 的IMDb id。\n请右键资料夹尝试更新详细信息。", NM_HIDE|NM_ERROR)
        end
    
        local textPb= anime_data.media_title.." "..anime_data.original_title.. (string.isEmpty(anime_data.season_title) and{ "" }or{ " "..anime_data.season_title })[1]
        Kikoplus.systemAddToPasteboard(textPb,"< "..textPb.." >")
    elseif menuid == "show_media_matadata_table" then
        kiko.viewtable(anime_data)
        kiko.viewtable(anime)
    elseif menuid == "show_media_matadata" then
        -- 显示媒体元数据
        -- kiko.log(os.time)
        -- local tipString="" -- 显示的媒体元数据文本
        -- 把媒体信息"data"的json的字符串转为<table>
        -- table.toStringLog(anime_data) -- kiko.log("")
        local tmpString, tipString, tipStringT, tipStringTC = "", "", "", 1
        -- 格式化输出字符串
        tmpString = anime["name"]
        -- tipString = tipString .. "媒体标题：\t" .. (tmpString or "").."\n"
        tipString = tipString .. "标题：\t\t" .. (anime_data.interf_title or anime_data.media_title or "")
                    ..(string.isEmpty(anime_data.original_title) and{""} or{"   |   "..anime_data.original_title})[1]
        -- tipString = tipString .. "\n原标题：\t\t" .. (anime_data["original_title"] or "")
        if anime_data["media_type"]=="movie" then
            tipString = tipString .. "\n首映：\t\t"
        elseif anime_data["media_type"]=="tv" then
            tipString = tipString .. "\n季标题：\t\t" .. (anime_data.season_title or "")
            if anime_data.tv_is_epgroup == "true" or anime_data.tv_is_epgroup == true then
                tipString = tipString .. "\n版本标题：\t\t" .. (anime_data.epgroup_title or "")
                tipString = tipString .. "\n剧集首播：\t"
            else
                tipString = tipString .. "\n首播：\t\t"
            end
        else tipString = tipString .. "\n首映/首播：\t"
        end
        tmpString = anime["airdate"]
        tipString = tipString .. (tmpString or anime_data["release_date"] or "")
        if not string.isEmpty(anime_data["tagline"] or anime_data.tagline_origin) then
            tipString = tipString .. "\n标语：\t\t".. (anime_data.tagline or anime_data.tagline_origin or "")
        end

        tipString = tipString .. "\n类型：\t\t"
        if anime_data.media_type == "movie" or anime_data.media_type == "tv" then
            tipString = tipString .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[anime_data.media_type] or anime_data.media_type or"")
        else
            tipString = tipString .. (anime_data.media_type or (Translation["und-XX"] or{}).media_type["Unknown"])
        end
        if not string.isEmpty(anime_data.tv_type) then
            tipString = tipString .. ", " .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})[anime_data.tv_type] or anime_data.tv_type or (Translation["und-XX"] or{}).media_type[""])
        end
        if not string.isEmpty(anime_data.epgroup_type) then
            tipString = tipString .. ", " .. (((Translation[settings["metadata_lang"]] or{}).media_type_epgroup or{})[anime_data.epgroup_type] or anime_data.epgroup_type or (Translation["und-XX"] or{}).media_type_epgroup[""])
        end
        if anime_data.mo_is_video==true or anime_data.mo_is_video=="true" then
            tipString = tipString .. ", " .. (((Translation[settings["metadata_lang"]] or{}).media_type or{})["Movie Video"] or"Video Movie")
        end
        if not string.isEmpty(anime_data.status) then
            tipString = tipString .. "\n状态：\t\t".. (((Translation[settings["metadata_lang"]] or{}).media_status or{})[anime_data.status] or
                    anime_data.status or (Translation["und-XX"] or{}).media_status["Unknown"])
            if anime_data["tv_in_production"]==true or anime_data["tv_in_production"]=="true" then
                tipString = tipString ..", ".. (((Translation[settings["metadata_lang"]] or{}).media_status or{})["TV In Production"] or"In Production TV")
            end
        end
        if not table.isEmpty(anime_data.mo_belongs_to_collection) and not string.isEmpty(anime_data.mo_belongs_to_collection.name) then
            tipString = tipString .. "\n系列：\t\t" .. string.gsub(anime_data.mo_belongs_to_collection.name,"[ ]*（系列）","")
        elseif anime_data.media_type=="tv" and tonumber(anime_data.season_count)~=nil and
                math.floor(tonumber(anime_data.season_count))>math.floor(1) then
            tipString = tipString .. "\n系列：\t\t" .. (anime_data.media_title ..
                    string.format(' (%s)', string.sub(anime_data.tv_first_air_date, 1, 4)))
        end
        tipString = tipString .. "\n流派：\t\t" .. (Array.toStringLine(anime_data["genre_names"]) or "")
        if anime_data["mo_is_adult"]==true or anime_data["mo_is_adult"]=="true" then
            tipString = tipString .. (#(anime_data["genre_names"])==0 and{""}or{", "})[1].. (((Translation[settings["metadata_lang"]] or{}).media_genre or{})["Adult"] or"Adult")
        end
        local mediaLang= {anime_data["original_language"]}
        Array.extendUnique(mediaLang,anime_data["spoken_language"],"iso_639_1")
        Array.extendUnique(mediaLang,anime_data["tv_language"])
        local mediaRegion= table.deepCopy(anime_data["origin_region"]) or{}
        Array.extendUnique(mediaRegion,anime_data["production_region"],"iso_3166_1")
        if not table.isEmpty(mediaLang) or not table.isEmpty(mediaRegion) then
            tipString = tipString .. "\n语言地区：\t"
            if not table.isEmpty(mediaLang) then
                for index, value in ipairs(mediaLang) do
                    mediaLang[index]= ((Translation[settings["metadata_lang"]] or{}).language or{})[value] or value
                end
                tipString = tipString .. (Array.toStringLine(mediaLang) or "")
            end
            if not table.isEmpty(mediaLang) and not table.isEmpty(mediaRegion) then
                tipString = tipString .. "  |  "
            end
            if not table.isEmpty(mediaRegion) then
                for index, value in ipairs(mediaRegion) do
                    mediaRegion[index]= ((Translation[settings["metadata_lang"]] or{}).region or{})[value] or value
                end
                tipString = tipString .. (Array.toStringLine(mediaRegion) or "")
            end
        end
        mediaLang= {}
        mediaRegion= {}
        tmpString = anime["epcount"]
        if anime_data["media_type"]~="movie" then
            tipString = tipString .. "\n本季季序号/集数：\t" .. string.format("%-5s",tmpString or tostring(math.floor(tonumber(anime_data["season_number"]))) or "")
                    .."/    ".. (tmpString or tostring(math.floor(tonumber(anime_data["episode_count"]))) or "")
            if anime_data.tv_is_epgroup == "true" or anime_data.tv_is_epgroup == true then
                tipString = tipString .. "\n版本总季数/集数：\t" .. string.format("%-5s",tmpString or tostring(math.floor(tonumber(anime_data["season_count_eg"]))) or "")
                        .."/    ".. (tmpString or tostring(math.floor(tonumber(anime_data["episode_total_eg"]))) or "")
            end
            tipString = tipString .. "\n剧集总季数/集数：\t" .. string.format("%-5s",tmpString or tostring(math.floor(tonumber(anime_data["season_count"]))) or "")
                    .."/    ".. (tmpString or tostring(math.floor(tonumber(anime_data["episode_total"]))) or "")
        end
        if not string.isEmpty(anime_data["runtime"]) and anime_data["runtime"]~=0.0 then
            tipString = tipString .. "\n时长：\t\t" .. anime_data["runtime"][1]
        end
        if not string.isEmpty(anime_data["vote_average"]) and anime_data["vote_average"]~=0.0 then
            tipString = tipString .. "\nTMDb评分：\t" .. (anime_data["vote_average"] or "")
        end
        if not string.isEmpty(anime_data["mo_budget"]) and anime_data["mo_budget"]~=0.0 then
            tipString = tipString .. "\n预算：\t\t" .. anime_data["mo_budget"]
        end
        if not string.isEmpty(anime_data["mo_revenue"]) and anime_data["mo_revenue"]~=0.0 then
            tipString = tipString .. "\n收入：\t\t" .. anime_data["mo_revenue"]
        end

        local mediaNetwork={}
        Array.extendUniqueFields(mediaNetwork,anime_data["tv_network"],{"name","origin_region"},true,false)
        local mediaCompany={}
        Array.extendUniqueFields(mediaCompany,anime_data["production_company"],{"name","origin_region"},true,false)
        -- Array.extendUnique(mediaCompany,anime_data["tv_network"],"name")
        local mediaKeyword={}
        Array.extendUnique(mediaKeyword,anime_data.keyword_names,"name")
        local mediaCRating={}
        Array.extendUniqueFields(mediaCRating,anime_data.content_rating,{"rating","origin_region"},true,false)
        if not table.isEmpty(mediaNetwork) then
            tmpString= {}
            for _, value in ipairs(mediaNetwork or {}) do
                if (not string.isEmpty(value.name)) then
                    table.insert(tmpString,value.name ..(string.isEmpty(value.origin_region) and{ "" }or
                            { " (".. (((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region) ..")" })[1])
                end
            end
            tipString = tipString .. "\n平台：\t\t" .. (Array.toStringLine(tmpString) or "")
        end

        if not string.isEmpty(anime_data["tv_first_air_date"]) then
            tipString = tipString .. "\n剧集首播：\t" .. anime_data["tv_first_air_date"]
        end
        if not string.isEmpty(anime_data["tv_last_air_date"]) then
            tipString = tipString .. "\n剧集最新：\t" .. anime_data["tv_last_air_date"]
        end
        if not table.isEmpty(anime_data.update_info) then
            tipString = tipString .. "\n本地数据更新：\t" ..
                    (string.isEmpty(anime_data.update_info.timestamp) and{""} or{os.date("%Y-%m-%d %H:%M:%S",anime_data.update_info.timestamp)})[1]
                    ..(string.isEmpty(anime_data.update_info.version) and{""} or{" | v".. anime_data.update_info.version})[1]
                    -- ..(string.isEmpty(anime_data.update_info.level_detail) and{""} or{" | ".. anime_data.update_info.level_detail})[1]
        end

        mediaNetwork={}
        tipStringT= tipStringT.. string.sub(tipString,tipStringTC)
        -- tipStringTC= string.len(tipString)+1
        tipString = "\n" .. tipString
        if not table.isEmpty(mediaKeyword) then
            tipString = "标签：\t\t".. (Array.toStringLine(mediaKeyword) or "") .."\n"..tipString
        end
        mediaKeyword= {}
        if not table.isEmpty(mediaCompany) then
            tmpString= {}
            for _, value in ipairs(mediaCompany or {}) do
                if (not string.isEmpty(value.name)) then
                    table.insert(tmpString,value.name ..(string.isEmpty(value.origin_region) and{ "" }or
                            { " (".. (((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region) ..")" })[1])
                end
            end
            tipString = "公司：\t\t" .. (Array.toStringLine(tmpString) or "") .."\n"..tipString
        end
        mediaCompany= {}
        if not table.isEmpty(mediaCRating) then
            tmpString= {}
            for _, value in ipairs(mediaCRating or {}) do
                if (not string.isEmpty(value.rating)) then
                    table.insert(tmpString,value.rating ..(string.isEmpty(value.origin_region) and{ "" }or
                            { " (".. (((Translation[settings["metadata_lang"]] or{}).region or{})[value.origin_region] or value.origin_region) ..")" })[1])
                end
            end
            tipString = "分级：\t\t" .. (Array.toStringLine(tmpString) or "") .."\n"..tipString
        end
        mediaCRating={}
        if not string.isEmpty(anime_data["homepage_path"]) then
            tipString = "媒体主页：\t" .. anime_data["homepage_path"] .."\n"..tipString
        end

        tipString = tipString .. "\n"
        tipString = tipString .. (string.isEmpty(anime_data.overview_season or anime_data.overview_season_origin) and{""}or
                { "\n本季介绍：\t" .. (anime_data.overview_season or anime_data.overview_season_origin or "") })[1]
        tipString = tipString .. (string.isEmpty(anime_data.overview_epgroup or anime_data.overview_epgroup_origin) and{""}or
                { "\n版本介绍：\t" .. (anime_data.overview_epgroup or anime_data.overview_epgroup_origin or "") })[1]
        tipString = tipString .. "\n"..((anime_data.media_type~="movie")and{"剧集"}or{"电影"})[1] .."介绍：\t" ..
                (anime_data.overview or anime_data.overview_origin or "")
        
        for _, castT in ipairs(anime_data.person_cast or{}) do
            if type(castT.character)~="table" then
                for _, crtGpair in ipairs((Translation[settings["metadata_lang"]] or{}).character_gsub or{}) do
                    castT.character = string.gsub(castT.character or"",crtGpair[1] or"",crtGpair[2] or crtGpair[1] or"")
                end
            else
                for crtI, crtV in ipairs(castT.character or{}) do
                    for _, crtGpair in ipairs((Translation[settings["metadata_lang"]] or{}).character_gsub or{}) do
                        castT.character[crtI] = string.gsub(castT.character[crtI] or"",crtGpair[1] or"",crtGpair[2] or crtGpair[1] or"")
                    end
                end
            end
        end
        for _, crewT in ipairs(anime_data.person_crew or{}) do
            if type(crewT.job)~="table" then
                crewT.job= ((Translation[settings["metadata_lang"]] or{}).credit_job or{})[crewT.job] or (""..crewT.job) or""
            else
                for jobI, jobV in ipairs(crewT.job or{}) do
                    crewT.job[jobI]= ((Translation[settings["metadata_lang"]] or{}).credit_job or{})[jobV] or (""..jobV) or""
                end
            end
        end
        tipString = tipString .. "\n\n演员表：\t\t\n"
        if table.isEmpty(anime_data.person_cast) then
            for _, value in ipairs(anime.crt or {}) do
                tipString = tipString ..""..string.format("%-17s",value.actor or"").."\t\t\t"..(value.name or"").."\n"
            end
        else
            for _, value in ipairs(anime_data.person_cast or {}) do
                tipString = tipString ..""..string.format("%-17s",value.original_name or value.name or"").."\t\t\t"..(Array.toStringLine(value.character or"") or"").."\n"
            end
        end
        tipString = tipString .. "\n职员表：\t\t\n"
        if table.isEmpty(anime_data.person_crew) then
            for djobstr, value in ipairs(anime.staff or {}) do
                tipString = tipString..""..string.format("%-17s",djobstr or "").."\t\t\t"..(value or"").."\n"
            end
        else
            for _, value in ipairs(anime_data.person_crew or {}) do
                tipString = tipString..""..string.format("%-17s",(((Translation[settings["metadata_lang"]] or{}).department or{})[value.department] or value.department or"")..
                        "-".. (Array.toStringLine(value.job or"") or"") ) .."\t\t\t"..(value.original_name or value.name or"").."\n"
            end
        end

        tipString = tipString .. "\n"
        if not string.isEmpty(anime_data["imdb_id"]) then
            tipString = tipString .. "\nIMDb：\t\t" .. anime_data["imdb_id"]
        end
        if not string.isEmpty(anime_data["tvdb_id"]) then
            tipString = tipString .. "\nTVDb：\t\t" .. anime_data["tvdb_id"]
        end
        tmpString = anime["url"]
        tipString = tipString .. "\nTMDb链接：\t" .. (tmpString or "")
        tmpString = anime["coverurl"]
        tipString = tipString .. "\n海报链接：\t" .. (tmpString or "")
        
        local function getStrArtImage(value, fiType, prefix_size)
            local tmpLine="\n"
            tmpLine= tmpLine..string.format("%4s",fiType or "").."("..string.format("%4s",((Translation[settings["metadata_lang"]] or{}).language or{})[value.lang] or (Translation["und-XX"] or{}).language[""])
            if not string.isEmpty(value.disc_type) then
                tmpLine= tmpLine..","..string.format("%6s",value.disc_type or"")
            end
            if not string.isEmpty(value.season) then
                tmpLine= tmpLine..","..string.format("%02s",value.season or"")
            end
            tmpLine= tmpLine.. ")\t"
            if not string.isEmpty(value.url) then
                tmpLine= tmpLine..prefix_size..(value.url or"")
            end
            return tmpLine
        end
        for fTypei, value in pairs(anime_data.tmdb_art_path or {}) do
            for oisField, oisPath in pairs(value) do
                if oisField=="origin" then
                    tipString = tipString .. getStrArtImage(oisPath,(Image_fanart.type_zh[fTypei] or fTypei).." ",Image_tmdb.prefix..((Image_tmdb[fTypei] or{})[Image_tmdb.max_ix] or "original"))
                elseif oisField=="interf" then
                    tipString = tipString .. getStrArtImage(oisPath,(Image_fanart.type_zh[fTypei] or fTypei).." ",Image_tmdb.prefix..((Image_tmdb[fTypei] or{})[Image_tmdb.max_ix] or "original"))
                end
            end
        end
        for fTypei, value in pairs(anime_data.fanart_path or {}) do
            for oisField, oisPath in pairs(value) do
                if oisField=="origin" then
                    tipString = tipString .. getStrArtImage(oisPath,(Image_fanart.type_zh[fTypei] or fTypei).." ",Image_fanart.prefix..Image_fanart.size[2])
                elseif oisField=="interf" then
                    tipString = tipString .. getStrArtImage(oisPath,(Image_fanart.type_zh[fTypei] or fTypei).." ",Image_fanart.prefix..Image_fanart.size[2])
                end
            end
        end
        
        tipString = tipString .. "\n\n> 此区域的所有编辑 都不可保存哦~"
        local dataString = ""
        if anime_data == nil then
            -- 无媒体信息
            kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        else
            -- 有anime["data"]字段
            dataString = table.toStringBlock(anime_data or "", 1) .. dataString
        end
        tipString = tipString .. "\n\n其他：\t\n" .. dataString --

        -- tipString=string.gsub(tipString,"\t","    ")
        -- kiko.log(tipString)
        -- kiko.log(dataString)
        -- kiko.dialog 疑似不支持多行显示？
        -- resTF ∈ ["accept","reject"]
        
        -- 获取 背景图 的二进制数据
        -- local sizeOfFanart,sizeOfTMDb = 2,5
        local mImgPTmp = "TMDb_only"
        if settings["metadata_image_priority"]=="fanart_only"
            or settings["metadata_image_priority"]=="TMDb_only"
            or settings["metadata_image_priority"]=="TMDb_prior" then
            mImgPTmp= settings["metadata_image_priority"]
        end
        local imgLangPri={"origin","interf"}
        if settings["metadata_info_origin_image"]=="1" or settings["metadata_info_origin_image"]=="2" then
            imgLangPri={"origin","interf"}
        elseif settings["metadata_info_origin_image"]=="0" then
            imgLangPri={"interf","origin"}
        end
        local function getImgPath(sign)
            local paramImgFth={ ["poster"]= {["img_fx"]=1,["header_suffix"]="jpeg",},
                            ["banner"]= {["img_fx"]=2,["header_suffix"]="jpeg",},
                            ["thumb"]= {["img_fx"]=3,["header_suffix"]="jpeg",},
                            ["background"]= {["img_fx"]=4,["header_suffix"]="jpeg",},
                            ["logo"]= {["img_fx"]=5,["header_suffix"]="png",},
                            ["logoL"]= {["img_fx"]=6,["header_suffix"]="png",},
                            ["art"]= {["img_fx"]=7,["header_suffix"]="png",},
                            ["artL"]= {["img_fx"]=8,["header_suffix"]="png",},
                            ["otherart"]= {["img_fx"]=9,["header_suffix"]="png",},
                        }
            local paramImgPath= paramImgFth[sign]
            if paramImgPath==nil then return "" end

            local backgUrlTmp,backgUrlT,backgUrlF,backgUrlTp,backgUrlFp = nil,nil,nil,nil,nil
            local backgUrlTmpT= (anime_data.tmdb_art_path or{})[anime_data.media_type..sign]
            if not table.isEmpty(backgUrlTmpT) then
                if anime_data.media_type=="movie" then
                    backgUrlTmpT = backgUrlTmpT[imgLangPri[1]] or backgUrlTmpT[imgLangPri[2]]
                elseif anime_data.media_type=="tv" then
                    backgUrlTmpT = backgUrlTmpT[imgLangPri[1]] or backgUrlTmpT[imgLangPri[2]]
                    local backgUrlTmpS=(anime_data.tmdb_art_path or{})["season"..sign]
                    if not table.isEmpty(backgUrlTmpS) then
                        backgUrlTmpT = backgUrlTmpS[imgLangPri[1]] or backgUrlTmpS[imgLangPri[2]] or backgUrlTmpT
                    end
                end
                if not table.isEmpty(backgUrlTmpT) and not string.isEmpty(backgUrlTmpT.url) then
                    backgUrlT = Image_tmdb.prefix..Image_tmdb.background[Image_tmdb.max_ix] .. backgUrlTmpT.url
                    backgUrlTp = Image_tmdb.prefix..Image_tmdb.background[Image_tmdb.min_ix] .. backgUrlTmpT.url
                end
            end
            if mImgPTmp=="fanart_prior" or (string.isEmpty(backgUrlT) and mImgPTmp=="TMDb_prior") then
                if anime_data.media_type=="tv" then
                    backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][paramImgPath.img_fx]] or{})[imgLangPri[1]] or{}).url or
                    (((anime_data.fanart_path or{})[Image_fanart["season"][paramImgPath.img_fx]] or{})[imgLangPri[2]] or{}).url or"")
                end
                if not string.isEmpty(backgUrlTmp) then
                    backgUrlF = Image_fanart.prefix..Image_fanart.size[Image_fanart.max_ix]..backgUrlTmp
                    backgUrlFp = Image_fanart.prefix..Image_fanart.size[Image_fanart.min_ix]..backgUrlTmp
                else
                    backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type][paramImgPath.img_fx]] or{})[imgLangPri[1]] or{}).url or
                            (((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type][paramImgPath.img_fx]] or{})[imgLangPri[2]] or{}).url or"")
                    if not string.isEmpty(backgUrlTmp) then
                        backgUrlF = Image_fanart.prefix..Image_fanart.size[Image_fanart.max_ix]..backgUrlTmp
                        backgUrlFp = Image_fanart.prefix..Image_fanart.size[Image_fanart.min_ix]..backgUrlTmp
                    elseif mImgPTmp=="fanart_prior" then
                        if not string.isEmpty(backgUrlT) then
                            backgUrlF = backgUrlT
                            backgUrlFp = backgUrlTp
                        end
                    end
                end
            end
            backgUrlF= backgUrlF or backgUrlT
            backgUrlFp= backgUrlFp or backgUrlTp

            return {["path"]=backgUrlF,["path_preview"]=backgUrlFp,["header_suffix"]=paramImgPath.header_suffix or"jpeg"}
        end

        local img_back_data=nil
        local tmpImgPath=getImgPath(settings["metadata_show_imgtype"] or Metadata_show_imgtype)
        if not table.isEmpty(tmpImgPath) then
            local header = {["Accept"] = "image/"..tmpImgPath.header_suffix}
            local err, reply = kiko.httpget(tmpImgPath.path, {} , header)
            if err ~= nil or (reply or{}).hasError then
                kiko.log("[ERROR] TMDb.API.reply-showmnfo.httpget: " .. err..
                        (((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1])
                err, reply = kiko.httpget(tmpImgPath.path_preview, {} , header)
                if err ~= nil then
                    goto jumpover_metadatadisplay_img_scraping
                end
            end
            img_back_data=reply["content"]
        end
        -- kiko.log(reply)
        --[[
        local rf=io.open(sourcePath,"rb")
        local len = rf:seek("end")
        rf:seek("set",0)= rf:read(len)
        img_back_data = rf:read(len)
        ]]--
        ::jumpover_metadatadisplay_img_scraping::
        -- local rand_symbol= ""
        -- local rand_num= os.time() % string.len(rand_symbol)
        local resTF, resText = kiko.dialog({
            ["title"] = anime["name"] .. " - 元数据", -- 对话框标题，可选
            -- ["tip"] = "> 此处的编辑不可保存哦~\t", -- 对话框提示信息
            ["tip"] = tipStringT,
            ["text"] = tipString, -- 可选，存在这个字段将在对话框显示一个可供输入的文本框，并设置text为初始值
            ["image"]=img_back_data,   --可选，内容为图片数据，存在这个字段将在对话框内显示图片
        })
        if resTF == "accept" then
            kiko.message("此处的编辑不可保存哦~", NM_HIDE)
        end
    end
end

-- 对修改设置项`settings`响应。KikoPlay当 设置中修改了脚本设置项 时，会尝试调用`setoption`函数通知脚本。
-- key为设置项的key，val为修改后的value
function setoption(key, val)
    -- 显示设置更改信息
    kiko.log(string.format("[INFO]  Settings changed: %s = %s", key, val))

    if key=="api_key" then
        local query = { ["api_key"] = val, ["language"]="zh-CN", }
        local header = { ["Accept"] = "application/json", }
        local hg_theme= "tv/67070" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.themoviedb.org/3/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError then
            kiko.log("[ERROR] TMDb.API.reply-test.httpget: ".. err)
            if tostring(err) == ("Host requires authentication") then
                kiko.dialog({
                    ["title"]="测试 TMDb 的API是否有效连接",
                    ["tip"]="[错误]\t请在脚本设置中填写正确的 `TMDb的API密钥`！",
                    ["text"]="+ TMDb 获取API - https://www.themoviedb.org/settings/api",
                })
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            else
                kiko.dialog({
                    ["title"]="测试 TMDb 的API是否有效连接",
                    ["tip"]="[错误]\t"..err..(((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1].."！",
                    ["text"]="+ TMDb 获取API - https://www.themoviedb.org/settings/api",
                })
            end
            -- error(err)
        else
            kiko.dialog({
                ["title"]="测试 TMDb 的API是否有效连接",
                ["tip"]="\t成功设置 `API - TMDb的API密钥` ！",
            })
        end
    end
    if key=="api_key_fanart" then
        local query = { ["api_key"] = val }
        local header = { ["Accept"] = "application/json" }
        local hg_theme= "tv/314614" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("http://webservice.fanart.tv/v3/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError then
            kiko.log("[ERROR] fanart.API.reply-test.httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
                kiko.dialog({
                    ["title"]="测试 fanart 的API是否有效连接",
                    ["tip"]="[错误]\t请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                        "\t\t或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。",
                    ["text"]="+ fanart 获取API - https://fanart.tv/get-an-api-key/",
                })
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            else
                kiko.dialog({
                    ["title"]="测试 fanart 的API是否有效连接",
                    ["tip"]="[错误]\t"..err..(((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1].."！",
                    ["text"]="+ fanart 获取API - https://fanart.tv/get-an-api-key/",
                })
            end
            -- error(err)
        else
            kiko.dialog({
                ["title"]="测试 fanart 的API是否有效连接",
                ["tip"]="\t成功设置 `API - fanart的API密钥` ！",
            })
        end
    end
    if key=="metadata_image_priority" and val=="fanart_prior" then
        kiko.dialog({
            ["title"]="更改了 `元数据 - 图片主要来源`",
            ["tip"]="此功能建议fanart的API有效连接，\n请点击`设置`->`脚本`->右键`TMDb`->测试连接。",
            ["text"]=nil,
        })
    end
    if key=="metadata_show_imgtype" and (val=="thumb"
            or val=="banner" or val=="logo" or val=="art" or val=="otherart") then
        kiko.dialog({
            ["title"]="更改了 `元数据 - 显示的图片种类`",
            ["tip"]="此功能需要fanart的API有效连接，\n请点击`设置`->`脚本`->右键`TMDb`->测试连接。",
            ["text"]=nil,
        })
    end
end

function scriptmenuclick(menuid)
    kiko.log(string.format("[INFO]  Script menu click: %s", menuid))
    if menuid == "detect_valid_api" then
        local diaTitle, diaTip, diaText = "测试 API 是否有效连接","",""
        local query = { ["api_key"] = settings["api_key"], ["language"]="zh-CN", }
        local header = { ["Accept"] = "application/json", }
        local hg_theme= "tv/67070" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.themoviedb.org/3/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError then
            kiko.log("[ERROR] TMDb.API.reply-test.httpget: ".. err)
            if tostring(err) == ("Host requires authentication") then
                diaTip = diaTip.. "[错误]\t请在脚本设置中填写正确的 `TMDb的API密钥`！\n"
                diaText = diaText.. "+ TMDb 获取API - https://www.themoviedb.org/settings/api\n"
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            else
                diaTip = diaTip.. "[错误]\t"..err..(((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1].."！\n"
                diaText = diaText.. "+ TMDb 获取API - https://www.themoviedb.org/settings/api\n"
            end
            -- error(err)
        else
            diaTip = diaTip.. "\t成功连接 `API - TMDb的API密钥` ！\n"
        end
        query = { ["api_key"] = settings["api_key_fanart"] }
        header = { ["Accept"] = "application/json" }
        hg_theme= "tv/314614" -- Flebag (2016)
        err,reply = nil,nil
        err, reply = kiko.httpget("http://webservice.fanart.tv/v3/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError then
            kiko.log("[ERROR] fanart.API.reply-test.httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
                diaTip = diaTip.. "\n[错误]\t请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                        "\t\t或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。\n"
                diaText = diaText.. "+ fanart 获取API - https://fanart.tv/get-an-api-key/\n"
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            else
                diaTip = diaTip.. "\n[错误]\t"..err..(((reply or{}).hasError) and{" <"..math.floor((reply or{}).statusCode).."> "..(reply or{}).errInfo} or{""})[1].."！\n"
                diaText = diaText.. "+ fanart 获取API - https://fanart.tv/get-an-api-key/\n"
            end
            -- error(err)
        else
            diaTip = diaTip.. "\n\t成功连接 `API - fanart的API密钥` ！\n"
        end
        kiko.dialog({
            ["title"]= diaTitle,
            ["tip"]= diaTip,
            ["text"]=  (string.isEmpty(diaText) and{nil} or{diaText})[1],
        })
    elseif menuid == "link_repo_usage" then
        kiko.execute(true, "cmd", {"/c", "start", "https://github.com/kafovin/KikoPlayScript#%E8%84%9A%E6%9C%AC-tmdb-%E7%9A%84%E7%94%A8%E6%"})
    elseif menuid == "display_dialog_about" then
        local img_back_data= nil
        -- local header = {["Accept"] = "image/jpeg" }
        -- local err, reply = kiko.httpget("https://github.com/kafovin/KikoPlayScript/blob/library-tmdb-beta/manual.assets/image-Scraping.by.TMDb-2.1.1.png", {} , header)
        -- if err ~= nil or (reply or{}).hasError then
        --     img_back_data=nil
        -- else
        --     img_back_data=reply["content"]
        -- end
        kiko.dialog({
            ["title"]= "关于  -  脚本 TMDb",
            ["tip"]= "\t\t\t\tEdited by: kafovin\n\n"..
                    "脚本 TMDb (/library/tmdb.lua) 是用于弹幕视频播放软件 KikoPlay 的资料脚本，\n"..
                    "主要借助你从 The Movie Database (TMDb) 申请的API 来搜索和刮削信息。\n"..
                    "也可设置选择刮削 fanart 的媒体图片、Jellyfin/Emby 的本地元数据、TVmaze的剧集演员。\n"..
                    "\n欢迎到 此脚本的GitHub页面 或 KikoPlay的QQ群 反馈！\n",
            ["text"]= "+ 此脚本的GitHub页面 - https://github.com/kafovin/KikoPlayScript\n"..
                    "\t 用法、常见问题…\n"..
                    "+ TMDb 申请 API - https://www.themoviedb.org/settings/api\n"..
                    "+ fanart 申请 API - https://fanart.tv/get-an-api-key/\n"..
                    "\n本脚本基于：\n"..
                    "+ TMDb 首页 - https://www.themoviedb.org/\n"..
                    "+ fanart 首页 - https://fanart.tv/\n"..
                    "+ TVmaze 首页 - https://www.tvmaze.com/\n"..
                    "+ Jelyfin 首页 - https://jellyfin.org/\n"..
                    "+ Emby 首页 - https://emby.media/\n"..
                    "+ 其他另见脚本内注释\n"..
                    "\nKikoPlay：\n"..
                    "+ KikoPlay 首页 - https://kikoplay.fun/\n"..
                    "+ KikoPlay的GitHub页面 - https://github.com/KikoPlayProject/KikoPlayScript\n"..
                    "+ KikoPlay 脚本仓库 - https://github.com/KikoPlayProject/KikoPlayScript",
            ["image"]= img_back_data,
        })
    end
end

---------------------
-- 功能函数
--

-- 从文件名获取粗识别的媒体信息
-- return: (table):{Title|SeasonNum|EpNum|EpExt|TitleExt|EpType}
function Path.getMediaInfoRawByFilename(filename)
    if filename == nil or filename=="" or type(filename)~="string" then
        return {"","","","","",""}
    end
    
    local res={}        -- 结果 Result:       Title|SeasonNum|EpNum|EpExt|TitleExt|EpType
    local resTS={}  -- 粗提取 ResultRaw:   TitleRaw|SeasonEpRaw
    local resSext={}    -- 季集 SeasonEpInfo: SeasonNum|EpNum|EpExt|TitleExt|Eptype

    -- kiko.regex([[...]],"options"):gsub("target","initpos")
    -- kiko.regex([[...]],"options"):gmatch("target","repl")
    -- kiko.regex([[...]],"options"):gsub("target","repl")
    
    -- 阿拉伯数字:季集 regex: (S)(01)(E)(02)(-)(03) | ()()(EP)(02)()()
    local patternSENum=[[^([Ss]|第{0,1}?|)(\d{1,}(?=[EeXx季部第]|[話集]\d{1,})|)([EeXx]|[Ee][Pp]{0,1}|[季部][ \-\.]{0,3}|[季部]{0,1}[ \-\.]{0,3}[第話集]|)(\d{1,})([話集]{0,1}[\-\.]{0,1}|)(\d{1,}|)([^\t\r\n]{0,}?)$]]
    -- 含中文数字:季集 regex: (第)(一)()(季第)(二)(-)(三)(集)...
    local patternSEZh=[[^(第|)((\d{1,}|[〇零一二三四五六七八九十]{1,5})(?=[季部第])|)([季部][ \-\.]{0,3}第{0,1}|第)(\d{1,}|[〇零一二三四五六七八九十]{1,5})([—\-\.]{0,1})((\d{1,}|[〇零一二三四五六七八九十]{1,5})|)([話话集]{0,1})([^\t\r\n]{0,}?)$]]

    -- kiko.regex不能多开，需要依次，否则会后来的替代掉之前的
    -- 普通集:标题-季集 regex: (Title)(.)(S01E02)... |  (Title)(.)(第一季第二集)...
    -- local patternSE=[[^([^\t\r\n]{0,}?)([ \-\.\[])((([Ss]{0,1}(\d{1,}[Ee]|(?<=[Ss \-\.\]\[])\d{1,2}[Xx])\d{1,}([\-]\d{1,3}|))|([Ee][Pp]{0,1}\d{1,}([\-\.]\d{1,3}|))|(第(\d{1,}|[〇零一二三四五六七八九十]{1,5})(([季部][ \-\.]{0,3}第{0,1}(\d{1,}|([〇零一二三四五六七八九十]{1,5}))([—\-\.]\d{1,3}|)[話话集]{0,1})|([\-\.]\d{1,3}|)[話话集]{0,1}))|(?<![ \.\[][HhXx]\.)\d{2,3}([\-\.]\d{1,}|)(?!\.))(?=[ \-\.\[\]\(\)])(?!p))([^\t\r\n]{0,})$]]
    local patternSE=[[^([^\t\r\n]{0,}?)([ \-\.\[])((([Ss]{0,1}((\d{1,}[Ee])|((?<=[Ss \-\.\]\[])\d{1,2}[Xx]))\d{1,}(([\-][Ee]{0,1}\d{1,3})|))|([Ee][Pp]{0,1}\d{1,}(([ \-\.]{1,3}[Ee]{0,1}\d{1,3})|)(?=[ \-\.\[\]\(\)]))|(第((\d{1,})|([〇零一二三四五六七八九十]{1,5}))(([季部][ \-\.]{0,3}第{0,1}(\d{1,}|([〇零一二三四五六七八九十]{1,5}))([ —\-\.]{1,3}\d{1,3}|)[話话集]{0,1})|([\-\.]\d{1,3}|)[話话集]))|((?<![ \.\[][HhXx]\.)\d{2,3}([ \-\.]{1,3}\d{1,}|)(?=(([ \-\.\[\]\(\)]{0,}$)|((?!\.)[ \-\.\[\]\(\)]{2,})|([ \-\.\[\]\(\)]{0,}?\.((avi)|(flv)|(mpg)|(mp4)|(mkv)|(rm)|(rmvb)|(ts)|(wmv))$)))(?!p[ \-\.\[\]\(\)])(?![^\t\r\n]{0,}?[ \-\.\[]((第[\d〇零一二三四五六七八九十]{1,})|([Ss]\d{1,})|(\d{0,}[Ee][Pp]{0,1}\d{1,})|(\d{1,2}[Xx]\d{1,})))))[^ \-\.\[\]\(\)]{0,})([^\t\r\n]{0,})$]]

    -- 特别篇:标题 regex: (Title)(.)(SP)...
    local patternSp=[[^([^\t\r\n]{0,}?)([ \-\.\[\]\(\)]{1,3})(((?<![ \.\[][HhXx]\.)[\d〇零一二三四五六七八九十]{1,3}([\-\.]\d{1,}|)(?=($|((?!\.)[ \-\.\[\]\(\)]{2,})|([ \-\.\[\]\(\)]{0,}?\.((avi)|(flv)|(mpg)|(mp4)|(mkv)|(rm)|(rmvb)|(ts)|(wmv))$)))(?![pPiIkK][ \-\.\[\]\(\)])(?![b]it)(?![^\t\r\n]{0,}?((第[\d〇零一二三四五六七八九十]{1,})|([Ss]\d{1,}))))|([Ss第]((\d{1,})|([〇零一二三四五六七八九十]{1,5}[季部]))[^ \-\.\(\)\[\]\{\}\t\r\n]{0,})|((([Ss]pecial[s]{0,1}|[Ee]xtra[s]{0,1}|[Ss][Pp]|特[别別典][篇编編片]{0,1})|([Tt]railer[s]{0,1}|[Cc][Mm]|[Pp][Vv]|[预預予][告][篇编編片]{0,1})|([Oo][Pp]|片[頭头]曲{0,1})|([Ee][Dd]|片尾曲{0,1}))(([ \-\.]{0,3}\d{1,3})|)(?=[ \-\.\[\]\(\)]{0,}?((\d{4})|(\d{3,4}[pPiIkK])|([34][dD])|([hHxX][\-\.]{0,1}26[45])|(\-[ \.])|(\[)|(DVD|HDTV|((WEB|[^ \-\.\(\)\[\]\{\}\t\r\n]{0,})([\-]{0,1}DL|[Rr]ip))|BD[Rr]ip|[Bb]lu[e\-]{0,2}[Rr]ay)|(((avi)|(flv)|(mpg)|(mp4)|(mkv)|(rm)|(rmvb)|(ts)|(wmv))$)|$))))([^\t\r\n]{0,})$]]
    -- 特别篇所在季序数: regex: (S01)...
    local patternSpSeason=[[((?<=^)|(.{0,}?(?<=[ \-\.\[\]\(\)])))([Ss]|第)(\d{1,}|([〇零一二三四五六七八九十]{1,5}(?=[季部第]))).{0,}$]]
    local patternSpSp=[[((?<=^)|(.{0,}?(?<=[ \-\.\[\]\(\)])))([Ss]pecial[s]{0,1}|[Ee]xtra[s]{0,1}|[Ss][Pp]|特[别別典][篇编編片]{0,1})(?=($|([ \-\.\[\]\(\)].{0,})))]]
    local patternSpTr=[[((?<=^)|(.{0,}?(?<=[ \-\.\[\]\(\)])))([Tt]railer[s]{0,1}|[Cc][Mm]|[Pp][Vv]|[预預予][告][篇编編片]{0,1})(?=($|([ \-\.\[\]\(\)].{0,})))]]
    local patternSpOp=[[((?<=^)|(.{0,}?(?<=[ \-\.\[\]\(\)])))([Oo][Pp]|片[頭头]曲{0,1})(?=($|([ \-\.\[\]\(\)].{0,})))]]
    local patternSpEd=[[((?<=^)|(.{0,}?(?<=[ \-\.\[\]\(\)])))([Ee][Dd]|片尾曲{0,1})(?=($|([ \-\.\[\]\(\)].{0,})))]]

    -- 仅标题 regex: (Title)(-)()...
    local patternNum=[[^([^\t\r\n]{0,}?)([ \-\.\[\]\(\)]{1,3})(\d{1,3}(?=[ \-\.\[\]\(\)]{1,3})|([Ss第](\d{1,}|[〇零一二三四五六七八九十]{1,5}[季部])[ \-\.]{0,3}[^ \-\.\(\)\[\]\{\}\t\r\n]{0,}?)|)(?=([ \-\.\[\]\(\)]{0,3})((\d{4})|(\d{3,4}[pPiIkK])|([34][dD])|([hHxX][\-\.]{0,1}26[45])|(\-[ \.])|(\[)|(\d{1,2}[Bb]it)|(DVD|HDTV|(WEB|[^ \-\.\(\)\[\]\{\}\t\r\n]{0,})([\-]{0,1}DL|[Rr]ip)|BD[Rr]ip|[Bb]lu\-{0,1}[Rr]ay)|((avi|flv|mpg|mp4|mkv|rm|rmvb|ts|wmv)$)))([^\t\r\n]{0,})$]]

    -- 普通集: filename->ResultRaw
    resTS=string.split(kiko.regex(patternSE,"i"):gsub(filename,"\\1\t\\3"),"\t")
    if resTS[1] ~= filename then
        while #resTS<2 do
            table.insert(resTS,"") -- 补全长度
        end
        -- 仅数字的集: SeasonEpRaw->SeasonEpInfo
        resSext=string.split(kiko.regex(patternSENum,"i"):gsub(resTS[2],"\\2\t\\4\t\\6\t\\7"),"\t")
        -- resSext=string.split(kiko.regex(patternSENum,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
        if resSext[1] ~= resTS[2] then
            -- 补全 TitleExt
            Array.extend(resSext,{""})
        else
            -- 含中文数字的集
            resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\5\t\\7\t\\10"),"\t")
            -- resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
            if resSext[1] ~= resTS[2] then
                Array.extend(resSext,{""})
            else
                -- Other unrecognizable results
                resSext={"","","",resTS[2],""}
            end
        end
        -- kiko.log("n\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
    else
        -- 特别篇
        resTS=string.split(kiko.regex(patternSp,"i"):gsub(filename,"\\1\t\\3"),"\t")
        if resTS[1] ~= filename then
            while #resTS<2 do
                table.insert(resTS,"")
            end
            -- 获取季序数
            local sextSeasonNum=kiko.regex(patternSpSeason,"i"):gsub(resTS[2],[[\4]])
            if sextSeasonNum == resTS[2] then
                sextSeasonNum=""
            end
            -- 不实现识别 特别篇的集序数： 集序数没有统一标准，根据文件名 容易识别后相互覆盖，且无法判断是相关某集序数还是特别篇的序数
            -- local sextEpNum="" -- 集序数
            -- local sextEpExt="" -- 集序数拓展
            
            -- 获取集类型
            local sextEpType="" -- 集类型
            -- 特别篇 预告片 片头/OP 片尾/ED 其他
            if resTS[2] ~= kiko.regex(patternSpSp,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="SP"
            elseif resTS[2] ~= kiko.regex(patternSpTr,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="TR"
            elseif resTS[2] ~= kiko.regex(patternSpOp,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="OP"
            elseif resTS[2] ~= kiko.regex(patternSpEd,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="ED"
            else
                sextEpType="OT"
            end
            resSext={sextSeasonNum,"","",resTS[2],sextEpType}
            -- kiko.log("s\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
        else
            -- 仅标题
            resTS=string.split(kiko.regex(patternNum,"i"):gsub(filename,"\\1\t\\3"),"\t")
            while #resTS<2 do
                table.insert(resTS,"")
            end
            -- 获取 季序数
            local sextSeasonNum=kiko.regex(patternSpSeason,"i"):gsub(resTS[2],[[\4]])
            local sextEpType="" -- 如果有季序数 集类型为Others
            if sextSeasonNum == resTS[2] then
                sextSeasonNum=""
                sextEpType=""
            -- 特别篇 预告片 片头/OP 片尾/ED 其他
            elseif resTS[2] ~= kiko.regex(patternSpSp,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="SP"
            elseif resTS[2] ~= kiko.regex(patternSpTr,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="TR"
            elseif resTS[2] ~= kiko.regex(patternSpOp,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="OP"
            elseif resTS[2] ~= kiko.regex(patternSpEd,"i"):gsub(resTS[2],[[\1\1]]) then
                sextEpType="ED"
            else
                sextEpType="OT"
            end
            -- 获取 集序数
            local sextEpNum=""
            sextEpNum=(kiko.regex([[^\d{1,}$]],"i")):gmatch(resTS[2])
            if(sextEpNum == nil) then sextEpNum=""
            else sextEpNum=sextEpNum()
            end

            resSext={sextSeasonNum,sextEpNum,"","",sextEpType}
            -- kiko.log("o\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
        end
    end
    -- 处理数字
    for ri in pairs({1,2,3}) do
        if resSext[ri] == nil then resSext[ri]="" end
        if("" ~= resSext[ri]) then
            -- x十/十x -> x〇/一x
            -- resSext[ri]=(kiko.regex([[^(十)$]],"i")):gsub(resSext[ri],[[一〇]])
            resSext[ri]=(kiko.regex([[^(十)]],"i")):gsub(resSext[ri],[[一\1]])
            resSext[ri]=(kiko.regex([[(十)$]],"i")):gsub(resSext[ri],[[\1〇]])
            -- 中文数字->0-9

            string.gsub(resSext[ri],"十","")
            local zhnumToNum={["〇"]="0", ["零"]="0", ["一"]="1", ["二"]="2", ["三"]="3", ["四"]="4", ["五"]="5", ["六"]="6", ["七"]="7", ["八"]="8", ["九"]="9", ["十"]=""}
            for key, value in pairs(zhnumToNum or {}) do
                resSext[ri] = string.gsub(resSext[ri],key,value)
            end
            -- 除去开头的'0'
            resSext[ri]=(kiko.regex([[^(0{1,})]],"i")):gsub(resSext[ri],"")
        end
    end
    -- 提取标题
    local resT=resTS[1] -- TitleRaw
    -- 移除非标题内容的后缀
    resT=(kiko.regex("\\[([Mm]ovie|[Tt][Vv]|)\\]","i")):gsub(resT,"")
    -- 移除不在末尾的"[...]"
    resT=(kiko.regex([[\[[^\[\]\r\n\t]{1,}\](?![ \-\.\[\]\(\)]{0,}$)]],"i")):gsub(resT,"")
    -- 移除一些符号
    resT=(kiko.regex([[[《》_\-\.\[\]\(\)]{1,}]],"i")):gsub(resT," ")
    -- 移除开头/末尾/多余的空格
    resT=(kiko.regex([[ {1,}]],"i")):gsub(resT," ")
    resT=(kiko.regex([[(^ {1,}| {1,}$)]],"i")):gsub(resT,"")
    
    -- 获取识别结果
    table.insert(res,resT)
    Array.extend(res,resSext)
    
    -- 输出获取结果
    local tmpLogPrint=""
    -- tmpLogPrint=tmpLogPrint .."  "..#res.."\t"
    for ri = 2, #res, 1 do
        if res[ri] == "" then tmpLogPrint=tmpLogPrint.."▫".."\t"
        else tmpLogPrint=tmpLogPrint.. res[ri]..'\t' end
    end
    tmpLogPrint=tmpLogPrint..res[1]
    kiko.log("Finished getting media info RAW by filename.\n" ..
        "Season\tEp\tEpExt\tEpInfo\tEpType\tTitle:\t"..tmpLogPrint)
    return res
end

-- 读 xml 文本文件
-- path_xml:video.nfo|file_nfo -> kiko.xmlreader:xml_file_nfo
-- 拓展名 .nfo，内容为 .xml 格式
-- 文件来自 Emby 的本地服务器 在电影/剧集文件夹存储 从网站刮削出的信息。
function Path.readxmlfile(path_xml)

    -- local io_status =io.type(path_xml)
    -- if io_status ==nil then
    -- error("readxmlfile - Fail to get valid path of file < ".. path_xml .. ' >.')
    -- return nil;
    -- end
    local file_nfo = io.open(path_xml, 'r') -- 以只读方式 打开.xml文文本文件
    if file_nfo == nil then
        -- 文件打开错误
        kiko.log("[ERROR] readxmlfile - Fail to read file <" .. path_xml .. ' >.')
        error("readxmlfile - Fail to open file < " .. path_xml .. ' >.')
        return nil;
    end
    local xml_file_nfo = file_nfo:read("*a") -- 读文件，从当前位置读取整个文件
    if xml_file_nfo == nil then
        -- 读文件失败
        kiko.log("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        error("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        return nil;
    end
    file_nfo:close() -- 关闭文件
    local kxml_file_nfo = kiko.xmlreader(xml_file_nfo) -- 用kiko读.xml格式文本
    xml_file_nfo = nil -- 获取错误信息
    local err = kxml_file_nfo:error()
    if err ~= nil then
        -- 读.xml文本失败
        kiko.log("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        error("readxmlfile - Fail to read xml content < " .. path_xml .. ' | ' .. file_nfo .. ' >. ' .. err)
        return nil;
    end
    return kxml_file_nfo
end

-- query, namespace
function Kikoplus.httpgetMediaId(queryMe,namespace)
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    local header = {["Accept"] = "application/json"}
    -- tmdb_id_media
    local err, replyMe = kiko.httpget(string.format(
        "http://api.themoviedb.org/3/" .. namespace), queryMe, header)

    if err ~= nil or (replyMe or{}).hasError then
        kiko.log("[ERROR] TMDb.API.reply-"..namespace.."."..(queryMe.language or"").."."..(queryMe.append_to_response or"-")..".httpget: " .. err..
                (((replyMe or{}).hasError) and{" <"..math.floor((replyMe or{}).statusCode).."> "..(replyMe or{}).errInfo} or{""})[1])
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err..(((replyMe or{}).hasError) and{" <"..math.floor((replyMe or{}).statusCode).."> "..(replyMe or{}).errInfo} or{""})[1])
    end
    local contentMe = replyMe["content"]
    local err, objMe = kiko.json2table(contentMe)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-"..namespace.."."..(queryMe.language or"")..".json2table: " .. err)
        error(err)
    end
    return objMe
end
-- 添加字符串至剪切板
function Kikoplus.systemAddToPasteboard(str,info)
    if str==nil then
        return nil
    elseif type(str)=="table" then
        str= table.toStringBlock(str)
    elseif type(str)=="number" then
        str= tostring(str)
    end
    kiko.execute(true, "cmd", {"/c", "set/p=", string.gsub(str ,"([\"])", " "),"<nul|clip"})
    kiko.log("[INFO]  Add "..(info or"") .. " to pasteboard.")
    return (kiko.message("已复制"..(string.isEmpty(info) and{ "" }or{ " "..info.." " })[1] .. "至剪切板", NM_HIDE))
end

-- 特殊字符转换 "&amp;" -> "&"  "&quot;" -> "\""
-- copy from & thanks to "..\\library\\bangumi.lua"
-- 在此可能用于媒体的标题名中的特殊符号，但是不知道需不需要、用不用得上。
function string.unescape(str)
    if type(str) ~= "string" then
        -- 非字符串
        return str
    end
    -- 替换符号
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
-- string.find reverse
-- 反向查找字符串首次出现
-- string:str  string:substr  number|int:ix -> number|int:字串首位索引
function string.findre(str, substr, ix)
    if ix < 0 then
        -- ix<0 即从后向前，换算为自前向后的序数
        ix = #str + ix + 1
    end
    -- 反转母串、子串查找，以实现
    local dstl, dstr = string.find(string.reverse(str), string.reverse(substr), #str - ix + 1, true)
    -- 返回子串出现在母串的左、右的序数
    return #str - dstl + 1, #str - dstr + 1
end
-- string.split("abc","b")
-- return: (table){} - 无匹配，返回 (table){input}
-- copy from & thanks to - https://blog.csdn.net/fightsyj/article/details/85057634
function string.split(input, delimiter)
    -- 分隔符nil，返回 (table){input}
    if type(delimiter) == nil then
        return {input}
    end
    -- 转换为string类型
    input = tostring(input)
    delimiter = tostring(delimiter)
    -- 分隔符空字符串，返回 (table){input}
    if (delimiter == "") then
        return {input}
    end

    -- 坐标；分割input后的(table)
    local pos, arr = 0, {}
    -- 从坐标每string.find()到一个匹配的分隔符，获取起止坐标
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        -- 插入 旧坐标到 分隔符开始坐标-1 的字符串
        table.insert(arr, string.sub(input, pos, st - 1))
        -- 更新坐标为 分隔符结束坐标+1
        pos = sp + 1
    end
    -- 插入剩余的字符串
    table.insert(arr, string.sub(input, pos))
    return arr
end
-- string.isEmpty():: nil->true | "" -> true
function string.isEmpty(input)
    if input==nil or tostring(input)==""
            or not (type(input)=="string" or type(input)=="number" or type(input)=="boolean") then
        return true
    else return false
    end
end

--获取默认集数，以秒数计算
function os.time2EpiodeNum()
    return math.random(1,9)/10+(os.time()%900)+100
end

-- 打印 <table> 至 kiko
-- copy from & thanks to: https://blog.csdn.net/HQC17/article/details/52608464
-- { k = v }
Key_tts = "" -- 暂存来自上一级的键Key
function table.toStringLog(table, level)
    if (table == nil) then return "" end
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
    for k, v in pairs(table or {}) do
        if type(v) == "table" then
            -- <table>变量，递归
            Key_tts = k
            str = str .. table.toStringLog(v, level + 1)
        else
            -- 普通变量，直接打印
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v or""))
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
function table.toStringLine(table0)
    --
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "(" .. k .. ")" .. tostring(v or"") .. ", "
        else
            -- <table>变量，递归
            str = str .. "(" .. k .. ")" .. "[ " .. table.toStringLine(v) .. " ], "
        end
    end
    return str
end
-- table 转 多行的string - 把表转为多行（含\n）的字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"[k]\t v,\n [ (k)v,\t (k)v ], \n"
function table.toStringBlock(table0, tabs)
    if tabs == nil then
        -- 根级别 无缩进
        tabs = 0
    end
    -- 排除非<table>类型
    if type(table0) ~= "table" then return "" end
    local str = "{\n" -- 要return的字符串
    tabs = tabs + 1
    for k, v in pairs(table0) do
        -- str=str..string.format("%10s",type(k).."-"..type(v)) -- [TEST]
        for i = 1, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            str = str .. "\t"
        end
        -- kiko.log(type(k).."  :  ".. tostring(k))
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "[ " .. k .. " ] : \t" .. tostring(v or"") .. "\n"
        else
            -- <table>变量，递归
            str = str .. "[ " .. k .. " ] : \t" .. table.toStringBlock(v, tabs) .. "\n"
        end
    end
    for i = 2, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            str = str .. "\t"
    end
    return str .. "}"
end
-- 判断table是否为 nil 或 {}
-- copy from & thanks to - https://www.cnblogs.com/njucslzh/archive/2013/02/02/2886876.html
function table.isEmpty(ta)
    if ta == nil then
        return true
    end
    return _G.next( ta ) == nil
end
-- 深拷贝<table>，包含元表(?)，不考虑键key为<table>的情形
-- copy from & thanks to - https://blog.csdn.net/qq_36383623/article/details/104708468
function table.deepCopy(tb)
    if tb == nil then
        return {}
    end
    if type(tb) ~= "table" then
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
    -- 设置元表。
    setmetatable(copy, table.deepCopy(getmetatable(tb)) or{})
    return copy
end

-- array 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <array>table0 -> <string>:"v, [(k)v, (k)v], "
function Array.toStringLine(table0,separator)
    if type(table0) ~= "table" and type(table0) == "string" then
        return tostring(table0)
    elseif type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    separator= (string.isEmpty(separator) and{ "," }or{ separator })[1]
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. (string.isEmpty(str) and{ "" }or{ separator.." " })[1] .. tostring(v or"")
        else
            -- <table>变量，递归
            str = str .. (string.isEmpty(str) and{ "[ " }or{ separator.." [ " })[1] .. table.toStringLine(v) .. " ]"
        end
    end
    return str
end
-- From: 数组tb的所有元素的值. To: 接续到数组ta的尾部
function Array.extend(ta,tb)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    for index, value in ipairs(tb) do
        table.insert(ta,value)
    end
    return table.deepCopy(ta)
end
-- From: 数组tb各 table:元素 键为string:tbField的 值，To: 这些值中所有未出现在数组ta内的. 乱序接续到ta的尾部。
function Array.extendUnique(ta,tb,tbField)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    if type(tbField) ~= "string" and type(tbField) == "number" then
        tbField=nil
    end
    local isValueOf=false
    for _, vb in ipairs(tb or {}) do
        isValueOf=false
        if vb == nil then
            goto continue_Array_EU_f
        end
        if (tbField~=nil and vb[tbField] == nil) then
            goto continue_Array_EU_f
        end
        for _, va in ipairs(ta or {}) do
            if tbField==nil then
                if vb==va then
                    isValueOf=true
                    break
                end
            else
                if vb[tbField] == va then
                    isValueOf=true
                    break
                end
            end
        end
        if not isValueOf then
            if tbField==nil then
                table.insert(ta,vb)
            else
                table.insert(ta,vb[tbField])
            end
        end
        ::continue_Array_EU_f::
    end
    return table.deepCopy(ta)
end
-- 相当于 tbField 存储了多个字段名的 Array.extendUnique(,,)
-- From: table，以array:tbField中所有出现的string:值 为键，以(非nil)来自数组tb中各table:元素内对应的值 为值。
-- To: 这些table中所有未出现在数组ta内的 (与ta的table:元素存在某一相等键的值不相等)，乱序接续到ta的尾部。
function Array.extendUniqueFields(ta,tb,tbField,isExistUnequal,isOnlyGiven)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    if type(tbField) ~= "table" or tbField == nil then
        if type(tbField) ~= "string" and type(tbField) ~= "number" and tbField ~= nil then
            tbField=nil
        end
        return Array.extendUnique(ta,tb,tbField)
    end
    local isValueOf=false
    for _, vb in ipairs(tb or {}) do
        isValueOf=false
        if vb == nil then
            goto continue_Array_EUF_s
        end
        if isExistUnequal==false and isExistUnequal~="false" then
            for _, va in ipairs(ta or {}) do
                for _, vf in ipairs(tbField or{}) do
                    if vf~=nil then
                        if vb[vf] == va[vf] then -- 存在值等，跳出
                            isValueOf=true
                            break
                        end
                    end
                end
                if isValueOf then break end -- 所有值不等，比较下一个va
            end
        elseif true then
            for _, va in ipairs(ta or {}) do
                for _, vf in ipairs(tbField or{}) do
                    if vf~=nil then
                        if vb[vf] ~= va[vf] then -- 存在值不等，比较下一个va
                            goto continue_Array_EUF_f
                        end
                    end
                end
                isValueOf= true -- 所有值等，跳出
                break
                ::continue_Array_EUF_f::
            end
        end
        if not isValueOf then
            local vbf={}
            if isOnlyGiven==false and isOnlyGiven~="false" then
                vbf= table.deepCopy(vb)
            elseif true then
                for _, vf in ipairs(tbField or{}) do
                    if vf~=nil then
                        vbf[vf]= vb[vf]
                    end
                end
            end
            table.insert(ta,vbf)
        end
        ::continue_Array_EUF_s::
    end
    return table.deepCopy(ta)
end
