-- TVmaze List
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TVmazeList",
    ["id"] = "Kikyou.b.TVmazeList",
    ["desc"] = "TVmaze 剧集日历脚本（测试中，不稳定） Edited by: kafovin \n"..
                "从 tvmaze.com 刮削剧集的日历时间表。",
    ["version"] = "0.1.22", -- 0.1.22.221004_fix
    ["min_kiko"] = "0.9.1",
}

-- 设置项
settings = {
    ["schedule_info_type_02"]={
        ["title"]="时间表 - 剧集类型",
        ["default"]="scripted",
        ["desc"]="时间表中出现的剧集、节目类型。\n"..
                "scripted：包含剧本类、动画类、纪录类等剧集 (默认)。scripted_variety：包含前者，以及综艺节目、颁奖节目等。\n"..
                "scripted_show：包含前者，以及游戏节目、真人节目、访谈节目、讨论节目等。tv_show：包括前者，以及体育节目、新闻节目等，即所有节目。",
        ["choices"]="scripted,scripted_variety,scripted_show,tv_show",
        ["group"]="时间表",
    },
    ["schedule_sort"]={
        ["title"]="时间表 - 排序",
        ["default"]="timeslot",
        ["desc"]="将每日时间表按此顺序排列，顺序相同的以`标题 季序号 集序号`为序。\n"..
                "time：按时间升序。timeslot：按时间档升序 (默认)。title：按名称升序。",
                -- "default：默认。time：按时间升序。",
        ["choices"]="time,timeslot,title",
        -- ["choices"]="default,time",
        ["group"]="时间表",
    },
    ["schedule_date_release_type"]={
        ["title"]="时间表 - 放送日期类型",
        ["default"]="show_x_ep",
        ["desc"]="时间表中，`放送日期`的一列显示的日期类型。\n"..
                "episode：均为该集的播映日期。\n"..
                "show：均为剧集最初的播映日期，通常为S01E01或试播集的播映日期。\n"..
                "show_x_ep：一般为剧集最初的播映日期，对于`自定义星期`是该集的播映日期 (默认)。",
        ["choices"]="episode,show,show_x_ep",
        ["group"]="时间表",
    },
    ["season_deviance_older"]={
        ["title"]="分组列表 - 近几周",
        ["default"]="54",
        ["desc"]="分组的列表中，显示现在及以前几周。列表倒数第2个为 下一周，最后一个为本周。请保存设置后重启，方可查看新的分组列表。\n"..
                "近1周为 1 (即本周)，近2周为 2 (即本周、上一周)，以此类推。\n"..
                "0：自1989-12-17所在一周至今。 54：近54周 (默认)。",
        -- 用 1989-12-17 是因为TVmaze网站日历的默认显示，似乎从这一天开始逐渐有内容，即 The Simpsons S01E01 播出时的那一周。
        ["group"]="分组列表",
    },
    ["season_order_nextweek"]={
        ["title"]="分组列表 - 显示下一周",
        ["default"]="0",
        ["desc"]="分组的列表中，下一周的位置。\n"..
                "0：不显示 (默认)。 1：显示在`本周`的后一个。\n"..
                "-1：显示在`本周`的前一个 (可能会影响`关注`功能的识别)。",
        ["choices"]="-1,0,1",
        ["group"]="分组列表",
    },
    -- ["season_naming_date"]={
    --     ["title"]="分组列表 - 日期格式",
    --     ["default"]="Y-m-d",
    --     ["desc"]="分组的列表中，周名的日期格式。建议与`时间表 - 放送日期类型`的设置搭配以分辨日期。\n"..
    --             "[注意]  更改此设置后，以前载入的周会无法识别。\n"..
    --             "[注意]  要使用以前的时间表需要手动重命名此目录下的缓存：`.\\KikoPlay\\data\\calendar\\Kikyou.b.TVmazeList`\n"..
    --             "Y-m-d：年份-月份-日期，如 `2021-12-31` (默认)。Ymd：年份月份日期，如 `20211231`。\n"..
    --             "Y-m-u：年份-月份-该月周序号，如 `2021-12-5`。Ymu：年份-月份-该月周序号，如 `2021125`。\n"..
    --             "Y-U：年份-该年周序号，如 `2021-52`。YU：年份-该年周序号，如 `202152`。\n",
    --     ["choices"]="Y-m-d,Ymd,Y-m-u,Ymu,Y-U,YU",
    --     ["group"]="分组列表",
    -- },
    -- ["datetime_zone"]={
    --     ["title"]="时间 - 时区",
    --     ["default"]="system",
    --     ["desc"]="使用的时区。目前仅限使用程序在当前系统的默认时区。\n"..
    --             "system:系统默认时区。",
    --     ["choices"]="system,+08:00"
    --     ["group"]="时间时区",
    -- },
    ["datetime_zone_hour"]={
        ["title"]="时间 - 时区小时",
        ["default"]="system",
        ["desc"]="使用时区的小时数。目前仅限使用程序在当前系统的默认时区。\nAsia/Shanghai(亚洲/上海)的时区为`+08:00`，即此处为`+08`。\n"..
                "system:系统默认时区 (默认)。",
        ["choices"]="system,-12,-11,-10,-09,-08,-07,-06,-05,-04,-03,-02,-01,+00,+01,+02,+03,+04,+05,+06,+07,+08,+09,+10,+11,+12",
        ["group"]="时间时区",
    },
    ["datetime_zone_minute"]={
        ["title"]="时间 - 时区分钟",
        ["default"]="system",
        ["desc"]="使用时区的分钟数。目前仅限使用程序在当前系统的默认时区。\nAsia/Shanghai(亚洲/上海)的时区为`+08:00`，即此处为`00`。\n"..
                "system:系统默认时区 (默认)。",
        ["choices"]="system,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,"..
                    "30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59",
        ["group"]="时间时区",
    },
}

