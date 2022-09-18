-- Trakt List
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TraktList",
    ["id"] = "Kikyou.b.TraktList",
    ["desc"] = "Trakt 媒体日历脚本（测试中，不稳定） Edited by: kafovin \n"..
                "从 trakt.tv 刮削媒体的日历时间表，可在日历中自动标记Trakt账户里已关注的媒体。",
    ["version"] = "0.1.04", -- 0.1.04.220801_fix
}

-- 设置项
settings = {
    ["api_key_trakt"] = {
        ["title"] = "API - Trakt的Client ID",
        ["default"] = "<<Client_ID_Here>>",
        ["desc"] = "[必填项] 在`trakt.tv`注册账号，并把个人设置`Settings`中的`Your API Apps`申请到的\n"..
                    "`Client ID` 填入此项。 ( `https://trakt.tv/oauth/applications`，一般为一串字母数字)"
    },
    -- ["api_key_trakt_token"] = {
    --     ["title"] = "API - Trakt的设备通行码",
    --     ["default"] = "<<Access_Token_Here>>",
    --     ["desc"] = "[选填项] (此功能不可用)在`trakt.tv`注册账号，并把个人设置`Settings`中的`Your API Apps`里面`Devices`申请到的\n"..
    --                 "`Bearer [access_token]` 填入此项。 ( `https://trakt.tv/oauth/applications`，一般为一串字母数字)\n"..
    --                 "`时间表 - 媒体范围`中，收藏相关功能(my)需要此`API - Trakt的设备通行码`。",
    -- },
    -- ["schedule_info_type_02"]={
    --     ["title"]="时间表 - 剧集类型",
    --     ["default"]="scripted",
    --     ["desc"]="时间表中出现的剧集、节目类型。\n"..
    --             "scripted：包含剧本类、动画类、纪录类等剧集 (默认)。scripted_variety：包含前者，以及综艺节目、颁奖节目等。\n"..
    --             "scripted_show：包含前者，以及游戏节目、真人节目、访谈节目、讨论节目等。tv_show：包括前者，以及体育节目、新闻节目等，即所有节目。",
    --     ["choices"]="scripted,scripted_variety,scripted_show,tv_show",
    -- },
    ["schedule_info_range"]={
        ["title"]="时间表 - 媒体范围",
        ["default"]="show_movie_all",
        ["desc"]="时间表中所出现媒体的范围，例如：剧集/电影、仅关注/所有。\n"..
                "show：剧集。 movie：电影。 dvd：光盘。  all：所有。 my：Trakt账户里已关注的媒体。\n"..
                "show_movie_all：所有剧集、电影 (默认)。 `my`相关功能还需要`账户授权`(在脚本设置右键菜单)。",
        -- ["choices"]="show_all,show_movie_all",
        ["choices"]="show_all,show_movie_all,show_all_my,show_movie_all_my,show_my,show_movie_my",
    },
    ["schedule_info_zmerged"]={
        ["title"]="时间表 - 合并剧集",
        ["default"]="1",
        ["desc"]="时间表中的剧集某季 是否将同一星期的不同集数合并为一行。\n"..
                "0：按各自集数显示为多行显示。 1：按所属星期将不同集数合并为一行显示 (默认)。\n"..
                "2：按所属星期将不同集数合并为一行，不注明集数。",
        ["choices"]="0,1,2",
        -- ["choices"]="show_all,show_my,show_movie_all,show_movie_my",
    },
    ["schedule_sort"]={
        ["title"]="时间表 - 排序",
        ["default"]="timeslot",
        ["desc"]="将每日时间表按此顺序排列，顺序相同的以`标题 季序号 集序号`为序。\n"..
                "time：按时间升序。timeslot：按时间档升序 (默认)。title：按名称升序。 mf：将电影排在最前。",
                -- "default：默认。time：按时间升序。",
        ["choices"]="time,timeslot,title,time_mf,timeslot_mf",
        -- ["choices"]="default,time",
    },
    -- ["schedule_date_release_type"]={
    --     ["title"]="时间表 - 放送日期类型",
    --     ["default"]="show_x_ep",
    --     ["desc"]="时间表中，`放送日期`的一列显示的日期类型。\n"..
    --             "episode：均为该集的播映日期。\n"..
    --             "show：均为剧集最初的播映日期，通常为S01E01或试播集的播映日期。\n"..
    --             "show_x_ep：一般为剧集最初的播映日期，对于`自定义星期`是该集的播映日期 (默认)。",
    --     ["choices"]="episode,show,show_x_ep",
    -- },
    ["season_deviance_older"]={
        ["title"]="分组列表 - 近几组",
        ["default"]="56",
        ["desc"]="分组的列表中，显示现在及以前几组，最后一个为本组。请保存设置后重启，方可查看新的分组列表。\n"..
                "近1组为 1 (即本组)，近2组为 2 (即本组、上一组)，以此类推。\n"..
                "0：自1909-02-01所在一组至今。 56：近56组 (默认)。",
        -- 用 1909-02-01 是因为Trakt网站日历的默认显示，似乎从这一天开始逐渐有内容，即 The Mack Sennett Collection S01E01 播出时的那一组。
    },
    ["season_deviance_period"]={
        ["title"]="分组列表 - 组周期",
        ["default"]="w14",
        ["desc"]="分组的列表中 每组显示的时间范围，包括 起始日期、天数，即每个 从某日起几天 的范围。\n"..
                "m：每月01日。 w：每周的周日。 * 最多33天。\n"..
                "例如：w14 (每周从周日起的14天) (默认)。",
    },
    ["season_order_nextperiod"]={
        ["title"]="分组列表 - 显示下一组",
        ["default"]="0",
        ["desc"]="分组的列表中，下一组的位置。\n"..
                "0：不显示 (默认)。 1：显示在`本组`的后一个。\n"..
                "-1：显示在`本组`的前一个 (可能会影响`关注`功能的识别)。",
        ["choices"]="-1,0,1",
    },
    -- ["season_naming_date"]={
    --     ["title"]="分组列表 - 日期格式",
    --     ["default"]="Y-m-d",
    --     ["desc"]="分组的列表中，组名的日期格式。建议与`时间表 - 放送日期类型`的设置搭配以分辨日期。\n"..
    --             "[注意]  更改此设置后，以前载入的组会无法识别。\n"..
    --             "[注意]  要使用以前的时间表需要手动重命名此目录下的缓存：`.\\KikoPlay\\data\\calendar\\Kikyou.b.TVmazeList`\n"..
    --             "Y-m-d：年份-月份-日期，如 `2021-12-31` (默认)。Ymd：年份月份日期，如 `20211231`。\n"..
    --             "Y-m-u：年份-月份-该月周序号，如 `2021-12-5`。Ymu：年份-月份-该月周序号，如 `2021125`。\n"..
    --             "Y-U：年份-该年周序号，如 `2021-52`。YU：年份-该年周序号，如 `202152`。\n",
    --     ["choices"]="Y-m-d,Ymd,Y-m-u,Ymu,Y-U,YU",
    -- },
    -- ["datetime_zone"]={
    --     ["title"]="时间 - 时区",
    --     ["default"]="system",
    --     ["desc"]="使用的时区。目前仅限使用程序在当前系统的默认时区。\n"..
    --             "system:系统默认时区。",
    --     ["choices"]="system,+08:00"
    -- },
    ["datetime_zone_hour"]={
        ["title"]="时间 - 时区小时",
        ["default"]="system",
        ["desc"]="使用时区的小时数。目前仅限使用程序在当前系统的默认时区。\nAsia/Shanghai(亚洲/上海)的时区为`+08:00`，即此处为`+08`。\n"..
                "system:系统默认时区 (默认)。",
        ["choices"]="system,-12,-11,-10,-09,-08,-07,-06,-05,-04,-03,-02,-01,+00,+01,+02,+03,+04,+05,+06,+07,+08,+09,+10,+11,+12",
    },
    ["datetime_zone_minute"]={
        ["title"]="时间 - 时区分钟",
        ["default"]="system",
        ["desc"]="使用时区的分钟数。目前仅限使用程序在当前系统的默认时区。\nAsia/Shanghai(亚洲/上海)的时区为`+08:00`，即此处为`00`。\n"..
                "system:系统默认时区 (默认)。",
        ["choices"]="system,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,"..
                    "30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59",
    },
}

scriptmenus = {
    {["title"]="检测连接", ["id"]="detect_valid_api"},
    {["title"]="账户授权", ["id"]="detect_valid_oauth"},
    {["title"]="使用方法", ["id"]="link_repo_usage"},
    {["title"]="关于", ["id"]="display_dialog_about"},
}

-- (() and{} or{})[1]

--[[ copy from & thanks to "../bgm_calendar/bgmlist.lua" in "KikoPlay/bgm_calendar"|KikoPlayScript
_, Site_map = kiko.json2table([[{"acfun":{"title":"AcFun","urlTemplate":"https://www.acfun.cn/bangumi/aa{{id}}","regions":["CN"],"type":"onair"},"bilibili":{"title":"哔哩哔哩","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["CN"],"type":"onair"},"bilibili_hk_mo_tw":{"title":"哔哩哔哩（港澳台）","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["HK","MO","TW"],"type":"onair"},"sohu":{"title":"搜狐视频","urlTemplate":"https://tv.sohu.com/{{id}}","regions":["CN"],"type":"onair"},"youku":{"title":"优酷","urlTemplate":"https://list.youku.com/show/id_z{{id}}.html","regions":["CN"],"type":"onair"},"qq":{"title":"腾讯视频","urlTemplate":"https://v.qq.com/detail/{{id}}.html","regions":["CN"],"type":"onair"},"iqiyi":{"title":"爱奇艺","urlTemplate":"https://www.iqiyi.com/{{id}}.html","regions":["CN"],"type":"onair"},"letv":{"title":"乐视","urlTemplate":"https://www.le.com/comic/{{id}}.html","regions":["CN"],"type":"onair"},"pptv":{"title":"PPTV","urlTemplate":"http://v.pptv.com/page/{{id}}.html","regions":["CN"],"type":"onair"},"mgtv":{"title":"芒果tv","urlTemplate":"https://www.mgtv.com/h/{{id}}.html","regions":["CN"],"type":"onair"},"nicovideo":{"title":"Niconico","urlTemplate":"https://ch.nicovideo.jp/{{id}}","regions":["JP"],"type":"onair"},"netflix":{"title":"Netflix","urlTemplate":"https://www.netflix.com/title/{{id}}","type":"onair"},"gamer":{"title":"動畫瘋","urlTemplate":"https://acg.gamer.com.tw/acgDetail.php?s={{id}}","regions":["TW"],"type":"onair"},"muse_hk":{"title":"木棉花 HK","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","MO"],"type":"onair"},"ani_one_asia":{"title":"Ani-One Asia","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","TW","MO","SG","MY","PH","TH","ID","VN","KH","BD","BN","BT","FJ","FM","IN","KH","LA","LK","MH","MM","MN","MV","NP","NR","PG","PK","PW","SB","TL","TO","TV","VU","WS"],"type":"onair"},"viu":{"title":"Viu","urlTemplate":"https://www.viu.com/ott/hk/zh-hk/vod/{{id}}/","regions":["HK","SG","MY","IN","PH","TH","MM","BH","EG","JO","KW","OM","QA","SA","AE","ZA"],"type":"onair"}}]]
--)]]
-- as above

