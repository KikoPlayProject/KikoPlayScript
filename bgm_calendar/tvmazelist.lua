-- TVmaze List
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TVmazeList",
    ["id"] = "Kikyou.b.TVmazeList",
	["desc"] = "TVmaze 剧集日历脚本（测试中，不稳定） Edited by: kafovin \n"..
                "从 tvmaze.com 刮削剧集的日历时间表。",
	["version"] = "0.1.1", -- 0.1.1.20220305_build
}

-- 设置项
settings = {
    ["schedule_info_type"]={
        ["title"]="时间表 - 剧集类型",
        ["default"]="series_shows",
        ["desc"]="时间表中出现的剧集类型。\n"..
                "series_only：仅剧集。series_shows：包括剧集、节目等。",
        ["choices"]="series_only,series_shows"
    },
    ["schedule_sort"]={
        ["title"]="时间表 - 排序",
        ["default"]="timeslot",
        ["desc"]="将每日时间表按此顺序排列。\n"..
                "time：按时间升序。timeslot：按时间档升序。title：按名称升序。",
                -- "default：默认。time：按时间升序。",
        ["choices"]="time,timeslot,title",
        -- ["choices"]="default,time",
    },
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
                "system:系统默认时区。",
        ["choices"]="system,-12,-11,-10,-09,-08,-07,-06,-05,-04,-03,-02,-01,+00,+01,+02,+03,+04,+05,+06,+07,+08,+09,+10,+11,+12",
    },
    ["datetime_zone_minute"]={
        ["title"]="时间 - 时区分钟",
        ["default"]="system",
        ["desc"]="使用时区的分钟数。目前仅限使用程序在当前系统的默认时区。\nAsia/Shanghai(亚洲/上海)的时区为`+08:00`，即此处为`00`。\n"..
                "system:系统默认时区。",
        ["choices"]="system,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,"..
                    "30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59",
    },
}
-- (()and{}or{})[1]

--[[ copy from & thanks to "../bgm_calendar/bgmlist.lua" in "KikoPlay/bgm_calendar"|KikoPlayScript
_, Site_map = kiko.json2table([[{"acfun":{"title":"AcFun","urlTemplate":"https://www.acfun.cn/bangumi/aa{{id}}","regions":["CN"],"type":"onair"},"bilibili":{"title":"哔哩哔哩","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["CN"],"type":"onair"},"bilibili_hk_mo_tw":{"title":"哔哩哔哩（港澳台）","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["HK","MO","TW"],"type":"onair"},"sohu":{"title":"搜狐视频","urlTemplate":"https://tv.sohu.com/{{id}}","regions":["CN"],"type":"onair"},"youku":{"title":"优酷","urlTemplate":"https://list.youku.com/show/id_z{{id}}.html","regions":["CN"],"type":"onair"},"qq":{"title":"腾讯视频","urlTemplate":"https://v.qq.com/detail/{{id}}.html","regions":["CN"],"type":"onair"},"iqiyi":{"title":"爱奇艺","urlTemplate":"https://www.iqiyi.com/{{id}}.html","regions":["CN"],"type":"onair"},"letv":{"title":"乐视","urlTemplate":"https://www.le.com/comic/{{id}}.html","regions":["CN"],"type":"onair"},"pptv":{"title":"PPTV","urlTemplate":"http://v.pptv.com/page/{{id}}.html","regions":["CN"],"type":"onair"},"mgtv":{"title":"芒果tv","urlTemplate":"https://www.mgtv.com/h/{{id}}.html","regions":["CN"],"type":"onair"},"nicovideo":{"title":"Niconico","urlTemplate":"https://ch.nicovideo.jp/{{id}}","regions":["JP"],"type":"onair"},"netflix":{"title":"Netflix","urlTemplate":"https://www.netflix.com/title/{{id}}","type":"onair"},"gamer":{"title":"動畫瘋","urlTemplate":"https://acg.gamer.com.tw/acgDetail.php?s={{id}}","regions":["TW"],"type":"onair"},"muse_hk":{"title":"木棉花 HK","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","MO"],"type":"onair"},"ani_one_asia":{"title":"Ani-One Asia","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","TW","MO","SG","MY","PH","TH","ID","VN","KH","BD","BN","BT","FJ","FM","IN","KH","LA","LK","MH","MM","MN","MV","NP","NR","PG","PK","PW","SB","TL","TO","TV","VU","WS"],"type":"onair"},"viu":{"title":"Viu","urlTemplate":"https://www.viu.com/ott/hk/zh-hk/vod/{{id}}/","regions":["HK","SG","MY","IN","PH","TH","MM","BH","EG","JO","KW","OM","QA","SA","AE","ZA"],"type":"onair"}}]]
--)]]
-- as above