scriptmenus = {
    {["title"]="检测连接", ["id"]="detect_valid_connect"},
    {["title"]="使用方法", ["id"]="link_repo_usage"},
    {["title"]="关于", ["id"]="display_dialog_about"},
}

-- (()and{}or{})[1]

--[[ copy from & thanks to "../bgm_calendar/bgmlist.lua" in "KikoPlay/bgm_calendar"|KikoPlayScript
_, Site_map = kiko.json2table([[{"acfun":{"title":"AcFun","urlTemplate":"https://www.acfun.cn/bangumi/aa{{id}}","regions":["CN"],"type":"onair"},"bilibili":{"title":"哔哩哔哩","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["CN"],"type":"onair"},"bilibili_hk_mo_tw":{"title":"哔哩哔哩（港澳台）","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["HK","MO","TW"],"type":"onair"},"sohu":{"title":"搜狐视频","urlTemplate":"https://tv.sohu.com/{{id}}","regions":["CN"],"type":"onair"},"youku":{"title":"优酷","urlTemplate":"https://list.youku.com/show/id_z{{id}}.html","regions":["CN"],"type":"onair"},"qq":{"title":"腾讯视频","urlTemplate":"https://v.qq.com/detail/{{id}}.html","regions":["CN"],"type":"onair"},"iqiyi":{"title":"爱奇艺","urlTemplate":"https://www.iqiyi.com/{{id}}.html","regions":["CN"],"type":"onair"},"letv":{"title":"乐视","urlTemplate":"https://www.le.com/comic/{{id}}.html","regions":["CN"],"type":"onair"},"pptv":{"title":"PPTV","urlTemplate":"http://v.pptv.com/page/{{id}}.html","regions":["CN"],"type":"onair"},"mgtv":{"title":"芒果tv","urlTemplate":"https://www.mgtv.com/h/{{id}}.html","regions":["CN"],"type":"onair"},"nicovideo":{"title":"Niconico","urlTemplate":"https://ch.nicovideo.jp/{{id}}","regions":["JP"],"type":"onair"},"netflix":{"title":"Netflix","urlTemplate":"https://www.netflix.com/title/{{id}}","type":"onair"},"gamer":{"title":"動畫瘋","urlTemplate":"https://acg.gamer.com.tw/acgDetail.php?s={{id}}","regions":["TW"],"type":"onair"},"muse_hk":{"title":"木棉花 HK","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","MO"],"type":"onair"},"ani_one_asia":{"title":"Ani-One Asia","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","TW","MO","SG","MY","PH","TH","ID","VN","KH","BD","BN","BT","FJ","FM","IN","KH","LA","LK","MH","MM","MN","MV","NP","NR","PG","PK","PW","SB","TL","TO","TV","VU","WS"],"type":"onair"},"viu":{"title":"Viu","urlTemplate":"https://www.viu.com/ott/hk/zh-hk/vod/{{id}}/","regions":["HK","SG","MY","IN","PH","TH","MM","BH","EG","JO","KW","OM","QA","SA","AE","ZA"],"type":"onair"}}]]
--)]]
-- as above