Array={}
Datetime={}
ApiTrakt={}
-- Schedule_info={["country"]= {"GB","US","JP","CN"},}
Calendar_group={
    -- ["deviance_old"]={-1,1,0},
    ["deviance_older"]= -55, -- 1-7*8
    ["deviance_oldest"]= {},
    ["period_older"]= {
        ["year"]= { ["year"]= 1, ["month"]= 2, ["week"]= 5, ["day"]= 33, },
        ["month"]= { ["year"]= 1, ["month"]= 2, ["week"]= 5, ["day"]= 33, },
        ["week"]= { ["year"]= 1, ["month"]= 1, ["week"]= 2, ["day"]= 14, },
        ["day"]= { ["year"]= 1, ["month"]= 1, ["week"]= 1, ["day"]= 7, },
        -- ["year"]= { ["year"]= 1, ["month"]= 13, ["week"]= 54, ["day"]= 378, },
        -- ["month"]= { ["year"]= 1, ["month"]= 2, ["week"]= 5, ["day"]= 35, },
        -- ["week"]= { ["year"]= 1, ["month"]= 1, ["week"]= 2, ["day"]= 14, },
        -- ["day"]= { ["year"]= 1, ["month"]= 1, ["week"]= 1, ["day"]= 7, },
    },
    ["period_oldest"]= { ["year"]= 1, ["month"]= 2, ["week"]= 5, ["day"]= 33, },
    ["peroid_settings"]= {}
}
Date_time_info={
    ["timezone_hm"]= {
        ["hour"]= (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",1,3)) or 0)),
        ["min"]= (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",4,5)) or 0)),
    },
    ["timezone"]= (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",1,3)) or 0)) *3600 +
                    (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",4,5)) or 0)) *60,  -- 记录系统时区
    ["timezone_cus"]= nil,   -- 记录设置的时区
    ["calendar_week_start"]="2022-01-01",
    ["weekEnNum"]= {["Sunday"]=0,["Monday"]=1,["Tuesday"]=2,["Wednesday"]=3,["Thursday"]=4,["Friday"]=5,["Saturday"]=6,},
    ["custom_week_title"]= "自定义星期",
    ["str_format"]="%Y-%m-%d||%H:%M:%S||%z||%U-%w",
    ["present"]= nil,
}
Date_time_info["timezone_cus"]= ((( settings["datetime_zone_hour"]=="system") and{ Date_time_info.timezone_hm.hour}
                or{ math.floor(tonumber( settings["datetime_zone_hour"]  ) or Date_time_info.timezone_hm.hour) })[1]) *3600 +
                ((( settings["datetime_zone_minute"]=="system") and{ Date_time_info.timezone_hm.min }
                or{ math.floor(tonumber( settings["datetime_zone_minute"]) or Date_time_info.timezone_hm.min ) })[1]) *60

Metadata_lang= "zh-CN"
Translation = {
    ["und-XX"] = {
        ["template"]={ [""]= "Others", ["Unknown"]= "Unknown" },
        ["media_type"]={ ["movie"]= "Movie", ["tv"]= "TV", ["show"]= "Show",["dvd"]= "DVD", [""]= "Others", ["Unknown"]= "Unknown" },
    },
}
Translation["zh-CN"] = {
    ["media_type"]={ ["movie"]= "电影", ["tv"]= "剧集", ["show"]= "剧集", ["dvd"]= "光盘", [""]= "其他", ["Unknown"]= "未知" },
}

-- string.isEmpty():: nil->true | "" -> true
function string.isEmpty(input)
    if input==nil or tostring(input)==""
            or not (type(input)=="string" or type(input)=="number" or type(input)=="boolean") then
        return true
    else return false
    end
end
--* any timestamp , (string)typeStart::year/month/week/[day] -> (table)date
function Datetime.stampToDate(stamp,typeStart,isKeephm)
    if stamp<0 then
        stamp=Date_time_info.present.p_stamp
    end
    -- 24*3600=86400
    local sundTmp
    if typeStart==nil then
        if type(isKeephm)~="boolean" then isKeephm=true end
        sundTmp=os.date("*t",stamp)
    elseif (typeStart or Calendar_group.peroid_settings.start) =="week" then
        if type(isKeephm)~="boolean" then isKeephm=false end
        sundTmp=os.date("*t",stamp -Date_time_info.timezone+Date_time_info.timezone_cus
                -86400*tonumber(os.date("%w",stamp -Date_time_info.timezone+Date_time_info.timezone_cus)))
    elseif true or (typeStart or Calendar_group.peroid_settings.start) =="day" then
        if type(isKeephm)~="boolean" then isKeephm=false end
        sundTmp=os.date("*t",stamp -Date_time_info.timezone+Date_time_info.timezone_cus)
    end
    local sund={}
    sund.year=sundTmp.year
    sund.month=sundTmp.month
    sund.day=sundTmp.day
    if isKeephm then
    sund.hour=sundTmp.hour
    sund.minute=sundTmp.minute
    else
        sund.hour=nil
        sund.minute=nil
    end
    if typeStart==nil then
        return sund
    end
    if (typeStart or Calendar_group.peroid_settings.start) =="month" then
        sund.day=1
    elseif (typeStart or Calendar_group.peroid_settings.start) =="year" then
        sund.day=1
        sund.month=1
    end
    return sund
end
--* get present (table) p.st p.d sun.d sun.st
function Datetime.getPresent()
    local pStamp,pDate,pSunDate,pSunStamp,pZone
    pStamp= os.time()
    pDate= Datetime.stampToDate(pStamp,"day")
    pSunDate= Datetime.stampToDate(pStamp, Calendar_group.peroid_settings.start,false)
    pSunStamp=(os.time(pSunDate)) -43200 +Date_time_info.timezone-Date_time_info.timezone_cus -- 12*3600
    -- pZone= os.date("%z",pStamp) -- +0800
    return {
        ["p_stamp"] = pStamp,--presentTimeStamp Date_time_info.present.sun_stamp
        ["p_date"] = pDate,--presentTimeStamp Date_time_info.present.sun_stamp
        ["sun_date"]= pSunDate,--thisSunDate
        ["sun_stamp"]= pSunStamp,--thisSunStamp),
    }
end
function Datetime.getZoneSettings()
    zHour= (( settings["datetime_zone_hour"]=="system"  ) and{ Date_time_info.timezone_hm.hour}
                    or{ math.floor(tonumber( settings["datetime_zone_hour"]  ) or Date_time_info.timezone_hm.hour) })[1]
    zMin=  (( settings["datetime_zone_minute"]=="system") and{ Date_time_info.timezone_hm.min }
                    or{ math.floor(tonumber( settings["datetime_zone_minute"]) or Date_time_info.timezone_hm.min ) })[1]
    return zHour *3600 + zMin *60
end
function Datetime.getPeroidFromSettings(period_settings)
    if type(period_settings)~="string" or string.isEmpty(period_settings) then
        period_settings= settings["season_deviance_period"] or "w14"
    end
    local patternF= [[^[^YyMmWwDd0-9\r\n]*([YyMmWwDd]{0,1})[^0-9\r\n]*(\d*)[^YyMmWwDd0-9\r\n]*([YyMmWwDd]{0,1})]]
    local kregexF= kiko.regex(patternF,"i")
    local _, _, clgPrStart, clgPrCount, clgPrUnit = kregexF:find(tostring(period_settings),1)

    clgPrStart= (string.isEmpty(clgPrStart) and{"m"} or{clgPrStart})[1]
    if clgPrStart=="y" or clgPrStart=="Y" then clgPrStart="year"
    elseif clgPrStart=="m" or clgPrStart=="M" then clgPrStart="month"
    elseif clgPrStart=="d" or clgPrStart=="d" then clgPrStart="day"
    elseif true or clgPrStart=="w" or clgPrStart=="W" then clgPrStart="week"
    end

    clgPrUnit= (string.isEmpty(clgPrUnit) and{"d"} or{clgPrUnit})[1]
    if clgPrUnit=="y" or clgPrUnit=="Y" then clgPrUnit="year"
    elseif clgPrUnit=="m" or clgPrUnit=="M" then clgPrUnit="month"
    elseif clgPrUnit=="w" or clgPrUnit=="W" then clgPrUnit="week"
    elseif true or clgPrUnit=="d" or clgPrUnit=="D" then clgPrUnit="day"
    end

    if tonumber(clgPrCount)~=nil and tonumber(clgPrCount)> Calendar_group.period_oldest[clgPrUnit] then
        clgPrCount = Calendar_group.period_oldest[clgPrUnit]
    elseif tonumber(clgPrCount)~=nil and tonumber(clgPrCount)>0 then
        clgPrCount = clgPrCount
    elseif true or tonumber(clgPrCount)==nil or tonumber(clgPrCount)<=0 then
        clgPrCount = Calendar_group.period_older[clgPrStart][clgPrUnit]
    end

    return { ["start"]= clgPrStart, ["count"]= clgPrCount, ["unit"]= clgPrUnit, }
end
--* (string)str :: "2022-03-01T07:00:00-05:00" -> timestamp
function Datetime.strToStamp(input)
    local dateTa={}
    local secZdt=0
    -- if isFromLocal==nil then isFromLocal=false end

    if string.isEmpty(input) then
        return Date_time_info.present.p_stamp
    else
        local dataTap= os.date("*t",Date_time_info.present.p_stamp)
        dateTa={
            ["year"]= math.floor(tonumber(string.sub(input,1,4) or"") or tonumber(dataTap.year) or 2022),
            ["month"]= math.floor(tonumber(string.sub(input,6,7) or"") or 1),
            ["day"]= math.floor(tonumber(string.sub(input,9,10) or"") or 1),
            ["hour"]= math.floor(tonumber(string.sub(input,12,13) or"") or 0),
            ["min"]= math.floor(tonumber(string.sub(input,15,16) or"") or 0),
            ["sec"]= math.floor(tonumber(string.sub(input,18,19) or"") or 0),
        }
        secZdt= ((tonumber(string.sub(input,20,22) or"") or tonumber(string.sub(input,24,25) or""))
                and{    math.floor(tonumber(string.sub(input,20,22) or"") or 0)*3600 +
                        math.floor(tonumber(string.sub(input,24,25) or"") or 0)*60 }
                or{Date_time_info.timezone_cus})[1]
        
    end
    return os.time(dateTa) -secZdt +Date_time_info.timezone
end

Calendar_group.peroid_settings= Datetime.getPeroidFromSettings(settings["season_deviance_period"])
Date_time_info.present= Datetime.getPresent()
Calendar_group.deviance_oldest= {
    ["year"]= -math.ceil(Date_time_info.present.p_date.year - 1909), -- 1909-02-01 ~115
    ["month"]= -math.ceil((Date_time_info.present.p_date.year - 1909)*12 + Date_time_info.present.p_date.month - 2), -- 1909-02-01 ~1300
    ["week"]= -math.ceil(os.difftime(Date_time_info.present.sun_stamp,Datetime.strToStamp("1989-12-17T20:00:00-05:00"))/604800.0)-1, -- 3600*24*7 ~1700
    ["day"]= -math.ceil(os.difftime(Date_time_info.present.p_stamp,Datetime.strToStamp(string.format("%d",Date_time_info.present.p_date.year-4).."-"..os.date("%m-%d").."T12:00:00+00:00"))/86400.0), -- 3600*24 ~1650
}

---------------------
-- 日历脚本部分
-- copy (as template) from & thanks to "../bgm_calendar/bgmlist.lua" in "KikoPlay/library"|KikoPlayScript
--

function getseason()
    -- Date_time_info.timezone_cus= Datetime.getZoneSettings()
    -- date|time|zone|week -- 2022-02-27||17:05:02||CST||09-0
    kiko.log("[INFO]  Getting calendar group of <" .. os.date(Date_time_info.str_format,Date_time_info.present.p_stamp)
            .."."..settings["season_deviance_period"].. ">")
    Calendar_group.peroid_settings= Datetime.getPeroidFromSettings(settings["season_deviance_period"])
    Date_time_info.present= Datetime.getPresent()

    -- kiko.log("[TEST]  " .. os.date(Date_time_info.str_format,Date_time_info.present.sun_stamp) .. ">")
    -- kiko.log("[TEST]  ! "..os.date("!%Y-%m-%dT%H:%M:%S+%z",Date_time_info.present.p_stamp))

    -- any timestamp -> the sunday timestamp
    local clgDvTmp={} -- list
    local clgDvO=0 -- start
    local season_deviance_older= (tonumber(settings["season_deviance_older"]) and{ 1- tonumber(settings["season_deviance_older"]) }or{ nil })[1]
    if season_deviance_older and math.floor(season_deviance_older) <=1 then
        if math.floor(season_deviance_older) >0 then
            clgDvO= Calendar_group.deviance_oldest[Calendar_group.peroid_settings.start]
        else clgDvO= season_deviance_older
        end
    else clgDvO= Calendar_group.deviance_older
    end
    -- get deviance(int) list
    for i= clgDvO,-1,1 do
        table.insert(clgDvTmp,i)
    end
    if settings["season_order_nextperiod"] == "-1" then
        table.insert(clgDvTmp,1)
        table.insert(clgDvTmp,0)
    elseif settings["season_order_nextperiod"] == "1" then
        table.insert(clgDvTmp,0)
        table.insert(clgDvTmp,1)
    elseif true or settings["season_order_nextperiod"] == "0" then
        table.insert(clgDvTmp,0)
    end

    local theSunStamp= {-1} -- -1::customized
    local cldgInfo={}
    local cTitle,cData="",{}
    local pWeekDateInfo= {}

    -- customized
    cData.period_start_dt= {}
    cData.period_end_dt= {}
    cData.period_start_dt.stamp = Date_time_info.present.sun_stamp
    cData.period_end_dt.stamp = Datetime.stampAddPeriod(cData.period_start_dt.stamp, Calendar_group.peroid_settings.unit, Calendar_group.peroid_settings.count, Calendar_group.peroid_settings.start)

    local err, cDataJson = kiko.table2json(cData)
    if err ~= nil then
        kiko.log(string.format("[ERROR] table2json: %s", err))
    end
    table.insert(cldgInfo,{
        ["title"]= Date_time_info.custom_week_title,
        ["data"]= cDataJson,
    })

    -- get period start date(table) list
    if Calendar_group.peroid_settings.start =="day" or Calendar_group.peroid_settings.start =="week" then
        local devpSec= nil
        if Calendar_group.peroid_settings.start =="day" then
            devpSec= 86400 -- 24*3600
        elseif true or Calendar_group.peroid_settings.start =="week" then
            devpSec= 604800 -- 7*24*3600
        end

        for _, dev in ipairs(clgDvTmp) do
            cTitle,cData="",{}
            cData.period_start_dt= {}
            cData.period_end_dt= {}
            local tss= Date_time_info.present.sun_stamp + (dev or 0) *devpSec
            pWeekDateInfo = Datetime.stampToDate(tss,"day",false)
            cData.period_start_dt.stamp = tss
            cData.period_end_dt.stamp = Datetime.stampAddPeriod(cData.period_start_dt.stamp, Calendar_group.peroid_settings.unit, Calendar_group.peroid_settings.count, Calendar_group.peroid_settings.start)
            -- if settings["season_naming_date"] == "Ymu" then
            -- elseif settings["season_naming_date"] == "Y-m-u" then
            -- elseif settings["season_naming_date"] == "YU" then
            -- elseif settings["season_naming_date"] == "Y-U" then
            -- elseif settings["season_naming_date"] == "Ymd" then
            -- elseif true or settings["season_naming_date"] == "Y-m-d" then
            -- end
            cTitle= string.format("%04d-%02d-%02d",pWeekDateInfo.year,pWeekDateInfo.month,pWeekDateInfo.day)

            err, cDataJson = kiko.table2json(cData)
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            table.insert(cldgInfo,{
                ["title"]=cTitle,
                ["data"]=cDataJson,
            })
        end
    elseif true or Calendar_group.peroid_settings.start =="year" or Calendar_group.peroid_settings.start =="month" then
        for _, dev in ipairs(clgDvTmp) do
            cTitle,cData="",{}
            cData.period_start_dt= {}
            cData.period_end_dt= {}
            local pStart_d, pEnd_d = {}, {}
            if Calendar_group.peroid_settings.start =="year" then
                pStart_d.year= Date_time_info.present.sun_date.year + dev
                pStart_d.month= 1
            elseif true or Calendar_group.peroid_settings.start =="month" then
                pStart_d.year= Date_time_info.present.sun_date.year + math.floor((Date_time_info.present.sun_date.month + dev)/12)
                pStart_d.month= (Date_time_info.present.sun_date.month + dev)%12
            end
            pStart_d.day= 1
            cTitle= string.format("%04d-%02d-%02d",pStart_d.year,pStart_d.month,pStart_d.day)
            cData.period_start_dt.stamp = (os.time(pStart_d)) -43200 +Date_time_info.timezone-Date_time_info.timezone_cus
            cData.period_end_dt.stamp = Datetime.stampAddPeriod(cData.period_start_dt.stamp, Calendar_group.peroid_settings.unit, Calendar_group.peroid_settings.count, Calendar_group.peroid_settings.start)

            err, cDataJson = kiko.table2json(cData)
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            table.insert(cldgInfo,{
                ["title"]=cTitle,
                ["data"]=cDataJson,
            })
        end
    end

    kiko.log("[INFO]  Finished getting " .. #cldgInfo .. " calendar groups.")
    return cldgInfo
end

function getbgmlist(season)
    kiko.log("[INFO]  Starting getting Trakt list of <" .. season["title"]..">")
    Date_time_info.present= Datetime.getPresent()

    -- Date_time_info.timezone_cus= Datetime.getZoneSettings()
    -- kiko.log("[TEST]  "..table.toStringBlock(Date_time_info))

    local err, objCldg = kiko.json2table(season.data or"{}")
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    if table.isEmpty(objCldg) or table.isEmpty(objCldg.period_start_dt) or err ~= nil then
        kiko.log("[WARN]  season."..(season.title or "_")..":[\"data\"] not found.")
        -- error("[WARN]  season."..season.title..": "..err)
        -- Datetime.
        objCldg={}
        if string.isEmpty(season.title) then
            season.title="_"
            objCldg.period_start_dt.stamp = Date_time_info.present.sun_stamp
            objCldg.period_end_dt.stamp = Datetime.stampAddPeriod(objCldg.period_start_dt.stamp, Calendar_group.peroid_settings.unit, Calendar_group.peroid_settings.count, Calendar_group.peroid_settings.start)
        elseif true or not string.isEmpty(season.title) then
            objCldg.period_start_dt.stamp = os.time( Datetime.strToDate(season.title) ) -43200 +Date_time_info.timezone-Date_time_info.timezone_cus
            objCldg.period_end_dt.stamp = Datetime.stampAddPeriod(objCldg.period_start_dt.stamp, Calendar_group.peroid_settings.unit, Calendar_group.peroid_settings.count, Calendar_group.peroid_settings.start)
        end
    end

    --for each date of the week
    local weeksInfo ={}
    local sunday0100_s, sunday0100_e =objCldg.period_start_dt.stamp, objCldg.period_end_dt.stamp
    if season.title==Date_time_info.custom_week_title then
        local pdatestr=string.format("%04d-%02d-%02d",Date_time_info.present.p_date.year,Date_time_info.present.p_date.month,Date_time_info.present.p_date.day)
        local resDiaTF, resInput = kiko.dialog({
            ["title"] = "请输入要查询的 起始日期 及 天数。",
            ["tip"] = "形如 <"..pdatestr.." "..tostring(Calendar_group.period_older.month.day)..">：\t日期(默认今天)，从这天算起的天数(默认35)，\n以空格分开。\t\t确认->获取该日期所在组的节目单。 取消->不获取。",
            ["text"]= pdatestr .." "..tostring(Calendar_group.period_older.month.day),
        })
        local resInputSplit = string.split(resInput," ")
        -- 从对话框确定媒体类型
        if resDiaTF == "accept" or resDiaTF == true then
            sunday0100_s= (os.time( Datetime.strToDate(resInputSplit[1]) )) -43200 +Date_time_info.timezone-Date_time_info.timezone_cus -- 12*3600
            local periodSettings = Datetime.getPeroidFromSettings(resInputSplit[2] or "w14")
            sunday0100_e= Datetime.stampAddPeriod(sunday0100_s,periodSettings.unit, periodSettings.count, periodSettings.start)
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            return {}
        end
    end
    -- schedule_info_range boolean
    local schedule_info_type_tmp= settings["schedule_info_range"] or"show_all"
    local isSitShow, isSitMovie, isSitAll, isSitMy = true, false, true, false
    isSitShow= (string.find(schedule_info_type_tmp,"show")) ~=nil
    isSitMovie= (string.find(schedule_info_type_tmp,"movie")) ~=nil
    isSitAll= (string.find(schedule_info_type_tmp,"all")) ~=nil
    isSitMy= (string.find(schedule_info_type_tmp,"my")) ~=nil
    local apiAccesst= ApiTrakt.getAccessToken() or {}
    isSitMy= apiAccesst.success and isSitMy
    -- start_date days in httpget url
    local qDateStart= Datetime.stampToDate(sunday0100_s-86400,"day",false)
    local qDdStr= string.format("%04d-%02d-%02d", qDateStart.year, qDateStart.month, qDateStart.day)
    local qDayCount= math.ceil((sunday0100_e - sunday0100_s)/86400) +2 -- 24*3600
    qDayCount= ((qDayCount>33) and{33} or{qDayCount})[1]
    qDdStr= qDdStr .."/".. qDayCount
    local hGetBatchTable={ ["url"]= {}, ["query"]= {}, ["header"]= {}, ["redirect"]= true, ["type"]={}, }
    local replyCs,contentCs, objCs=nil,nil, {}
    local queryCs = {}
    local header = {
        ["Content-Type"]= "application/json",
        ["trakt-api-version"]= "2",
        ["trakt-api-key"]= settings["api_key_trakt"],
    }
    if isSitAll then
        if isSitShow then
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/all/shows/" ..qDdStr)
            table.insert(hGetBatchTable.type, {"all","show"})
        end
        if isSitMovie then
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/all/movies/" ..qDdStr)
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/all/dvd/" ..qDdStr)
            table.insert(hGetBatchTable.type, {"all","movie"})
            table.insert(hGetBatchTable.type, {"all","dvd"})
        end
    end
    for i = 1, #(hGetBatchTable.url), 1 do
        table.insert(hGetBatchTable.query, table.deepCopy(queryCs) or{})
        table.insert(hGetBatchTable.header, table.deepCopy(header) or{})
    end
    local hgbtUrlLenTmp= #(hGetBatchTable.url)+1
    if isSitMy then
        if isSitShow then
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/my/shows/" ..qDdStr)
            table.insert(hGetBatchTable.type, {"my","show"})
        end
        if isSitMovie then
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/my/movies/" ..qDdStr)
            table.insert(hGetBatchTable.url, "https://api.trakt.tv/".."calendars/my/dvd/" ..qDdStr)
            table.insert(hGetBatchTable.type, {"my","movie"})
            table.insert(hGetBatchTable.type, {"my","dvd"})
        end
        header["Authorization"]= "Bearer " .. (apiAccesst.access_token or "")
        for i = hgbtUrlLenTmp,#(hGetBatchTable.url), 1 do
            table.insert(hGetBatchTable.query, table.deepCopy(queryCs) or{})
            table.insert(hGetBatchTable.header, table.deepCopy(header) or{})
        end
    end

    err,replyCs= kiko.httpgetbatch(hGetBatchTable.url,hGetBatchTable.query,hGetBatchTable.header)
    if err ~= nil then
        kiko.log("[ERROR] Trakt.schedule.reply-week.of." ..(season.title or"").. ".httpgetbatch: " .. err)
        kiko.message("[错误] 对" ..(season.title or"").. "所在组获取时间表失败。\n" .. err,1|8)
        -- kiko.log("[INFO]  hg: "..table.toStringBlock(hGetBatchTable).."\n\nrc"..table.toStringBlock(replyCs))
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `API - Trakt的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://trakt.tv/oauth/applications"})
        end
        return weeksInfo
    end
    for replyCsI, replyCsV in ipairs(replyCs) do
        contentCs = replyCsV["content"]
        if (replyCsV or{}).hasError==true then
            kiko.log("[ERROR] Trakt.schedule.reply-week.of." ..(season.title or"").. ".httpgetbatch: <"..
                    string.format("%03d",(replyCsV or{}).statusCode)..">"..((replyCsV or{}).errInfo or""))
            kiko.message("[错误] 对" ..(season.title or"").. "所在组获取时间表失败。\n<"..
                    string.format("%03d",(replyCsV or{}).statusCode)..">" .. ((replyCsV or{}).errInfo or""),1|8)
            error("ERROR"..string.format("%03d",(replyCsV or{}).statusCode)..": " .. ((replyCsV or{}).errInfo or""))
        end
        local objCsi= {}
        err, objCsi = kiko.json2table(contentCs)
        if err ~= nil then
            kiko.log("[ERROR] Trakt.schedule.reply-on."..(string.gsub(string.sub(hGetBatchTable.url[replyCsI],32),"/",".") or"")..".json2table: " ..err)
            -- error(err)
        elseif table.isEmpty(objCsi) then
            kiko.log("[INFO]  Trakt.schedule.reply-on."..(string.gsub(string.sub(hGetBatchTable.url[replyCsI],32),"/",".") or"")..".json2table: Empty table.")
            -- error(err)
        elseif true then
            table.insert(objCs,objCsi)
        end
    end
    local weeksInfoM = {}
    for mgi,mg in ipairs(objCs) do
        local isMgAll, isMgMy, isMgShow, isMgMovie, isMgDvd= hGetBatchTable.type[mgi][1]=="all", hGetBatchTable.type[mgi][1]=="my",
                hGetBatchTable.type[mgi][2]=="show", hGetBatchTable.type[mgi][2]=="movie", hGetBatchTable.type[mgi][2]=="dvd"
        local fRelease, fMedia, fEpisode = nil,nil,nil
        if isMgMovie or isMgDvd then fRelease, fMedia, fEpisode = "released", "movie", nil
        elseif true or isMgShow then fRelease, fMedia, fEpisode = "first_aired", "show", "episode"
        end
        for _,mi in ipairs(mg) do
            if table.isEmpty(mi[fMedia]) then
                goto continue_gbl_wii
            end
            -- local isInSiCountry= false
            -- local channelNW= {"network","webChannel"}
            -- for _,channelNWV in ipairs(channelNW) do
            --     local tmpCcode= (((ep.show or{})[channelNWV] or{}).country or {}).code
            --     if not string.isEmpty(tmpCcode) then
            --         for _, vSic in ipairs(Schedule_info.country) do
            --             if tmpCcode==vSic then
            --                 isInSiCountry= true
            --                 break
            --             end
            --         end
            --         if not isInSiCountry then
            --             goto continue_gbl_wii
            --         end
            --     end
            -- end
            if string.isEmpty(mi[fMedia].title) then goto continue_gbl_wii
            end
            local wStamp, wWeekday, wTime, wDate= nil,nil,nil,nil
            if isMgMovie or isMgDvd then
                wDate= mi[fRelease]
                wTime= ""
                wStamp= Datetime.strToStamp(mi[fRelease])
                wWeekday= math.floor(tonumber( os.date("%w", wStamp
                            -Date_time_info.timezone+Date_time_info.timezone_cus )) or 0)
            elseif true or isMgShow then
                wStamp= Datetime.strToStamp(string.sub(mi[fRelease], 1,19) .."+00:00Z") -- 2022-07-24T00:00:00.000Z
                local wDatetime= Datetime.stampToDate(wStamp,"day",true)
                wDate= string.format("%04d-%02d-%02d", wDatetime.year, wDatetime.month or 1, wDatetime.day or 1)
                wTime= string.format("%02d:%02d", wDatetime.hour or 0, wDatetime.minute or 0)
                wWeekday= math.floor(tonumber( os.date("%w", wStamp
                            -Date_time_info.timezone+Date_time_info.timezone_cus )) or 0)
            end
            if wStamp<sunday0100_s or wStamp>=sunday0100_e then-- 7*24*3600=604800
                goto continue_gbl_wii
            end
            --scripted,scripted_variety,scripted_show,tv_show
            -- if (ep.show or{}).type~="Scripted" and (ep.show or{}).type~="Animation" and (ep.show or{}).type~="Documentary" then
            --     if schedule_info_type_tmp=="scripted" then
            --         goto continue_gbl_wii
            --     elseif (ep.show or{}).type~="Variety" and (ep.show or{}).type~="Award Show" then
            --         if schedule_info_type_tmp=="scripted" or schedule_info_type_tmp=="scripted_variety" then
            --             goto continue_gbl_wii
            --         elseif (ep.show or{}).type~="Reality" and (ep.show or{}).type~="Game Show" and (ep.show or{}).type~="Talk Show" and (ep.show or{}).type~="Panel Show" then
            --             if schedule_info_type_tmp=="scripted" or schedule_info_type_tmp=="scripted_variety" or schedule_info_type_tmp=="scripted_show" then
            --                 goto continue_gbl_wii
            --             end
            --         end
            --     end
            -- end

            mi.wDate, mi.wTime, mi.wWeekday, mi.wStamp = wDate, wTime, wWeekday, wStamp
            if isMgMovie or isMgDvd then
                local tmpWiMid= fMedia .. (mi[fMedia].ids.trakt or "")
                weeksInfoM[tostring(wWeekday)] = weeksInfoM[tostring(wWeekday)] or {}
                weeksInfoM[tostring(wWeekday)].movie = weeksInfoM[tostring(wWeekday)].movie or {}
                weeksInfoM[tostring(wWeekday)].movie[tmpWiMid] = weeksInfoM[tostring(wWeekday)].movie[tmpWiMid] or {}
                weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].info = weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].info or mi.movie
                weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].eps = weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].eps or {}
                if isMgMovie then
                    weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].eps.movie = mi
                elseif isMgDvd then
                    weeksInfoM[tostring(wWeekday)].movie[tmpWiMid].eps.dvd = mi
                end
                mi.isFocus= mi.isFocus or isMgMy
                mi.isMovie= mi.isMovie or isMgMovie
                mi.isDvd= mi.isDvd or isMgDvd
            elseif true or isMgShow then
                local tmpWiTsid= fMedia .. (math.floor(mi[fMedia].ids.trakt or 0) or "").."S"..string.format("%06d",mi[fEpisode].season or 0)
                local tmpWiTeid= "E"..string.format("%06d",mi[fEpisode].number or 0)
                weeksInfoM[tostring(wWeekday)] = weeksInfoM[tostring(wWeekday)] or {}
                weeksInfoM[tostring(wWeekday)].show = weeksInfoM[tostring(wWeekday)].show or {}
                weeksInfoM[tostring(wWeekday)].show[tmpWiTsid] = weeksInfoM[tostring(wWeekday)].show[tmpWiTsid] or {}
                weeksInfoM[tostring(wWeekday)].show[tmpWiTsid].info = weeksInfoM[tostring(wWeekday)].show[tmpWiTsid].info or mi.show
                weeksInfoM[tostring(wWeekday)].show[tmpWiTsid].eps = weeksInfoM[tostring(wWeekday)].show[tmpWiTsid].eps or {}
                weeksInfoM[tostring(wWeekday)].show[tmpWiTsid].eps[tmpWiTeid] = mi
                mi.isFocus= mi.isFocus or isMgMy
                mi.isShow= mi.isShow or isMgShow
            end
            ::continue_gbl_wii::
        end
    end
    for wdi,wdv in pairs(weeksInfoM) do
        for mType,mTypeV in pairs(wdv) do
            for _,mediaV in pairs(mTypeV) do
                local wSites= {}
                -- if not string.isEmpty(((ep.show or{}).network or{}).name) then
                --     table.insert(wSites,{ ["name"]=string.format("%s",((ep.show or{}).network or{}).name.." "..Translation["zh-CN"].show_type[(ep.show or{}).type or""]), ["url"]=(ep.show or{}).officialSite})
                -- end
                -- if not string.isEmpty(((ep.show or{}).webChannel or{}).name) then
                --     table.insert(wSites,{ ["name"]=string.format("%s",((ep.show or{}).webChannel or{}).name.." "..Translation["zh-CN"].show_type[(ep.show or{}).type or""]), ["url"]=(ep.show or{}).officialSite})
                -- end
                -- if not string.isEmpty((ep.show or{}).officialSite) then
                --     table.insert(wSites,{ ["name"]="主页", ["url"]=(ep.show or{}).officialSite})
                -- end
                if mType~="movie" and not string.isEmpty(mediaV.info.ids.slug) then
                    table.insert(wSites,{ ["name"]="Trakt", ["url"]="https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or""),})
                end
                if not string.isEmpty(mediaV.info.ids.imdb) then
                    table.insert(wSites,{ ["name"]="IMDb", ["url"]="https://www.imdb.com/title/".. mediaV.info.ids.imdb})
                end
                if not string.isEmpty(mediaV.info.title) then
                    table.insert(wSites,{ ["name"]="字幕库", ["url"]="https://zmk.pw/search?q="..string.gsub(mediaV.info.title or"","[ %c%p]","+")})
                    table.insert(wSites,{ ["name"]="SubHD", ["url"]="https://subhd.tv/search/"..string.gsub(mediaV.info.title or"","[ %c%p]","%%20")})
                    table.insert(wSites,{ ["name"]="YYeTs", ["url"]="https://www.yysub.net/search/index?search_type=&keyword="..string.gsub(mediaV.info.title or"","[ %c%p]","+")})
                end
                if not string.isEmpty(mediaV.info.ids.imdb) then
                    table.insert(wSites,{ ["name"]="OpenSubtitles", ["url"]="https://www.opensubtitles.com/zh-CN/zh-CN,zh-TW,en/search-all/q-"..
                                mediaV.info.ids.imdb.. "/hearing_impaired-include/machine_translated-include/trusted_sources-"})
                end
                -- if not string.isEmpty(((ep.show or{}).externals or{}).thetvdb) then
                --     table.insert(wSites,{ ["name"]="TVDb", ["url"]="https://thetvdb.com/series/"..((ep.show or{}).externals or{}).thetvdb})
                -- end
                -- if not string.isEmpty(((ep.show or{}).externals or{}).tvrage) then
                --     table.insert(wSites,{ ["name"]="TVRage", ["url"]="https://www.tvrage.com/"..((ep.show or{}).externals or{}).thetvdb})
                -- end
                
                local wEpisodeSite,wEpisodeName,wEpisodeList = {},{},{}
                if settings["schedule_info_zmerged"] =="2" or settings["schedule_info_zmerged"] =="1" then
                    if mType=="movie" then
                        local tmpSnameSEx=""
                        tmpSnameSEx= tmpSnameSEx.. ((mediaV.eps.movie~=nil) and{Translation[Metadata_lang].media_type.movie} or{""})[1]
                        tmpSnameSEx= tmpSnameSEx.. ((#(mediaV.eps)==2) and{"/"} or{""})[1]
                        tmpSnameSEx= tmpSnameSEx.. ((mediaV.eps.dvd~=nil) and{Translation[Metadata_lang].media_type.dvd} or{""})[1]
                        table.insert(wEpisodeSite,{
                            ["name"]= (string.isEmpty(tmpSnameSEx) and{"-"}or{tmpSnameSEx})[1],
                            ["url"]= "https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or""),
                        })
                        table.insert(wEpisodeName,"0m"..((mediaV.eps.movie~=nil) and{"3movie"} or{""})[1]..((mediaV.eps.dvd~=nil) and{"7dvd"} or{""})[1])
                        table.insert(wEpisodeList, mediaV.eps.movie or mediaV.eps.dvd)
                    elseif mType=="show" then
                        local tmpSnameSEm,tmpSnameSEx,tmpSnameSEr= nil,"",""
                        local mediaVepsTmp={}
                        for _,epv in pairs(mediaV.eps) do
                            table.insert(mediaVepsTmp,epv)
                        end
                        table.stable_sort(mediaVepsTmp, function(a,b) return string.format("E%06d",((a or{}).episode or{}).number)<string.format("E%06d",((b or{}).episode or{}).number) end)
                        local mediaVepsTmpt= mediaV.eps
                        mediaV.eps= mediaVepsTmp
                        mediaVepsTmp= mediaVepsTmpt
                        mediaVepsTmpt= nil
                        for _,epv in pairs(mediaV.eps) do
                            tmpSnameSEm= tmpSnameSEm or epv
                            tmpSnameSEm= ((tmpSnameSEm.first_aired > epv.first_aired) and{epv} or{tmpSnameSEm})[1]
                            tmpSnameSEx= tmpSnameSEx..string.format(":%02d", epv.episode.number)
                            tmpSnameSEr= tmpSnameSEr..string.format("E%06d", epv.episode.number)
                        end
                        if settings["schedule_info_zmerged"] =="2" then
                            tmpSnameSEx= ((tmpSnameSEm.episode.season==0) and{string.format("SP%02d",tmpSnameSEm.episode.season)}
                                        or{string.format("S%02d", tmpSnameSEm.episode.season)})[1]
                            tmpSnameSEr= ((tmpSnameSEm.episode.season==0) and{string.format("SP%05d",tmpSnameSEm.episode.season)}
                                        or{string.format("S%06d", tmpSnameSEm.episode.season)})[1]
                        elseif true or settings["schedule_info_zmerged"] =="1" then
                            tmpSnameSEx= ((tmpSnameSEm.episode.season==0) and{string.format("SP%02d",tmpSnameSEm.episode.season)}
                                        or{string.format("S%02d:", tmpSnameSEm.episode.season)})[1] ..tmpSnameSEx
                            tmpSnameSEr= ((tmpSnameSEm.episode.season==0) and{string.format("SP%05d",tmpSnameSEm.episode.season)}
                                        or{string.format("S%06d", tmpSnameSEm.episode.season)})[1] ..tmpSnameSEr
                        end
                        table.insert(wEpisodeSite,{
                            ["name"]= (string.isEmpty(tmpSnameSEx) and{"-"}or{tmpSnameSEx})[1],
                            ["url"]= "https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or"").."/seasons/"..
                                    string.format("%d",tmpSnameSEm.episode.season),
                        })
                        table.insert(wEpisodeName, tmpSnameSEr)
                        table.insert(wEpisodeList, tmpSnameSEm)
                    end
                elseif true or settings["schedule_info_zmerged"] =="0" then
                    if mType=="movie" then
                        local tmpSnameSEx=""
                        if mediaV.eps.dvd~=nil then
                            tmpSnameSEx= Translation[Metadata_lang].media_type.movie..Translation[Metadata_lang].media_type.dvd
                            table.insert(wEpisodeSite,{
                                ["name"]= (string.isEmpty(tmpSnameSEx) and{"Trakt"}or{tmpSnameSEx.."Trakt"})[1],
                                ["url"]= "https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or""),
                            })
                            table.insert(wEpisodeName,"0m7dvd")
                            table.insert(wEpisodeList, mediaV.eps.dvd)
                        elseif mediaV.eps.movie~=nil then
                            tmpSnameSEx= Translation[Metadata_lang].media_type.movie
                            table.insert(wEpisodeSite,{
                                ["name"]= (string.isEmpty(tmpSnameSEx) and{"Trakt"}or{tmpSnameSEx.."Trakt"})[1],
                                ["url"]= "https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or""),
                            })
                            table.insert(wEpisodeName,"0m3movie")
                            table.insert(wEpisodeList, mediaV.eps.movie)
                        end
                    elseif mType=="show" then
                        for _,epv in pairs(mediaV.eps) do
                            local tmpSnameSEx= ((epv.episode.season==0) and{string.format("SP%02d", epv.episode.number)}
                                    or{string.format("S%02dE%02d", epv.episode.season, epv.episode.number)})[1]
                            table.insert(wEpisodeSite,{
                                ["name"]= (string.isEmpty(tmpSnameSEx) and{"-"}or{tmpSnameSEx})[1],
                                ["url"]= "https://trakt.tv/"..mType.."s/".. (mediaV.info.ids.slug or"").."/seasons/"..
                                        string.format("%d",epv.episode.season).."/episodes/"..string.format("%d",epv.episode.number),
                            })
                            table.insert(wEpisodeName,((epv.episode.season==0) and{string.format("SP%05dE%06d",epv.episode.season ,epv.episode.number)}
                            or{string.format("S%06dE%06d", epv.episode.season, epv.episode.number)})[1] or "-")
                            table.insert(wEpisodeList, epv)
                        end
                    end
                end
                for epi=1,math.min(#wEpisodeSite, #wEpisodeName, #wEpisodeList),1 do
                    table.insert(wSites,1, wEpisodeSite[epi])
                    table.insert(weeksInfo,{
                        ["title"]= mediaV.info.title,-- ..
                                -- ((tonumber(ep.number)==nil) and{ "" } or{ string.format("E%02s", math.floor(tonumber(ep.number))) })[1],
                        ["weekday"]= wEpisodeList[epi].wWeekday, --放送星期，取值0(星期日)~6(星期六)
                        -- ["weekday"]=Date_time_info.weekEnNum[(((ep.show or{}).schedule or{}).days or{})[1]],
                        ["time"]=    wEpisodeList[epi].wTime, --放送时间
                        ["date"]=    wEpisodeList[epi].wDate, --放送日期
                        ["isnew"]=   wEpisodeList[epi].isMovie or (wEpisodeList[epi].isShow
                                and (wEpisodeList[epi].episode.season == 1 or wEpisodeList[epi].episode.number ==1 )), --是否新番
                        -- ["bgmid"]=nil,
                        ["bgmid"]= mType.."s/"..mediaV.info.ids.trakt, --Trakt id
                        ["sites"]= table.deepCopy(wSites), --放送站点列表
                        ["focus"]=   wEpisodeList[epi].isFocus, --用户是否关注

                        ["stamp"]=   wEpisodeList[epi].wStamp,
                        -- ["season_number"]= ((tonumber(ep.season or"")==nil)and{nil} or{ math.floor(tonumber(ep.season)) })[1],
                        -- ["episode_number"]= ((tonumber(ep.number or"")==nil) and{nil} or{ math.floor(tonumber(ep.number)) })[1],
                        ["season_ep_format"]= wEpisodeName[epi] or""
                    })
                    table.remove(wSites,1)
                end
            end
        end
    end

    local weeksInfoUnique= {}
    Array.extendUniqueFields(weeksInfoUnique,weeksInfo,{"title","season_ep_format","stamp"},true,false)
    weeksInfo= weeksInfoUnique
    weeksInfoUnique= nil

    kiko.log("[INFO]  Finished getting " .. #weeksInfo .. " info of < " .. season.title .. ">")
    local sSortBy= string.split(settings["schedule_sort"], "_")
    sSortBy[2]= (string.isEmpty(sSortBy[2]) and{"ml"} or{sSortBy[2]})[1]
    -- table.stable_sort(weeksInfo, function(a,b) return (a.episode_number or 0)<(b.episode_number or 0) end)
    -- table.stable_sort(weeksInfo, function(a,b) return (a.season_number or 0)<(b.season_number or 0) end)
    table.stable_sort(weeksInfo, function(a,b) return a.title.."  "..a.season_ep_format < b.title.."  "..b.season_ep_format end)
    if sSortBy[1] =="time" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        -- table.stable_sort(weeksInfo, function(a,b) return a.stamp<b.stamp end)
        if sSortBy[2] =="mf" then
            table.stable_sort(weeksInfo, function(a,b) return ( (a.date or "").. (string.isEmpty(a.time) and{"00 00"} or{a.time})[1])
                < (b.date or"").. ((string.isEmpty(b.time) and{"00 00"} or{b.time})[1]) end)
        elseif true or sSortBy[2] == "ml" then
            table.stable_sort(weeksInfo, function(a,b) return ( (a.date or "").. (string.isEmpty(a.time) and{"24:00"} or{a.time})[1])
                    < (b.date or"").. ((string.isEmpty(b.time) and{"24:00"} or{b.time})[1]) end)
        end
    elseif sSortBy[1] =="title" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.stamp<b.stamp end)
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        type(0)
    elseif true or sSortBy[1] =="timeslot" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        -- if settings["schedule_date_release_type"] == "episode" or (settings["schedule_date_release_type"] == "show_x_ep"
        --         and season.title==Date_time_info.custom_week_title) then
        --     table.stable_sort(weeksInfo, function(a,b) return a.date<b.date end)
        -- end
        if sSortBy[2] =="mf" then
            table.stable_sort(weeksInfo, function(a,b) return ( (string.isEmpty(a.time) and{"00 00"} or{a.time})[1]) ..(a.date or "")
                    < ((string.isEmpty(b.time) and{"00 00"} or{b.time})[1]) ..(b.date or"") end)
        elseif true or sSortBy[2] == "ml" then
            table.stable_sort(weeksInfo, function(a,b) return ( (string.isEmpty(a.time) and{"24:00"} or{a.time})[1]) ..(a.date or "")
                    < ((string.isEmpty(b.time) and{"24:00"} or{b.time})[1]) ..(b.date or"") end)
        end
    end
    return weeksInfo
end

-- 对修改设置项`settings`响应。KikoPlay当 设置中修改了脚本设置项 时，会尝试调用`setoption`函数通知脚本。
-- key为设置项的key，val为修改后的value
function setoption(key, val)
    -- 显示设置更改信息
    kiko.log(string.format("[INFO]  Settings changed: %s = %s", key, val))

    if key=="api_key_trakt" then
        local query = {}
        local header = {
            ["Content-Type"]= "application/json",
            ["trakt-api-version"]= "2",
            ["trakt-api-key"]= val,
        }
        local hg_theme= "shows/109975" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.trakt.tv/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] Trakt.API.reply-test.httpget: ".. (err or "").."<"..
                    string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            if tostring(err or"") == ("Host requires authentication") then
                kiko.dialog({
                    ["title"]="测试 Trakt 的API是否有效连接",
                    ["tip"]="[错误]\t请在脚本设置中填写正确的 `Trakt的API密钥`！",
                    ["text"]="+ Trakt 获取API - https://trakt.tv/oauth/applications",
                })
                kiko.execute(true, "cmd", {"/c", "start", "https://trakt.tv/oauth/applications"})
            else
                kiko.dialog({
                    ["title"]="测试 Trakt 的API是否有效连接",
                    ["tip"]="[错误]\t"..(err or "").."<".. string.format("%03d",(reply or{}).statusCode or 0)..
                            "> "..((reply or{}).errInfo or"").."！",
                    ["text"]="+ Trakt 获取API - https://trakt.tv/oauth/applications",
                })
            end
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
        else
            kiko.dialog({
                ["title"]="测试 Trakt 的API是否有效连接",
                ["tip"]="\t成功设置 `API - Trakt的API密钥` ！",
                ["text"]=nil,
            })
        end
    elseif key=="season_deviance_period" then
        kiko.dialog({
            ["title"]="更改了 `分组列表 - 组周期`",
            ["tip"]="\t请重启 KikoPlay 以应用设置。",
            ["text"]=nil,
        })
    elseif key=="season_order_nextperiod" then
        kiko.dialog({
            ["title"]="更改了 `分组列表 - 显示下一组`",
            ["tip"]="\t请重启 KikoPlay 以应用设置。",
            ["text"]=nil,
        })
    elseif key=="season_deviance_older" then
        kiko.dialog({
            ["title"]="更改了 `分组列表 - 近几组`",
            ["tip"]="\t请重启 KikoPlay 以应用设置。",
            ["text"]=nil,
        })
    elseif key=="schedule_info_range" then
        local ltmp,_= string.find(val,"my")
        if ltmp~=nil then
            ApiTrakt.getAccessToken(true)
        end
    end
end

function scriptmenuclick(menuid)
    if menuid == "detect_valid_api" then
        
        local diaTitle, diaTip, diaText = "检测 - API 是否有效连接","",""
        local query = {}
        local header = {
            ["Content-Type"]= "application/json",
            ["trakt-api-version"]= "2",
            ["trakt-api-key"]= settings["api_key_trakt"],
        }
        local hg_theme= "shows/109975" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.trakt.tv/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] Trakt.API.reply-test.httpget: ".. (err or "").."<"..
                    string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            if tostring(err or"") == ("Host requires authentication") then
                diaTip = diaTip.. "[错误]\t请在脚本设置中填写正确的 `Trakt的API密钥`！\n"
                diaText = diaText.. "+ Trakt 获取API - https://trakt.tv/oauth/applications\n"
                kiko.execute(true, "cmd", {"/c", "start", "https://trakt.tv/oauth/applications"})
            else
                diaTip = diaTip.. "[错误]\t"..(err or "").."<"..
                        string.format("%03d",(reply or{}).statusCode or 0).."> "..((reply or{}).errInfo or"").."！\n"
                diaText = diaText.. "+ Trakt 获取API - https://trakt.tv/oauth/applications\n"
            end
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
        else
            diaTip = diaTip.. "\t成功连接 `API - Trakt的API密钥` ！\n"
        end

        local atapi= ApiTrakt.getAccessToken(false)
        if((atapi or {}).success) then
            diaTip = diaTip.. "\n\tTrakt账户 已授权此设备"
            diaText = diaText.. "+ Trakt 获取API - https://trakt.tv/oauth/applications\n"
        else
            diaTip = diaTip.. "\n[警告]\tTrakt账户 未授权此设备\n\t当前无法让时间表的范围采用Trakt中您已收藏的媒体，"..
                    "\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项；或将账户授权此设备。"
            diaText = diaText.. "+ Trakt 获取API - https://trakt.tv/oauth/applications\n"
        end

        kiko.dialog({
            ["title"]= diaTitle,
            ["tip"]= diaTip,
            ["text"]=  (string.isEmpty(diaText) and{nil} or{diaText})[1],
        })
        if ((atapi or {}).success) then
            type(0)
        else
            atapi= ApiTrakt.getAccessToken(true)
        end
    elseif menuid == "detect_valid_oauth" then
        local diaTitle, diaTip, diaText = "检测 - Trakt账户 是否授权此设备","",""
        local atapi= ApiTrakt.getAccessToken(false)
        if((atapi or {}).success) then
            diaTip = diaTip.. "\tTrakt账户 已授权此设备"
        else
            diaTip = diaTip.. "[警告]\tTrakt账户 未授权此设备\n\t当前无法让时间表的范围采用Trakt中您已收藏的媒体。"..
                    "\n\t稍后会开启 账户授权向导，\n\t或者请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项；或将账户授权此设备。"
        end
        kiko.dialog({
            ["title"]= diaTitle,
            ["tip"]= diaTip,
            ["text"]=  (string.isEmpty(diaText) and{nil} or{diaText})[1],
        })
        if ((atapi or {}).success) then
            type(0)
        else
            atapi= ApiTrakt.getAccessToken(true)
        end
    elseif menuid == "link_repo_usage" then
        kiko.execute(true, "cmd", {"/c", "start", "https://github.com/kafovin/KikoPlayScript#%E8%84%9A%E6%9C%AC-trakt-%E7%9A%84%E7%94%A8%E6%"})
    elseif menuid == "display_dialog_about" then
        local img_back_data= nil
        -- local header = {["Accept"] = "image/jpeg" }
        -- local err, reply = kiko.httpget("https://github.com/kafovin/KikoPlayScript/blob/library-tmdb-beta/manual.assets/image-TVmazeList-1.1.1.png", {} , header)
        -- if err ~= nil then
        --     img_back_data=nil
        -- else
        --     img_back_data=reply["content"]
        -- end
        kiko.dialog({
            ["title"]= "关于",
            ["tip"]= "\t\t\t\tEdited by: kafovin\n\n"..
                    "脚本 TraktList (/bgm_calendar/traktlist.lua) 是针对剧集或电影的日历时间表脚本，\n"..
                    "主要借助从 Trakt 的公共API刮削剧集的日历时间表(剧集标题为英文)。\n"..
                    "* 测试中，不稳定，未来可能会有较大改动。\n"..
                    "\n欢迎到 此脚本的GitHub页面 或 KikoPlay的QQ群 反馈！\n",
            ["text"]= "+ 此脚本的GitHub页面 - https://github.com/kafovin/KikoPlayScript\n"..
                    "\t 用法、常见问题…\n"..
                    "\n本脚本基于：\n"..
                    "+ Trakt 首页 - https://trakt.tv/\n"..
                    "+ Trakt 的API页面 - https://trakt.tv/oauth/applications\n"..
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

--* string.split("abc","b")
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

--* table 转 多行的string - 把表转为多行（含\n）的字符串  （单向的转换，用于打印输出）
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
--* 判断table是否为 nil 或 {}
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

-- 排序<table>，依据规则less(a<b => true) as below
-- copy from & thanks to - https://gist.github.com/1bardesign/62b90260e47ea807864fc3cc8f880f8d
--[[
stable sorting routines for lua

	modifies the global table namespace so you don't have
	to re-require it everywhere.

		table.stable_sort
			a fast stable sort
		table.unstable_sort
			alias for the builtin unstable table.sort
		table.insertion_sort
			an insertion sort, should you prefer it

this is based on MIT licensed code from Dirk Laurie and Steve Fisher
license as follows:
]]
--[[
	Copyright © 2013 Dirk Laurie and Steve Fisher.

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
	DEALINGS IN THE SOFTWARE.
]]
-- (modifications by Max Cahill 2018)
local _sort_core = {}
--tunable size for
_sort_core.max_chunk_size = 24
function _sort_core.insertion_sort_impl( array, first, last, less )
	for i = first + 1, last do
		local k = first
		local v = array[i]
		for j = i, first + 1, -1 do
			if less( v, array[j-1] ) then
				array[j] = array[j-1]
			else
				k = j
				break
			end
		end
		array[k] = v
	end
end
function _sort_core.merge( array, workspace, low, middle, high, less )
	local i, j, k
	i = 1
	-- copy first half of array to auxiliary array
	for j = low, middle do
		workspace[ i ] = array[ j ]
		i = i + 1
	end
	-- sieve through
	i = 1
	j = middle + 1
	k = low
	while true do
		if (k >= j) or (j > high) then
			break
		end
		if less( array[ j ], workspace[ i ] )  then
			array[ k ] = array[ j ]
			j = j + 1
		else
			array[ k ] = workspace[ i ]
			i = i + 1
		end
		k = k + 1
	end
	-- copy back any remaining elements of first half
	for k = k, j-1 do
		array[ k ] = workspace[ i ]
		i = i + 1
	end
end
function _sort_core.merge_sort_impl(array, workspace, low, high, less)
	if high - low <= _sort_core.max_chunk_size then
		_sort_core.insertion_sort_impl( array, low, high, less )
	else
		local middle = math.floor((low + high)/2)
		_sort_core.merge_sort_impl( array, workspace, low, middle, less )
		_sort_core.merge_sort_impl( array, workspace, middle + 1, high, less )
		_sort_core.merge( array, workspace, low, middle, high, less )
	end
end
--inline common setup stuff
function _sort_core.sort_setup(array, less)
	local n = #array
	local trivial = false
	--trivial cases; empty or 1 element
	if n <= 1 then
		trivial = true
	else
		--default less
		less = less or function (a, b)
			return a < b
		end
		--check less
		if less(array[1], array[1]) then
		  error("invalid order function for sorting")
		end
	end
	--setup complete
	return trivial, n, less
end
-- alias for the builtin unstable table.sort
function _sort_core.stable_sort(array, less)
	--setup
	local trivial, n, less = _sort_core.sort_setup(array, less)
	if not trivial then
		--temp storage
		local workspace = {}
		workspace[ math.floor( (n+1)/2 ) ] = array[1]
		--dive in
		_sort_core.merge_sort_impl( array, workspace, 1, n, less )
	end
	return array
end
-- a fast stable sort
function _sort_core.insertion_sort(array, less)
	--setup
	local trivial, n, less = _sort_core.sort_setup(array, less)
	if not trivial then
		_sort_core.insertion_sort_impl(array, 1, n, less)
	end
	return array
end
--export sort core
table.insertion_sort = _sort_core.insertion_sort
table.stable_sort = _sort_core.stable_sort
table.unstable_sort = table.sort
-- 排序<table> as above

--* 将数组tb的所有的值 接续到数组ta的尾部，忽略tb中的键
function Array.extend(ta,tb)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    for index, value in ipairs(tb) do
        table.insert(ta,value)
    end
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

--* (string)str :: "2022-02-27" -> (table)date
function Datetime.strToDate(input)
    local dateTa={}
    if string.isEmpty(input) then
        dateTa.year= Date_time_info.present.p_date.year
        dateTa.month= Date_time_info.present.p_date.month
        dateTa.day= Date_time_info.present.p_date.day
    else
        dateTa={
            ["year"]= math.floor(tonumber(string.sub(input,1,4) or"") or tonumber(Date_time_info.present.p_date.year) or 2022),
            ["month"]= math.floor(tonumber(string.sub(input,6,7) or"") or 1),
            ["day"]= math.floor(tonumber(string.sub(input,9,10) or"") or 1),
        }
    end
    return dateTa
end
function Datetime.stampAddPeriod(stamp,pUnit,pCount,pStart)
    stamp = stamp or Date_time_info.present.p_stamp
    pUnit = pUnit or "day"
    if pUnit ~="year" and pUnit ~="month" and pUnit ~="week" and pUnit ~="day" then
        pUnit= "day"
    end
    if tonumber(pCount)~=nil and tonumber(pCount)> Calendar_group.period_oldest[pUnit] then
        pCount = Calendar_group.period_oldest[pUnit]
    elseif tonumber(pCount)>0 then
        pCount = pCount
    elseif true or tonumber(pCount)<=0 then
        pCount = Calendar_group.period_older[pStart or Calendar_group.peroid_settings.start or "month"][pUnit]
    end
    if pUnit =="year" or pUnit =="month" then
        local pStart_d,pEnd_d
        pStart_d = Datetime.stampToDate(stamp,"day",false)
        if Calendar_group.peroid_settings.start =="year" then
            pEnd_d.year= pStart_d.year + pCount
            pEnd_d.month= pStart_d.month
        elseif true or Calendar_group.peroid_settings.start =="month" then
            pEnd_d.year= pStart_d.year + math.floor((pStart_d.month + pCount)/12)
            pEnd_d.month= (pStart_d.month + pCount)%12
        end
        return (os.time(pEnd_d)) -43200 +Date_time_info.timezone-Date_time_info.timezone_cus
    elseif true or pUnit =="day" or pUnit =="week" then
        local pSec= 0
        if pUnit =="week" then
            pSec= pCount *604800 -- 7*24*3600
        elseif true or pUnit =="day" then
            pSec= pCount *86400 -- 24*3600
        end
        return stamp + pSec
    end
end

-- 检测 给出的 access_token 是否有效
--* @return {["success"]= (boolean), ["statusCode"]= (Integer)}
function ApiTrakt.testAccessToken(accessToken,tokenType)
    if type(accessToken)~="string" or string.isEmpty(accessToken) then return {["success"]=false} end
    if type(tokenType)~="string" or string.isEmpty(tokenType) then tokenType= "bearer" end
    if not string.isEmpty(accessToken) and not string.isEmpty(tokenType)
            and (tokenType=="bearer" or tokenType=="Bearer") then
        local query = {
            ["ignore_collected"]= true,
            ["limit"]= 1,
        }
        local header = {
            ["Content-Type"]= "application/json",
            ["trakt-api-version"]= "2",
            ["trakt-api-key"]= settings["api_key_trakt"],
            ["Authorization"]= "Bearer "..accessToken
        }
        local hg_theme= "recommendations/shows" --shows/109975 Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.trakt.tv/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] Trakt.API.reply-test.access_token.httpget: ".. (err or "").."<"..
                    string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
            return {["success"]=false, ["statusCode"]= math.floor((reply or{}).statusCode or 0)}
        else
            return {["success"]=true, ["statusCode"]= math.floor((reply or{}).statusCode or 0)}
        end
    end
    return {["success"]=false}
end
-- 从缓存文件`./data/script_cache/trakt_OAuth.info`读取access_token，并判断有效。
--* isGuide(boolean)：读取失败或无效时，是否开启向导获取access_token。
--* @return { ["success"]= (boolean),  ["access_token"]= (nil/string) }
function ApiTrakt.getAccessToken(isGuide)
    -- 读取缓存文件
    local tauthAccesstValid, tauthTable = false, {}
    local tauthPathdir,tauthFilename= ".\\data\\script_cache\\","trakt_OAuth.info"
    if not os.execute("cd "..tauthPathdir) then
        os.execute("mkdir "..tauthPathdir)
    end
    local tauthIofile=io.open(tauthPathdir..tauthFilename,"r")
    if tauthIofile==nil then
        kiko.log("[ERROR] Cache file of Track OAuth <"..tauthPathdir..tauthFilename.."> NOT found.")
    else
        local err
        err,tauthTable= kiko.json2table(tauthIofile:read("*a") or"")
        if err ~= nil then
            kiko.log("[ERROR] Trakt.oauth.cache.read.json2table: " ..err)
        elseif table.isEmpty(tauthTable) then
            kiko.log("[INFO]  Trakt.oauth.cache.read.json2table: Empty table.")
        elseif true then
            if not string.isEmpty(tauthTable.access_token) and not string.isEmpty(tauthTable.token_type)
                    and (tauthTable.token_type=="bearer" or tauthTable.token_type=="Bearer") then
                local tauthAccesstTest= ApiTrakt.testAccessToken(tauthTable.access_token,tauthTable.token_type) or{}
                tauthAccesstValid = (tauthAccesstTest or {}).success or false
                if tauthAccesstValid then
                    type(0)
                elseif tauthAccesstTest.statusCode==401 or tauthAccesstTest.statusCode==403 then
                    local _,data = kiko.table2json({
                        ["refresh_token"]= tauthTable.refresh_token,
                        ["grant_type"]= "refresh_token",
                        ["client_id"]= settings["api_key_trakt"],
                        ["client_secret"]= tauthTable.client_secret,
                        ["redirect_uri"]= tauthTable.redirect_uri,
                    })
                    local header = {
                      ["Content-Type"]= "application/json",
                    }
                    local err,replyOt= kiko.httppost("https://api.trakt.tv/oauth/token",data,header)
                    if err ~= nil or (replyOt or{}).hasError==true then
                        kiko.log("[ERROR] Trakt.API.reply-test.oauth.ot.httpget: ".. (err or "").."<"..
                                string.format("%03d",(replyOt or{}).statusCode or 0)..">"..((replyOt or{}).errInfo or""))
                        -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
                    end
                    local err,objOt= kiko.json2table(replyOt.content)
                    if err ~= nil then
                        kiko.log("[ERROR] Trakt.oauth.ot.json2table: " ..err)
                    elseif table.isEmpty(objOt) then
                        kiko.log("[INFO]  Trakt.oauth.ot.json2table: Empty table.")
                    else
                        tauthAccesstValid = (ApiTrakt.testAccessToken(objOt.access_token, objOt.token_type) or{}).success or false
                        if tauthAccesstValid then
                            local tauthInfoT= {}
                            tauthInfoT= table.deepCopy(objOt) or{}
                            tauthInfoT.client_id= settings["api_key_trakt"]
                            tauthInfoT.client_secret= tauthTable.client_secret
                            tauthInfoT.redirect_uri= tauthTable.redirect_uri
                            
                            if not os.execute("cd "..tauthPathdir) then
                                os.execute("mkdir "..tauthPathdir)
                            end
                            local fileTai = io.open (tauthPathdir..tauthFilename ,"w") -- 覆盖写
                            local _,t2jTai= kiko.table2json(tauthInfoT)
                            if fileTai~=nil then
                                fileTai:write(t2jTai)
                                fileTai:close()
                            end
                            tauthTable= tauthInfoT
                            tauthAccesstValid= true
                        end
                    end
                    
                end
            end
        end
        tauthIofile:close()
    end
    if tauthAccesstValid then
        return { ["success"]=tauthAccesstValid, ["access_token"]=tauthTable.access_token, }
    else
        if isGuide==true or isGuide=="true" then
            type(0)
        elseif true or isGuide==nil or isGuide==false or isGuide=="false" then
            return { ["success"]=tauthAccesstValid, }
        end
    end

    -- start guide
    tauthAccesstValid = false
    local tauthClients,tauthReirectu = nil,nil
    local objOdc,objOdt = {},{}
    local replyOdc,replyOdt = {},{}
    local resDiaTF,resDiaInput= nil,nil
    local tauthTestCycle= true
    local data,header,query,err = nil, nil, nil, nil
    local diaTipErrorInfo= ""
    while(tauthTestCycle) do
        tauthAccesstValid = false
        tauthTestCycle= false
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备",
            ["tip"]="如果要让时间表的范围采用Trakt中您已收藏的媒体，需要您将Trakt账户授权此设备。\n\n"..
                    "[ √ ]\t继续向导：\n"..
                    "\t将Trakt账户授权此设备，请按步骤继续。\n"..
                    "[ × ]\t中断向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            -- ["text"]= ,
        })
        if resDiaTF == "accept" or resDiaTF == true then
            type(0)
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            goto jumpto_guideend_fail
        end
        kiko.execute(true, "cmd", {"/c", "start", "https://trakt.tv/oauth/applications"})
        -- input client_secret, redirect_uri
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 输入 Client Secret",
            ["tip"]="在弹出网页中点击您所申请的API，复制 `Client Secret`对应的值 到输入框。\n\n"..
                    "[ √ ]\t确认输入，并继续向导：\n"..
                    "\t输入框请只保留 `Client Secret`的值，不要留有空格和换行。\n"..
                    "[ × ]\t中断向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            ["text"]= tauthClients or "<<Client_Secret>>",
        })
        if resDiaTF == "accept" or resDiaTF == true then
            tauthClients= string.gsub(resDiaInput, "%s", "")
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            goto jumpto_guideend_fail
        end
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 输入 Redirect URI",
            ["tip"]="在弹出网页中点击您所申请的API，复制 `Redirect URI`对应的值 到输入框。\n\n"..
                    "[ √ ]\t确认输入，并继续向导：\n"..
                    "\t输入框请只保留 `Redirect URI`的值，不要留有空格和换行。\n"..
                    "[ × ]\t中断向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            ["text"]= tauthReirectu or "<<Redirect_URI>>",
        })
        if resDiaTF == "accept" or resDiaTF == true then
            tauthReirectu= string.gsub(resDiaInput, "%s", "")
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            goto jumpto_guideend_fail
        end
        -- fetch device_code
        data,header,query = nil, nil, nil
        _,data = kiko.table2json({ ["client_id"]= settings["api_key_trakt"], })
        header = { ["Content-Type"]= "application/json", }
        err,replyOdc= kiko.httppost("https://api.trakt.tv/oauth/device/code", data,header)
        if err ~= nil or (replyOdc or{}).hasError==true then
            kiko.log("[ERROR] Trakt.API.reply-test.oauth.odc.httpget: ".. (err or "").."<"..
                    string.format("%03d",(replyOdc or{}).statusCode or 0)..">"..((replyOdc or{}).errInfo or""))
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
            tauthTestCycle= true
            diaTipErrorInfo= (err or "").."<"..string.format("%03d",(replyOdc or{}).statusCode or 0)..">"..((replyOdc or{}).errInfo or"")
            goto jumpto_guideend_fail
        end
        err,objOdc= kiko.json2table(replyOdc.content)
        if err ~= nil then
            kiko.log("[ERROR] Trakt.oauth.odc.json2table: " ..err)
            tauthTestCycle= true
            diaTipErrorInfo= err
            goto jumpto_guideend_fail
        elseif table.isEmpty(objOdc) then
            kiko.log("[INFO]  Trakt.oauth.odc.json2table: Empty table.")
            tauthTestCycle= true
            diaTipErrorInfo= "Empty table."
            goto jumpto_guideend_fail
        end
        -- verify user_code
        kiko.execute(true, "cmd", {"/c", "start", objOdc.verification_url})
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 提交验证码",
            ["tip"]="请在"..string.format("%d",objOdc.expires_in/60).."分钟内，复制以下文本框内的 <验证码>\n"..
                    "并填入弹出的网页中，再点击`continue`提交。\n\n"..
                    "[ √ ]\t确认已提交，并继续向导：\n"..
                    "\t请确定提交成功后，请稍等几秒，再继续向导。\n"..
                    "[ × ]\t中断向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            ["text"]= objOdc.user_code,
        })
        if resDiaTF == "accept" or resDiaTF == true then
            type(0)
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            goto jumpto_guideend_fail
        end
        -- fetch access_token
        ::jumpto_odt_begin::
        _,data = kiko.table2json({
            ["code"]= objOdc.device_code,
            ["client_id"]= settings["api_key_trakt"],
            ["client_secret"]= tauthClients,
        })
        header = {
        ["Content-Type"]= "application/json",
        }
        err,replyOdt= kiko.httppost("https://api.trakt.tv/oauth/device/token",data,header)
        if err ~= nil or (replyOdt or{}).hasError==true then
            kiko.log("[ERROR] Trakt.API.reply-test.oauth.odt.httpget: ".. (err or "").."<"..
                    string.format("%03d",(replyOdt or{}).statusCode or 0)..">"..((replyOdt or{}).errInfo or""))
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
            diaTipErrorInfo= (err or "").."<".. string.format("%03d",(replyOdt or{}).statusCode or 0)..">"..((replyOdt or{}).errInfo or "")
            goto jumpto_odt_fail
        end
        err,objOdt= kiko.json2table(replyOdt.content)
        if err ~= nil then
            kiko.log("[ERROR] Trakt.oauth.odt.json2table: " ..err)
            diaTipErrorInfo= err
            goto jumpto_odt_fail
        elseif table.isEmpty(objOdt) then
            kiko.log("[INFO]  Trakt.oauth.odt.json2table: Empty table.")
            diaTipErrorInfo= "Empty table."
            goto jumpto_odt_fail
        end
        tauthAccesstValid = (ApiTrakt.testAccessToken(objOdt.access_token, objOdt.token_type) or{}).success
        if tauthAccesstValid then
            break
        else
            diaTipErrorInfo= "Invalid access_token detected."
            goto jumpto_odt_fail
        end
        ::jumpto_odt_fail::
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 未检测到 验证码提交成功",
            ["tip"]="\t检测到当前此次验证码提交失败："..diaTipErrorInfo.."。\n\t请 再次检测验证码提交情况、重新开始向导、或 退出向导。\n\n"..
                    "[ 8 ]\t再次检测 验证码提交情况：\n"..
                    "\t在文本框仅输入数字`8`一个字符，并稍等一会儿再点击确认；将再次尝试检测 验证码是否提交成功。\n"..
                    "[ √ ]\t重新开始向导：\n"..
                    "\t将重新开始向导。\n"..
                    "[ × ]\t退出向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            ["text"]= "",
        })
        if resDiaTF == "accept" or resDiaTF == true then
            if resDiaInput=="8" then goto jumpto_odt_begin end
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            goto jumpto_guideend_fail
        end
        ::jumpto_guideend_fail::
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 此次授权失败",
            ["tip"]="\t此次授权失败："..diaTipErrorInfo.."。\n\n"..
                    "[ √ ]\t重新开始向导：\n"..
                    "\t将重新开始向导。\n"..
                    "[ × ]\t退出向导：\n"..
                    "\t将无法让时间表的范围采用Trakt中您已收藏的媒体，\n\t请更改设置项`时间表 - 媒体范围`为不包括`已收藏/my`的选项。",
            -- ["text"]= nil,
        })
        if resDiaTF == "accept" or resDiaTF == true then
            tauthTestCycle =true
        elseif true or resDiaTF == "reject" or resDiaTF == false then
            tauthTestCycle =false
        end
        if not tauthTestCycle then
            return { ["success"]=false, }
        end
    end
    if tauthAccesstValid then
        local tauthInfoT= {}
        tauthInfoT= table.deepCopy(objOdt) or{}
        tauthInfoT.client_id= settings["api_key_trakt"]
        tauthInfoT.client_secret= tauthClients
        tauthInfoT.redirect_uri= tauthReirectu
        
        if not os.execute("cd "..tauthPathdir) then
            os.execute("mkdir "..tauthPathdir)
        end
        local fileTai = io.open (tauthPathdir..tauthFilename ,"w") -- 覆盖写
        local _,t2jTai= kiko.table2json(tauthInfoT)
        if fileTai~=nil then
            fileTai:write(t2jTai)
            fileTai:close()
        end
        resDiaTF,resDiaInput= kiko.dialog({
            ["title"]="向导 - 将Trakt账户授权此设备 - 验证成功",
            ["tip"]= "\t验证成功！\n\n已Trakt账户授权此设备，现在时间表的范围 可以采用Trakt中您已收藏的媒体了。",
        })
        return { ["success"]=tauthAccesstValid, ["access_token"]=tauthInfoT.access_token, }
    else
        return { ["success"]=false, }
    end
end
