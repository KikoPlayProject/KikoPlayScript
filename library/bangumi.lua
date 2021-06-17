info = {
    ["name"] = "Bangumi",
    ["id"] = "Kikyou.l.Bangumi",
	["desc"] = "Bangumi脚本，从bgm.tv中获取动画信息",
	["version"] = "0.1"
}

settings = {
    ["result_type"]={
        ["title"]="搜索结果类型",
        ["default"]="2",
        ["desc"]="搜索条目类型， 2： 动画  3：三次元",
        ["choices"]="2,3"
    },
    ["cover_quality"]={
        ["title"]="封面图质量",
        ["default"]="common",
        ["desc"]="图片质量从高到低：medium(中), common(正常), large(高)",
        ["choices"]="medium,common,large"
    },
    ["tag_staff"]={
        ["title"]="添加Staff标签",
        ["default"]="y",
        ["desc"]="搜索标签时是否显示Staff层次标签",
        ["choices"]="y,n"
    },
    ["tag_actor"]={
        ["title"]="添加演员标签",
        ["default"]="y",
        ["desc"]="搜索标签时是否显示演员层次标签",
        ["choices"]="y,n"
    }
}

menus = {
    {["title"]="打开Bangumi页面", ["id"]="open_bgm"}
}

function menuclick(menuid, anime)
    local NM_HIDE=1
    local NM_PROCESS=2
    local NM_SHOWCANCEL = 4
    local NM_ERROR = 8
    local NM_DARKNESS_BACK = 16
    kiko.log("Menu Click: ", menuid)
    if menuid == "open_bgm" then
        kiko.message("Menu Action: Open BGM", NM_HIDE)
        kiko.execute(true,  "cmd", {"/c", "start", anime["url"]})
    end
end

function setoption(key, val)
    kiko.log(string.format("Setting changed: %s = %s", key, val))
end

function search(keyword)
    local query = {
        ["type"]=settings["result_type"],
        ["responseGroup"]="small",
        ["start"]="0",
        ["max_results"]="10"
    }
    local header = {
        ["Accept"]="application/json"
    }
    local err, reply = kiko.httpget(string.format("https://api.bgm.tv/search/subject/%s", keyword), query, header)
    if err ~= nil then  error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local animes = {}
    for _, anime in pairs(obj['list']) do
        local animeName = unescape(anime["name_cn"] or anime["name"])
        if #animeName==0 then
            animeName = unescape(anime["name"])
        end
        local data = string.format("%d", anime["id"])
        local epList = {}
        table.insert(animes, {
            ["name"]=animeName,
            ["data"]=data,
            ["extra"]=data
        })
    end
    return animes
end

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

function getep(anime)
    local bgmId = anime["data"]
    local header = {
        ["Accept"]="application/json"
    }
    local err, reply = kiko.httpget(string.format("https://api.bgm.tv/subject/%s/ep", bgmId), {}, header)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local eps = {}
    for _, ep in pairs(obj['eps']) do
        local epType = ep["type"] + 1  -- ep["type"]: 0~6
        local epIndex = ep["sort"]
        local epName = unescape(ep["name_cn"] or ep["name"])
        table.insert(eps, {
            ["name"]=epName,
            ["index"]=epIndex,
            ["type"]=epType
        })
    end
    return eps
end

function getStaff(staffArray)
    if staffArray == nil then
        return ""
    end
    local staffTable = {}
    for _, staff in pairs(staffArray) do
        local jobs = staff["jobs"]
        local _, sname =kiko.sttrans(staff["name"], true)
        if jobs ~= nil then
            for __, job in pairs(jobs) do
                if staffTable[job] == nil then
                    staffTable[job] = {}
                end
                table.insert(staffTable[job], sname)
            end
        end
    end
    jobstrs = {}
    for job, staffs in pairs(staffTable) do
        local cj = job..":"..table.concat(staffs, " ")
        table.insert(jobstrs, cj)
    end
    return table.concat(jobstrs, ";")
end

function getCrt(crtArray) 
    local crts = {}
    if crtArray == nil then
        return crts
    end
    for _, crt in pairs(crtArray) do
        if crt["actors"] ~= nil then
            local _, actor = kiko.sttrans(crt["actors"][1]["name"], true)
            local img = crt["images"]
            local imgurl = ""
            if img ~= nil then imgurl = img["grid"] end
            local crt_name = unescape(crt["name_cn"] or crt["name"])
            if #crt_name==0 then crt_name = unescape(crt["name"]) end
            table.insert(crts, {
                ["name"]=crt_name,
                ["actor"]=actor,
                ["link"]=string.format("http://bgm.tv/character/%d", crt["id"]),
                ["imgurl"]=imgurl
            })
        end
    end
    return crts
end