Array={}
Datetime={}
Schedule_info={["country"]= {"US","GB","JP"},}
Calendar_group={
    ["deviance"]={-1,1,0}
}
Date_time_info={
    ["timezone"]=nil,-- 记录系统时区
    ["timezone_cus"]=nil,-- 记录设置的时区
    ["calendar_week_start"]="2022-01-01",
    ["weekEnNum"]= {["Sunday"]=0,["Monday"]=1,["Tuesday"]=2,["Wednesday"]=3,["Thursday"]=4,["Friday"]=5,["Saturday"]=6,},
    ["custom_week_title"]= "自定义星期",
    ["str_format"]="%Y-%m-%d||%H:%M:%S||%z||%U-%w",
    ["present"]= nil,
}

--* any timestamp , (boolean)isToSun::false -> the (sun) date
function Datetime.stampToDate(stamp,isToSun)
    if stamp<0 then
        stamp=Date_time_info.present.p_stamp
    end
    -- 24*3600=86400
    local sundTmp
    if isToSun==true then
        sundTmp=os.date("*t",stamp- 86400*tonumber(os.date("%w",stamp)))
    elseif true or isToSun==false then
        sundTmp=os.date("*t",stamp)
    end
    local sund={}
    sund.year=sundTmp.year
    sund.month=sundTmp.month
    sund.day=sundTmp.day
    return sund
end
--* get present (table) p.st p.d sun.d sun.st
function Datetime.getPresent()
    local pStamp,pDate,pSunDate,pSunStamp,pZone
    pStamp= os.time()
    pDate= Datetime.stampToDate(pStamp,false)
    pSunDate= Datetime.stampToDate(pStamp,true)
    pSunStamp=(os.time(pSunDate)) -43200 -- 12*3600
    pZone= os.date("%z",pStamp) -- +0800
    return {
        ["p_stamp"] = pStamp,--presentTimeStamp Date_time_info.present.sun_stamp
        ["p_date"] = pDate,--presentTimeStamp Date_time_info.present.sun_stamp
        ["sun_date"]= pSunDate,--thisSunDate
        ["sun_stamp"]= pSunStamp,--thisSunStamp),
    },{
        ["hour"]= math.floor(tonumber(string.sub(pZone or"",1,3)) or 0),
        ["min"]= math.floor(tonumber(string.sub(pZone or"",4,5)) or 0),
    }
end
function Datetime.getZoneSettings()
    return {
        ["hour"]= (( settings["datetime_zone_hour"]=="system"  ) and{ Date_time_info.timezone.hour}
                    or{ math.floor(tonumber( settings["datetime_zone_hour"]  ) or Date_time_info.timezone.hour) })[1],
        ["min"]=  (( settings["datetime_zone_minute"]=="system") and{ Date_time_info.timezone.min }
                    or{ math.floor(tonumber( settings["datetime_zone_minute"]) or Date_time_info.timezone.min ) })[1],
    }
end

Date_time_info.present, Date_time_info.timezone= Datetime.getPresent()
Date_time_info.timezone_cus= Datetime.getZoneSettings()


---------------------
-- 日历脚本部分
-- copy (as template) from & thanks to "../bgm_calendar/bgmlist.lua" in "KikoPlay/library"|KikoPlayScript
--

