info = {
    ["name"] = "bgmlist",
    ["id"] = "Kikyou.b.Bgmlist",
	["desc"] = "bgmlist 番组日历",
	["version"] = "0.1",
}

settings = {
    ["load_last_season"]={
        ["title"]="加载上一季未完结动画",
        ["default"]="y",
        ["desc"]="在当季番组中添加上一季未完结动画",
        ["choices"]="y,n"
    }
}

site_json = [[{"acfun":{"title":"AcFun","urlTemplate":"https://www.acfun.cn/bangumi/aa{{id}}","regions":["CN"],"type":"onair"},"bilibili":{"title":"哔哩哔哩","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["CN"],"type":"onair"},"bilibili_hk_mo_tw":{"title":"哔哩哔哩（港澳台）","urlTemplate":"https://www.bilibili.com/bangumi/media/md{{id}}/","regions":["HK","MO","TW"],"type":"onair"},"sohu":{"title":"搜狐视频","urlTemplate":"https://tv.sohu.com/{{id}}","regions":["CN"],"type":"onair"},"youku":{"title":"优酷","urlTemplate":"https://list.youku.com/show/id_z{{id}}.html","regions":["CN"],"type":"onair"},"qq":{"title":"腾讯视频","urlTemplate":"https://v.qq.com/detail/{{id}}.html","regions":["CN"],"type":"onair"},"iqiyi":{"title":"爱奇艺","urlTemplate":"https://www.iqiyi.com/{{id}}.html","regions":["CN"],"type":"onair"},"letv":{"title":"乐视","urlTemplate":"https://www.le.com/comic/{{id}}.html","regions":["CN"],"type":"onair"},"pptv":{"title":"PPTV","urlTemplate":"http://v.pptv.com/page/{{id}}.html","regions":["CN"],"type":"onair"},"mgtv":{"title":"芒果tv","urlTemplate":"https://www.mgtv.com/h/{{id}}.html","regions":["CN"],"type":"onair"},"nicovideo":{"title":"Niconico","urlTemplate":"https://ch.nicovideo.jp/{{id}}","regions":["JP"],"type":"onair"},"netflix":{"title":"Netflix","urlTemplate":"https://www.netflix.com/title/{{id}}","type":"onair"},"gamer":{"title":"動畫瘋","urlTemplate":"https://acg.gamer.com.tw/acgDetail.php?s={{id}}","regions":["TW"],"type":"onair"},"muse_hk":{"title":"木棉花 HK","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","MO"],"type":"onair"},"ani_one_asia":{"title":"Ani-One Asia","urlTemplate":"https://www.youtube.com/playlist?list={{id}}","regions":["HK","TW","MO","SG","MY","PH","TH","ID","VN","KH","BD","BN","BT","FJ","FM","IN","KH","LA","LK","MH","MM","MN","MV","NP","NR","PG","PK","PW","SB","TL","TO","TV","VU","WS"],"type":"onair"},"viu":{"title":"Viu","urlTemplate":"https://www.viu.com/ott/hk/zh-hk/vod/{{id}}/","regions":["HK","SG","MY","IN","PH","TH","MM","BH","EG","JO","KW","OM","QA","SA","AE","ZA"],"type":"onair"}}]]
_, site_map = kiko.json2table(site_json)

function getseason()
    local err, reply = kiko.httpget("https://bgmlist.com/api/v1/bangumi/season")
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local seasons = {}
    month_tb = {
        ["q1"]="01",
        ["q2"]="04",
        ["q3"]="07",
        ["q4"]="10"
    }
    for _, season in pairs(obj["items"]) do
        local year = string.sub(season, 1, 4)
        local month = month_tb[string.sub(season, 5, 6)]
        table.insert(seasons, {
            ["title"]=string.format("%s-%s", year, month)
        })
    end
    return seasons
end

function timestamp(dateStringArg)
	local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone =      
        string.match(dateStringArg, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')
	local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')
    if tonumber(inYear) < 1970 then
        return 0
    end
	local returnTime = os.time({year=inYear, month=inMonth, day=inDay, hour=inHour, min=inMinute, sec=inSecond, isdst=false})
	if zHours then
		returnTime = returnTime - ((tonumber(zHours)*3600) + (tonumber(zMinutes)*60))
	end
	return returnTime
end

function isnew(syear, smonth, ts)
    if tonumber(syear) < 1970 then
        return true
    end
    local start = os.time({year=tonumber(syear), month=tonumber(smonth), day=1, hour=0, isdst=false})
    return ts >= start
end

function getbgmlist(season)
    local season_title = season["title"]
    local year = string.sub(season_title, 1, 4)
    local month = string.sub(season_title, 6, 7)
    local q_tb = {
        ["01"]="q1",
        ["04"]="q2",
        ["07"]="q3",
        ["10"]="q4"
    }
    local url = string.format("https://bgmlist.com/api/v1/bangumi/archive/%s%s", year, q_tb[month])
    local err, reply = kiko.httpget(url)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local bgmlist = {}
    for _, bgm in pairs(obj["items"]) do
        local title = bgm["title"]
        if bgm["titleTranslate"] ~= nil then
            local tt = bgm["titleTranslate"]
            if tt["zh-Hans"] ~= nil then
                title = tt["zh-Hans"][1]
            end
        end
        local airTimestamp = timestamp(bgm["begin"]) + 8*3600 
        local airTime = os.date("*t", airTimestamp)
        local weekDay = airTime["wday"]
        weekDay = weekDay - 1  -- 0~6
        local bgmid = ""
        local sites = {}
        if bgm["sites"] ~= nil then
            for _, site in pairs(bgm["sites"]) do
                local site_name = site["site"]
                if site_name == nil then
                    goto continue
                end
                if site_name=="bangumi" then
                    bgmid=site["id"]
                    goto continue
                else
                    local siteinfo = site_map[site_name]
                    if siteinfo ~= nil then
                        local template = siteinfo["urlTemplate"]
                        if site["id"]~=nil then
                            local url = string.gsub(template, "{{id}}", site["id"])
                            table.insert(sites, {
                                ["name"]=siteinfo["title"],
                                ["url"]=url
                            })
                        end
                    end
                end
                ::continue::
            end
        end
        local endTimestamp = -1
        if bgm["end"]~=nil and #bgm["end"]>0 then
            endTimestamp = timestamp(bgm["end"]) + 8*3600 
        end
        table.insert(bgmlist, {
            ["title"]=title,
            ["weekday"]=weekDay,
            ["time"]=string.format("%02d:%02d", airTime["hour"], airTime["min"]),
            ["date"]=string.format("%d-%02d-%02d", airTime["year"], airTime["month"], airTime["day"]),
            ["isnew"]=isnew(year, month, airTimestamp),
            ["bgmid"]=bgmid,
            ["sites"]=sites,
            ["end"]=endTimestamp
        })
    end
    if settings["load_last_season"]=='y' then
        local last_month_tb = {
            ["01"]="10",
            ["04"]="01",
            ["07"]="04",
            ["10"]="07"
        }
        local last_year = tonumber(year)
        if month=="01" then
            last_year = last_year-1
        end
        local last_season = {
            ["title"]=string.format("%d-%s", last_year, last_month_tb[month])
        }
        kiko.log("load_last_season", last_season["title"])
        settings["load_last_season"]='n'
        local states, last_bgms = pcall(getbgmlist, last_season)
        if states then
            for _, l_bgm in pairs(last_bgms) do
                if l_bgm["end"]==-1 or isnew(year, month, l_bgm["end"]) then
                    l_bgm["isnew"]=false
                    table.insert(bgmlist, l_bgm)
                end
            end
        else
            kiko.log(string.format("get last season %s failed: ", last_season["title"]), last_bgms)
        end
        settings["load_last_season"]='y'
    end
    return bgmlist
end