function detail(anime)
    local bgmId = anime["data"]
    query = {
        ["responseGroup"]="medium",
    }
    local header = {
        ["Accept"]="application/json"
    }
    local err, reply = kiko.httpget(string.format("https://api.bgm.tv/subject/%s", bgmId), query, header)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local animeName = unescape(obj["name_cn"] or obj["name"])
    if #animeName==0 then animeName = unescape(anime["name"]) end
    
    local anime = {
        ["name"]=animeName,
        ["data"]=bgmId,
        ["url"]=string.format("http://bgm.tv/subject/%s", bgmId),
        ["desc"]=obj["summary"],
        ["airdate"]=obj["air_date"],
        ["epcount"]=obj["eps_count"],
        ["coverurl"]=obj["images"][settings["cover_quality"]],
        ["staff"]=getStaff(obj["staff"]),
        ["crt"]=getCrt(obj["crt"])
    }
    return anime
end

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function removeWhen(src, cond, removes)
    if src[cond] then
        for _, v in ipairs(removes) do
            src[v] = nil
        end
    end
end

function string.split(str, sep)
    local pStart = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local pEnd = string.find(str, sep, pStart)
        if pEnd == pStart then
            pStart = pEnd + string.len(sep)
        else
            if not pEnd then
                nSplitArray[nSplitIndex] = string.sub(str, pStart, string.len(str))
                break
            end
            nSplitArray[nSplitIndex] = string.sub(str, pStart, pEnd - 1)
            pStart = pEnd + string.len(sep)
            nSplitIndex = nSplitIndex + 1
        end
    end
    return nSplitArray
end

function getNames(anime)
    local anames = {}
    for _, c in pairs(anime["crt"]) do
        table.insert(anames, c["name"])
        table.insert(anames, c["actor"])
    end
    for _, v in pairs(anime["staff"]) do
        for _, n in ipairs(string.split(v, " ")) do
            table.insert(anames, n)
        end
    end
    return anames
end

function addLevelTags(tags, anime)
    local studios = {
        ["BONES"] = "BONES", 
        ["京都动画"] ="京都动画", ["京都アニメーション"]="京都动画", 
        ["Madhouse"]="Madhouse", 
        ["A-1 Pictures"]="A-1 Pictures", ["A-1Pictures"]="A-1 Pictures", ["A-1_Pictures"]="A-1 Pictures",
        ["J.C.STAFF"]="J.C.STAFF", 
        ["Feel."]="Feel.", 
        ["Production I.G"]="Production I.G", 
        ["ufotable"]="ufotable",
        ["动画工房"]="动画工房", 
        ["P.A.WORKS"]="P.A.WORKS", 
        ["Studio Pierrot"]="Studio Pierrot", 
        ["Studio DEEN"]="Studio DEEN", 
        ["TOEI"]="TOEI", 
        ["SUNRISE"]="SUNRISE", 
        ["TRIGGER"]="TRIGGER", 
        ["GAINAX"]="GAINAX",
        ["SHAFT"]="SHAFT", 
        ["ZEXCS"]="ZEXCS", 
        ["David Production"]="David Production", ["davidproduction"]="David Production", ["david_production"]="David Production",
        ["TROYCA"]="TROYCA", 
        ["AIC"]="AIC", 
        ["MAPPA"]="MAPPA", 
        ["C2C"]="C2C", 
        ["SILVERLINK."]="SILVERLINK.", ["SILVER_LINK."]="SILVERLINK.", ["SILVERLINK"]="SILVERLINK.",
        ["TMSEntertainment"]="TMS Entertainment", ["TMS"]="TMS Entertainment",["TMS_Entertainment"]="TMS Entertainment", 
        ["NOMAD"] = "NOMAD", 
        ["ZERO-G"]="ZERO-G", 
        ["PINE JAM"]="PINE JAM", ["PINE_JAM"]="PINE JAM", ["PINEJAM"]="PINE JAM",
        ["8-Bit"]="8-Bit", ["8bit"]="8-Bit", 
        ["Nexus"]="Nexus", 
        ["Studio五组"]="Studio五组", 
        ["project No.9"]="project No.9",["projectNo.9"]="project No.9", ["project_No.9"]="project No.9",
        ["手冢Production"]="手冢Production", ["手塚PRODUCTION"]="手冢Production", ["手塚プロダクション"]="手冢Production",
        ["CONNECT"]="CONNECT",
        ["LIDENFILMS"]="LIDENFILMS",
        ["Diomedéa"]="Diomedéa",["diomedéa"]="Diomedéa", ["diomedea"]="Diomedéa",
        ["GEEK TOYS"]="GeekToys", ["GeekToys"]="GeekToys",
        ["Lerche"]="Lerche",
        ["Passione"]="Passione", ["パッショーネ"]="Passione",
        ["Millepensee"]="Millepensee", ["millepensee"]="Millepensee", ["ミルパンセ"]="Millepensee",
        ["WHITE FOX"]="WHITE FOX", ["WHITEFOX"]="WHITE FOX",
        ["ENGI Inc."]="ENGI Inc.", ["Engi"]="ENGI Inc.",
        ["Hoods Entertainment"]="Hoods Entertainment", ["HoodsEntertainment"]="Hoods Entertainment",
        ["MAHO FILM"]="MAHO FILM", ["MAHOFILM"]="MAHO FILM",
        ["Lesprit"]="Lesprit",
        ["SANZIGEN Inc."]="SANZIGEN Inc.", ["SANZIGEN"]="SANZIGEN Inc.",
        ["Tear Studio"]="Tear Studio", ["Tear_Studio"]="Tear Studio",
        ["C-Station"]="C-Station",
        ["Seven Arcs"]="Seven Arcs", ["SEVEN_ARCS"]="Seven Arcs", ["SEVEN·ARCS"]="Seven Arcs", ["SEVEN・ARCS"]="Seven Arcs", ["SevenArcs"]="Seven Arcs",
    }
    for i, tag in ipairs(tags) do
        if studios[tag] then
            tags[i] = "制作/"..studios[tag] 
        end
    end
    local types = Set({
        "轻改", "漫改", "游戏改", "原创"
    })
    for i, tag in ipairs(tags) do
        if types[tag] then
            tags[i] = "改编类型/"..tags[i]
        end
    end
    if settings["tag_staff"]=='y' then
        for k, v in pairs(anime["staff"]) do
            if k=="导演" or k=="原作" then
                for _, n in ipairs(string.split(v, " ")) do
                    table.insert(tags, k .. "/" .. n)
                end
            end
        end
    end
    if settings["tag_actor"]=='y' then
        local i = 0;
        for _, c in pairs(anime["crt"]) do
            table.insert(tags, "出演/" .. c["actor"])
            i = i+1
            if i>5 then break end
        end
    end
    return tags