function getseason()
    Date_time_info.timezone_cus= Datetime.getZoneSettings
    -- date|time|zone|week -- 2022-02-27||17:05:02||CST||09-0
    kiko.log("[INFO]  Getting calendar group of <" .. os.date(Date_time_info.str_format,Date_time_info.present.p_stamp) .. ">")
    -- kiko.log("[TEST]  " .. os.date(Date_time_info.str_format,Date_time_info.present.sun_stamp) .. ">")
    -- kiko.log("[TEST]  ! "..os.date("!%Y-%m-%dT%H:%M:%S+%z",Date_time_info.present.p_stamp))

    -- any timestamp -> the sunday timestamp
    local theSunStamp= {-1} -- -1::customized
    for _, dev in ipairs(Calendar_group.deviance) do
        table.insert(theSunStamp,Date_time_info.present.sun_stamp + (dev or 0)*604800) -- 7*24*3600=604800
    end

    local cldgInfo={}
    local cTitle,cData="",{}
    local pWeekDateInfo= ""
    for _, tss in ipairs(theSunStamp) do
        cTitle,cData="",{}

        if tss<0 then
            tss=Date_time_info.present.sun_stamp
            cTitle= Date_time_info.custom_week_title
            pWeekDateInfo,cData.dt_sun=Datetime.theSunStampToDt(tss)
        else
            pWeekDateInfo,cData.dt_sun=Datetime.theSunStampToDt(tss)
            cTitle= string.sub(pWeekDateInfo[1],1,10)
        end

        local err, cDataJson = kiko.table2json(cData)
        if err ~= nil then
            kiko.log(string.format("[ERROR] table2json: %s", err))
        end
        table.insert(cldgInfo,{
            ["title"]=cTitle,
            ["data"]=cDataJson,
        })
    end
    kiko.log("[INFO]  Finished getting " .. #cldgInfo .. " calendar groups.")
    return cldgInfo
end

function getbgmlist(season)
    kiko.log("[INFO]  Starting getting TVmaze list of <" .. season["title"]..">")

    Date_time_info.timezone_cus= Datetime.getZoneSettings()
    -- kiko.log("[TEST]  "..table.toStringBlock(Date_time_info))

    local err, objCldg = kiko.json2table(season.data or"{}")
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    if table.isEmpty(objCldg) or table.isEmpty(objCldg.dt_sun) then
        kiko.log("[WARN]  (BgmSeason)season."..(season.title or "_")..":[\"data\"] not found.")
        -- error("[WARN]  (BgmSeason)season."..season.title..": "..err)
        -- Datetime.
        objCldg={}
        if string.isEmpty(season.title) then
            season.title="_"
            _,objCldg.dt_sun=Datetime.theSunStampToDt(Date_time_info.present.sun_stamp)
        elseif true or not string.isEmpty(season.title) then
            _,objCldg.dt_sun=Datetime.theSunStampToDt(Datetime.strToStamp(season.title))
        end
    end

    --for each date of the week
    local weeksInfo ={}
    local sunday0100=objCldg.dt_sun.stamp
    if season.title==Date_time_info.custom_week_title then
        local pdatestr=string.format("%04d-%02d-%02d",Date_time_info.present.p_date.year,Date_time_info.present.p_date.month,Date_time_info.present.p_date.day)
        local resDiaTF, resInput = kiko.dialog({
            ["title"] = "请输入要查询的日期。",
            ["tip"] = "日期形如 <"..pdatestr..">： 确认->获取该日期所在周的节目单。 取消->不获取。",
            ["text"]= pdatestr,
        })
            sunday0100= Datetime.strToStamp(resInput)
            -- kiko.log("[TEST]  in  "..os.date(Date_time_info.str_format,sunday0100))
            sunday0100=(os.time(Datetime.stampToDate(sunday0100,true))) -43200 -- 12*3600
            -- kiko.log("[TEST]  sun "..os.date(Date_time_info.str_format,sunday0100))
        -- 从对话框确定媒体类型
        if resDiaTF == "accept" or resDiaTF == true then
        elseif resDiaTF == "reject" or resDiaTF == false then
            return {}
        else
        end
    end

    local dday0100=sunday0100 -- each day stamp
    for wday = -1, 7, 1 do
        dday0100=sunday0100 +86400*wday -- 24*3600=86400
        local queryCs = {
            ["date"]=os.date("%Y-%m-%d",dday0100+3600),
            ["country"]="",
        }
        local header = {["Accept"] = "application/json"}
        local urlPrefixLocal="https://api.tvmaze.com/schedule"
        local urlPrefixWeb="https://api.tvmaze.com/schedule/web"
        local replyCs,contentCs, objCs,objCsw=nil,nil, {},{}

        for _, countrySi in ipairs(Schedule_info.country) do
            queryCs.country = countrySi
            replyCs,contentCs, objCs,objCsw=nil,nil, {},{}

            err,replyCs = kiko.httpget(urlPrefixLocal, queryCs, header)
            if err ~= nil or replyCs==nil then
                kiko.log("[ERROR] TVmaze.schedule.reply-week."..queryCs.date..".of." ..(season.title or"") ..countrySi.. ".local.httpget: " .. (err or""))
                goto continue_gbl_wi
                -- error(err)
            end
            contentCs = replyCs["content"]
            err, objCs = kiko.json2table(contentCs)
            if err ~= nil then
                kiko.log("[ERROR] TVmaze.schedule.reply-week."..queryCs.date..".of." ..(season.title or"") ..countrySi.. ".local.json2table: " .. err)
                goto continue_gbl_wi
                -- error(err)
            end
            err,replyCs = kiko.httpget(urlPrefixWeb, queryCs, header)
            if err ~= nil then
                kiko.log("[ERROR] TVmaze.schedule.reply-week."..queryCs.date..".of." ..(season.title or"") ..countrySi.. ".web.httpget: " .. err)
                goto continue_gbl_wi
                -- error(err)
            end
            contentCs = replyCs["content"]
            err, objCsw = kiko.json2table(contentCs)
            if err ~= nil then
                kiko.log("[ERROR] TVmaze.schedule.reply-week."..queryCs.date..".of." ..(season.title or"") ..countrySi.. ".web.json2table: " .. err)
                goto continue_gbl_wi
                -- error(err)
            end

            Array.extend(objCs,objCsw)
            objCsw=nil
            for _,ep in ipairs(objCs) do
                if table.isEmpty(ep.show) then goto continue_gbl_wii
                elseif string.isEmpty((ep.show or{}).name) then goto continue_gbl_wii
                end
                local dtStamp= (Datetime.strToStamp(ep.airstamp))
                if dtStamp<sunday0100 or dtStamp>=(sunday0100 +604800) then-- 7*24*3600=604800
                    goto continue_gbl_wii
                end

                if settings["schedule_info_type"]=="series_only" then
                    if (ep.show or{}).type~="Scripted" then
                        goto continue_gbl_wii
                    end
                elseif true or settings["schedule_info_type"]=="series_shows" then
                end

                local wSites={}
                -- if (tonumber(ep.season)~=nil or tonumber(ep.number)~=nil) then
                if (tonumber(ep.number)~=nil) then
                    table.insert(wSites,{
                            ["name"]=--((tonumber(ep.season)==nil) and{ "" } or{ string.format("S%02s", math.floor(tonumber(ep.season))) })[1] ..
                                ((tonumber(ep.number)==nil) and{ "" } or{ string.format("E%02s", math.floor(tonumber(ep.number))) })[1],
                        })
                end
                if not string.isEmpty(((ep.show or{}).network or{}).name) then
                    table.insert(wSites,{ ["name"]=((ep.show or{}).network or{}).name, ["url"]=(ep.show or{}).officialSite})
                end
                if not string.isEmpty(((ep.show or{}).webChannel or{}).name) then
                    table.insert(wSites,{ ["name"]=((ep.show or{}).webChannel or{}).name, ["url"]=(ep.show or{}).officialSite})
                end
                -- if not string.isEmpty((ep.show or{}).officialSite) then
                --     table.insert(wSites,{ ["name"]="主页", ["url"]=(ep.show or{}).officialSite})
                -- end
                if not string.isEmpty(ep.url) then
                    table.insert(wSites,{ ["name"]="TVmaze", ["url"]=(ep.show or{}).url,})
                end
                if not string.isEmpty(((ep.show or{}).externals or{}).imdb) then
                    table.insert(wSites,{ ["name"]="IMDb", ["url"]="https://www.imdb.com/title/"..((ep.show or{}).externals or{}).imdb})
                end
                if not string.isEmpty((ep.show or{}).name) then
                    local tmpSeasont=""
                    if not string.isEmpty(ep.season) and tonumber(ep.season)~=nil then
                        tmpSeasont=tmpSeasont.."%20S"..string.format("%02d",math.floor(tonumber( ep.season )))
                    end
                    
                    table.insert(wSites,{ ["name"]="字幕库", ["url"]="https://zmk.pw/search?q="..string.gsub((ep.show or{}).name or"","[ %c%p]","+")})
                    table.insert(wSites,{ ["name"]="SubHD", ["url"]="https://subhd.tv/search/"..string.gsub((ep.show or{}).name or"","[ %c%p]","%%20")})
                    table.insert(wSites,{ ["name"]="YYeTs", ["url"]="https://www.yysub.net/search/index?search_type=&keyword="..string.gsub((ep.show or{}).name or"","[ %c%p]","+")})
                end
                if not string.isEmpty(((ep.show or{}).externals or{}).imdb) then
                    table.insert(wSites,{ ["name"]="OpenSubtitles", ["url"]="https://www.opensubtitles.com/zh-CN/zh-CN,zh-TW,en/search-all/q-"..
                                ((ep.show or{}).externals or{}).imdb.. "/hearing_impaired-include/machine_translated-include/trusted_sources-"})
                end
                -- if not string.isEmpty(((ep.show or{}).externals or{}).thetvdb) then
                --     table.insert(wSites,{ ["name"]="TVDb", ["url"]="https://thetvdb.com/series/"..((ep.show or{}).externals or{}).thetvdb})
                -- end
                -- if not string.isEmpty(((ep.show or{}).externals or{}).tvrage) then
                --     table.insert(wSites,{ ["name"]="TVRage", ["url"]="https://www.tvrage.com/"..((ep.show or{}).externals or{}).thetvdb})
                -- end
                
                table.insert(weeksInfo,{
                    ["title"]=((ep.show or{}).name or"").. ((tonumber(ep.season)==nil and tonumber(ep.number)==nil)and{""}
                                or{ string.format(" S%02s", math.floor(tonumber(ep.season))) })[1],-- ..
                            -- ((tonumber(ep.number)==nil) and{ "" } or{ string.format("E%02s", math.floor(tonumber(ep.number))) })[1],
                    ["weekday"]= ((tonumber( os.date("%w",dtStamp) )==nil)and{ nil }or{ math.floor(tonumber( os.date("%w",dtStamp) ))})[1], --放送星期，取值0(星期日)~6(星期六)
                    -- ["weekday"]=Date_time_info.weekEnNum[(((ep.show or{}).schedule or{}).days or{})[1]],
                    ["time"]=os.date("%H:%M",dtStamp), --放送时间
                    ["date"]=(ep.show or{}).premiered, --放送日期
                    ["isnew"]= ((tonumber(ep.season)==nil) and{ false }or{ math.floor(tonumber(ep.season))==1 })[1], --是否新番
                    -- ["bgmid"]=nil, --tvmaze id
                    ["bgmid"]=((ep.show or{}).externals or{}).thetvdb, --tvdb id
                    ["sites"]= wSites, --放送站点列表
                    ["stamp"]=dtStamp,
                })
                ::continue_gbl_wii::
            end
            ::continue_gbl_wi::
        end
    end
    kiko.log("[INFO]  Finished getting " .. #weeksInfo .. " info of < " .. season.title .. ">")
    if settings["schedule_sort"]=="time" then
        table.sort(weeksInfo, function(a,b) return a.stamp<b.stamp end)
    elseif settings["schedule_sort"]=="title" then
        table.sort(weeksInfo, function(a,b) return a.title<b.title end)
    elseif settings["schedule_sort"]=="timeslot" then
        table.sort(weeksInfo, function(a,b) return a.time<b.time end)
    end
    return weeksInfo
end

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
-- string.isEmpty():: nil->true | "" -> true
function string.isEmpty(input)
    if input==nil or tostring(input)==""
            or not (type(input)=="string" or type(input)=="number" or type(input)=="boolean") then
        return true
    else return false
    end
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

--* (string)str :: "2022-02-27" -> (table)date
function Datetime.strToDate(input)
    local dateTa={}
    if string.isEmpty(input) then
        local dateTaTmp= os.date("*t",Date_time_info.present.p_stamp)
        dateTa.year=dateTaTmp.year
        dateTa.month=dateTaTmp.month
        dateTa.day=dateTaTmp.day
    else
        local dataTap= os.date("*t",Date_time_info.present.p_stamp)
        dateTa={
            ["year"]= math.floor(tonumber(string.sub(input,1,4) or"") or dataTap.year),
            ["month"]= math.floor(tonumber(string.sub(input,6,7) or"") or 1),
            ["day"]= math.floor(tonumber(string.sub(input,9,10) or"") or 1),
        }
    end
    return dateTa
end
--* (string)str :: "2022-03-01T05:00:00+00:00" -> timestamp
function Datetime.strToStamp(input)
    local dateTa={}
    local hourZdt,minZdt=0,0
    -- if isFromLocal==nil then isFromLocal=false end

    if string.isEmpty(input) then
        return Date_time_info.present.p_stamp
    else
        local dataTap= os.date("*t",Date_time_info.present.p_stamp)
        dateTa={
            ["year"]= math.floor(tonumber(string.sub(input,1,4) or"") or dataTap.year),
            ["month"]= math.floor(tonumber(string.sub(input,6,7) or"") or 1),
            ["day"]= math.floor(tonumber(string.sub(input,9,10) or"") or 1),
            ["hour"]= math.floor(tonumber(string.sub(input,12,13) or"") or 0),
            ["min"]= math.floor(tonumber(string.sub(input,15,16) or"") or 0),
            ["sec"]= math.floor(tonumber(string.sub(input,18,19) or"") or 0),
        }
        hourZdt= math.floor(tonumber(string.sub(input,20,22) or"") or math.floor(tonumber(Date_time_info.timezone_cus.hour)))
        minZdt= math.floor(tonumber(string.sub(input,24,25) or"") or math.floor(tonumber(Date_time_info.timezone_cus.min)))
    end
    hourZdt= hourZdt -math.floor(tonumber(Date_time_info.timezone_cus.hour))
    minZdt= minZdt -math.floor(tonumber(Date_time_info.timezone_cus.min))
    return os.time(dateTa) -3600*hourZdt -60*minZdt
end
--* theSunStamp -> (str)"||"", (table)dt_sun
function Datetime.theSunStampToDt(tss)
    if tss<0 then
        tss=Date_time_info.present.p_stamp
    end
    local dt_sun={}
    -- kiko.log("[TEST]  "..tss)
    local pWeekDateInfo= string.split(os.date(Date_time_info.str_format,tss),"||")
    dt_sun.stamp= os.time(Datetime.strToDate(pWeekDateInfo[1]))-43200 -- 12*3600
    -- dt_sun.date= (pWeekDateInfo[1])
    -- dt_sun.time= (pWeekDateInfo[2])
    -- dt_sun.zone= (pWeekDateInfo[3])
    -- dt_sun.week= (pWeekDateInfo[4])
    return pWeekDateInfo,dt_sun
end