Array={}
Datetime={}
Schedule_info={["country"]= {"GB","US","JP","CN"},}
Calendar_group={
    ["deviance_old"]={-1,1,0},
    ["deviance_older"]=-10,
    ["deviance_oldest"]=-1689, -- math.ceil(os.difftime(Date_time_info.present.sun_stamp,Datetime.strToStamp("1989-12-17T20:00:00-05:00"))/604800.0) -- 3600*24*7
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

Translation = {
    ["und-XX"] = {
        ["show_type"]={ [""]= "Others", ["Unknown"]= "Unknown" },
    },
}
Translation["zh-CN"] = {
    ["show_type"]= {
        ["Scripted"]= "剧本类", ["Animation"]= "动画类", ["Documentary"]= "纪录类", ["Reality"]= "真人节目", ["Variety"]= "综艺节目", ["Game Show"]= "游戏节目", ["Award Show"]= "颁奖典礼", ["Talk Show"]= "访谈节目", ["Panel Show"]= "讨论节目", ["Sports"]= "体育节目", ["News"]= "新闻节目",
        [""]= "其他", ["Unknown"]= "未知",
    },
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
    Date_time_info.timezone_cus= Datetime.getZoneSettings()
    -- date|time|zone|week -- 2022-02-27||17:05:02||CST||09-0
    kiko.log("[INFO]  Getting calendar group of <" .. os.date(Date_time_info.str_format,Date_time_info.present.p_stamp) .. ">")
    -- kiko.log("[TEST]  " .. os.date(Date_time_info.str_format,Date_time_info.present.sun_stamp) .. ">")
    -- kiko.log("[TEST]  ! "..os.date("!%Y-%m-%dT%H:%M:%S+%z",Date_time_info.present.p_stamp))

    -- any timestamp -> the sunday timestamp
    local theSunStamp= {-1} -- -1::customized
    local clgDvTmp={}
    local clgDvO=0

    local season_deviance_older= (tonumber(settings["season_deviance_older"]) and{ 1- tonumber(settings["season_deviance_older"]) }or{ nil })[1]
    if season_deviance_older and math.floor(season_deviance_older) <=1 then
        if math.floor(season_deviance_older) >0 then
            clgDvO= Calendar_group.deviance_oldest
        else clgDvO= season_deviance_older
        end
    else clgDvO= Calendar_group.deviance_older
    end
    for i= clgDvO,-1,1 do
        table.insert(clgDvTmp,i)
    end
    if settings["season_order_nextweek"] == "-1" then
        table.insert(clgDvTmp,1)
        table.insert(clgDvTmp,0)
    elseif settings["season_order_nextweek"] == "1" then
        table.insert(clgDvTmp,0)
        table.insert(clgDvTmp,1)
    elseif true or settings["season_order_nextweek"] == "0" then
        table.insert(clgDvTmp,0)
    end
    for _, dev in ipairs(clgDvTmp) do
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
            -- if settings["season_naming_date"] == "Ymu" then
            -- elseif settings["season_naming_date"] == "Y-m-u" then
            -- elseif settings["season_naming_date"] == "YU" then
            -- elseif settings["season_naming_date"] == "Y-U" then
            -- elseif settings["season_naming_date"] == "Ymd" then
            -- elseif true or settings["season_naming_date"] == "Y-m-d" then
            -- end
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
        kiko.log("[WARN]  season."..(season.title or "_")..":[\"data\"] not found.")
        -- error("[WARN]  season."..season.title..": "..err)
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

    local schedule_info_type_tmp= settings["schedule_info_type_02"]
    if schedule_info_type_tmp~="scripted" and schedule_info_type_tmp~="scripted_variety" and
            schedule_info_type_tmp~="scripted_show" and schedule_info_type_tmp~="tv_show" then
        schedule_info_type_tmp= "scripted_variety"
    end

    local hGetBatchTable={ ["url"]= {}, ["query"]= {}, ["header"]= {}, ["redirect"]= true, }
    local dday0100=sunday0100 -- each day stamp
    local replyCs,contentCs, objCs=nil,nil, {}
    local urlPrefix={"https://api.tvmaze.com/schedule"}
    for wday = -1, 7, 1 do
        dday0100=sunday0100 +86400*wday -- 24*3600=86400
        local queryCs = {
            ["date"]=os.date("%Y-%m-%d",dday0100+3600),
            ["country"]=nil,
        }
        local header = {["Accept"] = "application/json"}

        for _, urlPrefixV in ipairs(urlPrefix) do
            for _, countrySi in ipairs(Schedule_info.country) do
                queryCs.country = countrySi
                table.insert(hGetBatchTable.url, urlPrefixV or"")
                table.insert(hGetBatchTable.query, table.deepCopy(queryCs) or{})
                table.insert(hGetBatchTable.header, table.deepCopy(header) or{})
            end
        end
        queryCs.country= ""
        table.insert(hGetBatchTable.url, "https://api.tvmaze.com/schedule/web")
        table.insert(hGetBatchTable.query, table.deepCopy(queryCs) or{})
        table.insert(hGetBatchTable.header, table.deepCopy(header) or{})
    end
    err,replyCs= kiko.httpgetbatch(hGetBatchTable.url,hGetBatchTable.query,hGetBatchTable.header)
    if err ~= nil then
        kiko.log("[ERROR] TVmaze.schedule.reply-week.of." ..(season.title or"").. ".httpgetbatch: " .. err)
        kiko.message("[错误] 对" ..(season.title or"").. "所在周获取时间表失败。\n" .. err,1|8)
        -- kiko.log("[INFO]  hg: "..table.toStringBlock(hGetBatchTable).."\n\nrc"..table.toStringBlock(replyCs))
        return weeksInfo
    end
    for replyCsI, replyCsV in ipairs(replyCs) do
        contentCs = replyCsV["content"]
        if (replyCsV or{}).hasError then
            kiko.log("[ERROR] TVmaze.schedule.reply-week.of." ..(season.title or"").. ".httpgetbatch: " .. err..
                    (((replyCsV or{}).hasError) and{" <"..math.floor((replyCsV or{}).statusCode).."> "..(replyCsV or{}).errInfo} or{""})[1])
            kiko.message("[错误] 对" ..(season.title or"").. "所在周获取时间表失败。\n" .. err,1|8)
            -- kiko.log("[INFO]  hg: "..table.toStringBlock(hGetBatchTable).."\n\nrc"..table.toStringBlock(replyCs))
            return weeksInfo
        end
        
        local objCsi= {}
        err, objCsi = kiko.json2table(contentCs)
        if err ~= nil then
            kiko.log("[ERROR] TVmaze.schedule.reply-on."..(hGetBatchTable.query[replyCsI].date or"")..".of."
                    ..(season.title or"")..".in."..(hGetBatchTable.query[replyCsI].country or"").. ".json2table: " ..err)
            -- error(err)
        elseif table.isEmpty(objCsi) then
            kiko.log("[INFO]  TVmaze.schedule.reply-on."..(hGetBatchTable.query[replyCsI].date or"")..".of."
                    ..(season.title or"")..".in."..(hGetBatchTable.query[replyCsI].country or"").. ": Empty table.")
            -- error(err)
        elseif true then
            Array.extend(objCs,objCsi)
        end
    end

    for _,ep in ipairs(objCs) do
        if table.isEmpty(ep.show) then
            if table.isEmpty((ep._embedded or{}).show) then
                goto continue_gbl_wii
            else
                ep.show= (ep._embedded or{}).show
                if table.isEmpty(ep.show) then
                    goto continue_gbl_wii
                end
            end
        end
        local isInSiCountry= false
        local channelNW= {"network","webChannel"}
        for _,channelNWV in ipairs(channelNW) do
            local tmpCcode= (((ep.show or{})[channelNWV] or{}).country or {}).code
            if not string.isEmpty(tmpCcode) then
                for _, vSic in ipairs(Schedule_info.country) do
                    if tmpCcode==vSic then
                        isInSiCountry= true
                        break
                    end
                end
                if not isInSiCountry then
                    goto continue_gbl_wii
                end
            end
        end
        if string.isEmpty((ep.show or{}).name) then goto continue_gbl_wii
        end
        local dtStamp= (Datetime.strToStamp(ep.airstamp))
        if dtStamp<sunday0100 or dtStamp>=(sunday0100 +604800) then-- 7*24*3600=604800
            goto continue_gbl_wii
        end
        --scripted,scripted_variety,scripted_show,tv_show
        if (ep.show or{}).type~="Scripted" and (ep.show or{}).type~="Animation" and (ep.show or{}).type~="Documentary" then
            if schedule_info_type_tmp=="scripted" then
                goto continue_gbl_wii
            elseif (ep.show or{}).type~="Variety" and (ep.show or{}).type~="Award Show" then
                if schedule_info_type_tmp=="scripted" or schedule_info_type_tmp=="scripted_variety" then
                    goto continue_gbl_wii
                elseif (ep.show or{}).type~="Reality" and (ep.show or{}).type~="Game Show" and (ep.show or{}).type~="Talk Show" and (ep.show or{}).type~="Panel Show" then
                    if schedule_info_type_tmp=="scripted" or schedule_info_type_tmp=="scripted_variety" or schedule_info_type_tmp=="scripted_show" then
                        goto continue_gbl_wii
                    end
                end
            end
        end

        local wSites={}
        local tmpSnameSE= nil
        if true then
            tmpSnameSE= string.format("%s",((tonumber(ep.season or"")==nil)and{""} or{ string.format("S%02s", math.floor(tonumber(ep.season))) })[1]..
                            ((tonumber(ep.number or"")==nil) and{""} or{ string.format("E%02s", math.floor(tonumber(ep.number))) })[1]..
                            ((ep.type=="insignificant_special")and{"SP-"}or{""})[1].. ((ep.type=="significant_special")and{"SP+"}or{""})[1].."")
            table.insert(wSites,{
                    ["name"]= (string.isEmpty(tmpSnameSE) and{"-"}or{tmpSnameSE})[1],
                    ["url"]= ep.url,
                })
        end
        if not string.isEmpty(((ep.show or{}).network or{}).name) then
            table.insert(wSites,{ ["name"]=string.format("%s",((ep.show or{}).network or{}).name.." "..Translation["zh-CN"].show_type[(ep.show or{}).type or""]), ["url"]=(ep.show or{}).officialSite})
        end
        if not string.isEmpty(((ep.show or{}).webChannel or{}).name) then
            table.insert(wSites,{ ["name"]=string.format("%s",((ep.show or{}).webChannel or{}).name.." "..Translation["zh-CN"].show_type[(ep.show or{}).type or""]), ["url"]=(ep.show or{}).officialSite})
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
        local tmpWeekInfoDate
        if settings["schedule_date_release_type"] == "episode" then
            tmpWeekInfoDate= os.date("%Y-%m-%d",dtStamp)
        elseif settings["schedule_date_release_type"] == "show" then
            tmpWeekInfoDate= (ep.show or{}).premiered
        elseif true or settings["schedule_date_release_type"] == "show_x_ep" then
            if season.title==Date_time_info.custom_week_title then
                tmpWeekInfoDate= os.date("%Y-%m-%d",dtStamp)
            else
                tmpWeekInfoDate= (ep.show or{}).premiered
            end
        end
        
        table.insert(weeksInfo,{
            ["title"]=((ep.show or{}).name or""),-- ..
                    -- ((tonumber(ep.number)==nil) and{ "" } or{ string.format("E%02s", math.floor(tonumber(ep.number))) })[1],
            ["weekday"]= ((tonumber( os.date("%w",dtStamp) )==nil)and{ nil }or{ math.floor(tonumber( os.date("%w",dtStamp) ))})[1], --放送星期，取值0(星期日)~6(星期六)
            -- ["weekday"]=Date_time_info.weekEnNum[(((ep.show or{}).schedule or{}).days or{})[1]],
            ["time"]=os.date("%H:%M",dtStamp), --放送时间
            ["date"]= tmpWeekInfoDate, --放送日期
            ["isnew"]= ((tonumber(ep.season)==nil) and{ false }or{ math.floor(tonumber(ep.season))==1 })[1]
                        or ((tonumber(ep.number)==nil) and{ false }or{ math.floor(tonumber(ep.number))==1 })[1], --是否新番
            -- ["bgmid"]=nil, --tvmaze id
            ["bgmid"]=((ep.show or{}).externals or{}).thetvdb, --tvdb id
            ["sites"]= wSites, --放送站点列表

            ["stamp"]=dtStamp,
            -- ["season_number"]= ((tonumber(ep.season or"")==nil)and{nil} or{ math.floor(tonumber(ep.season)) })[1],
            -- ["episode_number"]= ((tonumber(ep.number or"")==nil) and{nil} or{ math.floor(tonumber(ep.number)) })[1],
            ["season_ep_format"]= tmpSnameSE or""
        })
        ::continue_gbl_wii::
    end

    local weeksInfoUnique= {}
    Array.extendUniqueFields(weeksInfoUnique,weeksInfo,{"title","season_ep_format","stamp"},true,false)
    weeksInfo= weeksInfoUnique
    weeksInfoUnique= nil

    kiko.log("[INFO]  Finished getting " .. #weeksInfo .. " info of < " .. season.title .. ">")
    -- table.stable_sort(weeksInfo, function(a,b) return (a.episode_number or 0)<(b.episode_number or 0) end)
    -- table.stable_sort(weeksInfo, function(a,b) return (a.season_number or 0)<(b.season_number or 0) end)
    table.stable_sort(weeksInfo, function(a,b) return a.title.."  "..a.season_ep_format < b.title.."  "..b.season_ep_format end)
    if settings["schedule_sort"]=="time" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        table.stable_sort(weeksInfo, function(a,b) return a.stamp<b.stamp end)
    elseif settings["schedule_sort"]=="title" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.stamp<b.stamp end)
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        type(0)
    elseif true or settings["schedule_sort"]=="timeslot" then
        -- table.stable_sort(weeksInfo, function(a,b) return a.title.." "..a.season_ep_format < b.title.." "..b.season_ep_format end)
        -- if settings["schedule_date_release_type"] == "episode" or (settings["schedule_date_release_type"] == "show_x_ep"
        --         and season.title==Date_time_info.custom_week_title) then
        --     table.stable_sort(weeksInfo, function(a,b) return a.date<b.date end)
        -- end
        table.stable_sort(weeksInfo, function(a,b) return a.time<b.time end)
    end
    return weeksInfo
end

-- 对修改设置项`settings`响应。KikoPlay当 设置中修改了脚本设置项 时，会尝试调用`setoption`函数通知脚本。
-- key为设置项的key，val为修改后的value
function setoption(key, val)
    if key=="season_deviance_older" then
        kiko.dialog({
            ["title"]="更改了 `分组列表 - 近几周`",
            ["tip"]="\t请重启 KikoPlay 以应用设置。",
            ["text"]=nil,
        })
    end
    if key=="season_order_nextweek" then
        kiko.dialog({
            ["title"]="更改了 `分组列表 - 显示下一周`",
            ["tip"]="\t请重启 KikoPlay 以应用设置。",
            ["text"]=nil,
        })
    end
end

function scriptmenuclick(menuid)
    if menuid == "detect_valid_connect" then
        
        local diaTitle, diaTip, diaText = "检测 - 是否有效连接","",""
        local query = {}
        local header = { ["Content-Type"]= "application/json", }
        local hg_theme= "shows/16149" -- Flebag (2016)
        local err,reply
        err, reply = kiko.httpget("https://api.tvmaze.com/".. hg_theme, query, header)
        if err ~= nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] TVmaze.connect.reply-test.httpget: ".. (err or "").."<"..
                    string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            diaTip = diaTip.. "[错误]\t"..(err or "").."<"..
                    string.format("%03d",(reply or{}).statusCode or 0).."> "..((reply or{}).errInfo or"").."！\n"
            diaText = diaText.. ""
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
        else
            diaTip = diaTip.. "\t成功连接 TVmaze ！\n"
        end

        kiko.dialog({
            ["title"]= diaTitle,
            ["tip"]= diaTip,
            ["text"]=  (string.isEmpty(diaText) and{nil} or{diaText})[1],
        })
    elseif menuid == "link_repo_usage" then
        kiko.execute(true, "cmd", {"/c", "start", "https://github.com/kafovin/KikoPlayScript#%E8%84%9A%E6%9C%AC-tvmaze-%E7%9A%84%E7%94%A8%E6%"})
    elseif menuid == "display_dialog_about" then
        local img_back_data= nil
        -- local header = {["Accept"] = "image/jpeg" }
        -- local err, reply = kiko.httpget("https://github.com/kafovin/KikoPlayScript/blob/library-tmdb-beta/manual.assets/image-TVmazeList-1.1.1.png", {} , header)
        -- if err ~= nil or (reply or{}).hasError then
        --     img_back_data=nil
        -- else
        --     img_back_data=reply["content"]
        -- end
        kiko.dialog({
            ["title"]= "关于",
            ["tip"]= "\t\t\t\tEdited by: kafovin\n\n"..
                    "脚本 TVmazeList (/bgm_calendar/tvmazelist.lua) 是针对剧集的日历时间表脚本（仅英国、美国等），\n"..
                    "主要借助从 TVmaze 的公共API刮削剧集的日历时间表(剧集标题为英文)。\n"..
                    "* 测试中，不稳定，未来可能会有较大改动。\n"..
                    "\n欢迎到 此脚本的GitHub页面 或 KikoPlay的QQ群 反馈！\n",
            ["text"]= "+ 此脚本的GitHub页面 - https://github.com/kafovin/KikoPlayScript\n"..
                    "\t 用法、常见问题…\n"..
                    "\n本脚本基于：\n"..
                    "+ TVmaze 首页 - https://www.tvmaze.com/\n"..
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