end

function tagFilter(tags, anime)
    local trivialTags = Set({
        "TV", "OVA", "OAD", "WEB", "日本", "季番", "动画", "日本动画", "未确定", "追番",
        "佳作", "未上映", "未定档", "剧情", "TVA"
    })
    local nameTags = Set(getNames(anime))
    local containRemoveTags = {"OVA"}
    local fTags = {}
    local animeName = anime["name"]
    for _, tag in ipairs(tags) do
        repeat
            local _, tag = kiko.sttrans(tag, true)
            if trivialTags[tag] then break end
            if nameTags[tag] then break end
            if string.find(tag, "20%d%d") or string.find(tag, "19%d%d") then break end
            if string.find(tag, "%d%d月") or string.find(tag, "%d月") then break end
            if string.find(tag, animeName) then break end
            if string.find(animeName, tag) then break end
            local contains = false
            for __, ct in ipairs(containRemoveTags) do
                if string.find(tag, ct) then 
                    contains = true
                    break
                end
            end
            if contains then break end
            table.insert(fTags, tag)
        until true
    end
    local tagSet = Set(fTags)
    removeWhen(tagSet, "轻改", {"轻小说改", "小说改", "小说改编"})
    removeWhen(tagSet, "漫改", {"漫画改", "漫画改编"})
    removeWhen(tagSet, "游戏改", {"手游", "手游改", "游戏改编", "GAL改"})
    removeWhen(tagSet, "治愈", {"治愈系"})
    removeWhen(tagSet, "泡面番", {"泡面"})
    removeWhen(tagSet, "萌系", {"萌", "萌豚"})
    removeWhen(tagSet, "卖肉", {"肉", "肉番"})
    removeWhen(tagSet, "肉番", {"肉"})
    removeWhen(tagSet, "续作", {"续篇"})
    removeWhen(tagSet, "狗粮", {"酸"})
    local retTags = {}

    local i, maxCount = 0, 20
    for t, _ in pairs(tagSet) do
        table.insert(retTags, unescape(t))
        i = i+1
        if i>= maxCount then break end
    end
    local retTags = addLevelTags(retTags, anime)
    return retTags
end

function gettags(anime)
    local bgmId = anime["data"]
    local err, reply = kiko.httpget(string.format("http://bgm.tv/subject/%s", bgmId))
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, tagContent = string.find(content, "<div class=\"subject_tag_section\">(.*)<div id=\"panelInterestWrapper\">")
    local tags = {}
    if tagContent ~= nil then
        local parser = kiko.htmlparser(tagContent)
        while not parser:atend() do
            if parser:curnode()=="a" and parser:start() then
                parser:readnext()
                table.insert(tags, parser:readcontent())
            end
            parser:readnext()
        end
    end
    return tagFilter(tags, anime)
end