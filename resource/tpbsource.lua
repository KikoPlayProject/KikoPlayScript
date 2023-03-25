-- TPB source
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TPBsrc",
    ["id"] = "Kikyou.r.TPBsource",
    ["desc"] = "TPBsource 资源信息脚本（测试中，不稳定）  Edited by: anonymous\n"..-- Edited by: anonymous
                "从 thePirateBay 刮削媒体资源信息。",
    ["version"] = "0.0.05", -- 0.0.05.230325_build
    ["min_kiko"] = "0.9.1",
}

-- 设置项
settings = {
    ["aname_website_alias"] = {
        ["title"] = "网址 - TPB域名",
        ["default"] = "tpb.party",
        ["desc"] = "[必填项] 填写 `thePirateBay` 的域名，通常请不要带`https://`、`/`等字符，\n"..
                    "适用于其搜索页网址形如 [https://域名/search/搜索关键词/页码/排序/类别] 的。\n"..
                    "`tpb.party`：网址 [https://tpb.party/search/搜索关键词/1/3/0] 为其搜索页 (默认)。",
        ["group"]="网址",
    },
    -- ["aname_website_alias2"] = {
    --     ["title"] = "网址 - TPB域名格式2",
    --     ["default"] = "thepiratebaya.org",
    --     ["desc"] = "[选填项] (此设置不可用) 填写 `thePirateBay` 的域名，通常请不要带`https://`、`/`等字符，\n"..
    --                 "适用于其搜索页网址形如 [https://域名/search?q=搜索关键词] 的。\n"..
    --                 "注意：只有`网址 - TPB域名`不填写时才会采用此设置项。\n"..
    --                 "`thepiratebaya.org`：网址 [https://thepiratebaya.org/search?q=搜索关键词] 为其搜索页 (默认)。",
    --     ["group"]="网址",
    -- },
    ["list_filter_category"] = {
        ["title"] = "限定 - 资源所属类别",
        ["default"] = "0",
        ["desc"] = "限定资源列表搜索 只属于此类别的资源。   `0`：所有(all/x/) (默认)。\n"..
                    "`100` 音频(audio)：`101` 音乐、`102` 有声书、`103` 声音片段、`104` 无损音频、`199` 其他音频。\n"..
                    "`200` 视频([v]ideo)：`201` 电影、`202` 电影(DVD压制)、`203` MV/音乐视频(mv)、`204` 电影片段、`205` 剧集、`206` 手持设备、`207` 电影(高清)、`208` 剧集(高清)、`209` 3D视频(3d)、`299` 其他视频。\n"..
                    "`300` 应用([app]lication)：`301` Windows、`302` Mac、`303` UNIX、`304` 手持设备、`305` IOS (iPad/iPhone)、`306` Android、`399` 其他系统下的应用。\n"..
                    "`400` 游戏([g]ame)：`401` PC、`402` Mac、`403` PSx、`404` XBOX360、`405` Wii、`406` 手持设备、`407` IOS (iPad/iPhone)、`408` Android、`499` 其他游戏。\n".. -- `500` 淫秽：`501` 电影、`502` 电影(DVD压制)、`503` 图像、`504` 游戏、`505` 电影(高清)、`506` 电影片段、`599` 其他。\n"
                    "`600` 其他(other(s))：`601` 电子书、`602` 漫画(comic(s))、`603` 图像、`604` 封面、`605` 3D打印模型、`699` 其他。",
        ["choices"]="0,100,101,102,103,104,199,200,201,202,203,204,205,206,207,208,209,299"..
                    ",300,301,302,303,304,305,306,399,400,401,402,403,404,405,406,407,408,499"..
                    ",500,501,502,503,504,505,506,599,600,601,602,603,604,605,699", -- 
        ["group"]="限定",
    },
    ["list_filter_orderby"] = {
        ["title"] = "限定 - 资源排序方式",
        ["default"] = "7",
        ["desc"] = "限定资源列表搜索按此排序资源。 降序:从大到小(desc/-/)；升序:从小到大(asc/+) `7`：做种节点数 由多到少 (默认)。\n"..
                    "`1`/`2`：按 标题(name) 降序ZA/升序。\t`13`/`14`：按 类型(category) 降序/升序。 \n"..
                    "`3`/`4`：按 上传时间([t]ime) 降序新旧/升序。\t`5`/`6`：按 文件大小(si[z]e) 降序/升序。 \n"..
                    "`7`/`8`：按 做种节点数([s]eeder(s)/) 降序/升序。 `9`/`10`：按 吸血节点数(leecher(s)) 降序/升序。 ", -- "`11`/`12`：按 上传者昵称(uploader) 降序/升序。 \n"..
        ["choices"]="1,2,3,4,5,6,7,8,9,10,11,12,13,14",
        ["group"]="限定",
    },
    ["list_filter_qtext"] = {
        ["title"] = "限定 - 关键词限定",
        ["default"] = "filter",
        ["desc"] = "在搜索的关键词后加上形如 `$filter=排序编号/类别编号$` 的文本来限定资源列表搜索，即以字符'$'分隔关键词和限定词\n"..
                    "例如输入 `HEVC Bluray $filter=3/200`，即为 搜索`x265 Bluray`的视频、列表按上传时间由新到旧排列。\n"..
                    "以下为与上例`$filter=3/200`同义的限定词： `$filter=time_desc/video`、`$filter:t-/v`等。\n"..
                    "`plain`：所有输入仅作为普通关键词。 `filter`：识别形如`$filter=0/7$`的限定 (默认)。 ", -- "`11`/`12`：按 上传者昵称 降序/升序。 \n"..
        ["choices"]="plain,filter",
        ["group"]="限定",
    },
}

scriptmenus = {
    {["title"]="检测连接", ["id"]="detect_valid_connect"},
    -- {["title"]="使用方法", ["id"]="link_repo_usage"},
    {["title"]="关于", ["id"]="display_dialog_about"},
}

searchsettings = {
    ["list_filter_i07_qtext"] = {
        ["title"] = "限定：",
        -- ["default"] = "filter",
        ["desc"] = "在搜索的关键词后加上形如 `$filter=排序编号/类别编号$` 的文本来限定资源列表搜索，即以字符'$'分隔关键词和限定词\n"..
                    "例如输入 `HEVC Bluray $filter=3/200`，即为 搜索`x265 Bluray`的视频、列表按上传时间由新到旧排列。\n"..
                    "以下为与上例`$filter=3/200`同义的限定词： `$filter=time_desc/video`、`$filter:t-/v`等。\n"..
                    "识别形如`$filter=0/7$`的限定 (`限定 - 关键词限定`的默认设置)。 ", -- "`11`/`12`：按 上传者昵称 降序/升序。 \n"..
        -- ["choices"]="plain,filter",
        ["save"]=false,
        ["display_type"] = 5,
    },
    ["list_filter_i23_orderby"] = {
        ["title"] = "排序",
        ["default"] = "默认",
        ["desc"] = "限定资源列表搜索按此排序资源。 降序:从大到小(desc/-/)；升序:从小到大(asc/+) `7`：做种节点数 由多到少。\n"..
                    "`1`/`2`：按 标题(name) 降序ZA/升序。\t`13`/`14`：按 类型(category) 降序/升序。 \n"..
                    "`3`/`4`：按 上传时间([t]ime) 降序新旧/升序。\t`5`/`6`：按 文件大小(si[z]e) 降序/升序。 \n"..
                    "`7`/`8`：按 做种节点数([s]eeder(s)/) 降序/升序。 `9`/`10`：按 吸血节点数(leecher(s)) 降序/升序。 ", -- "`11`/`12`：按 上传者昵称(uploader) 降序/升序。 \n"..
        ["choices"]="默认,标题降序,标题升序,时间降序,时间升序,大小降序,大小升序,做种数降序,做种数升序,吸血数降序,吸血数升序,上传者降序,上传者升序,类别降序,类别升序",
        ["save"]=true,
        ["display_type"] = 1,
    },
    ["list_filter_i33_category"] = {
        ["title"] = "类别",
        ["default"] = "默认",
        ["desc"] = "限定资源列表搜索 只属于此类别的资源。   `0`：所有(all/x/)。\n"..
                    "`100` 音频(audio)：`101` 音乐、`102` 有声书、`103` 声音片段、`104` 无损音频、`199` 其他音频。\n"..
                    "`200` 视频([v]ideo)：`201` 电影、`202` 电影(DVD压制)、`203` MV/音乐视频(mv)、`204` 电影片段、`205` 剧集、`206` 手持设备、`207` 电影(高清)、`208` 剧集(高清)、`209` 3D视频(3d)、`299` 其他视频。\n"..
                    "`300` 应用([app]lication)：`301` Windows、`302` Mac、`303` UNIX、`304` 手持设备、`305` IOS (iPad/iPhone)、`306` Android、`399` 其他系统下的应用。\n"..
                    "`400` 游戏([g]ame)：`401` PC、`402` Mac、`403` PSx、`404` XBOX360、`405` Wii、`406` 手持设备、`407` IOS (iPad/iPhone)、`408` Android、`499` 其他游戏。\n".. -- `500` 淫秽：`501` 电影、`502` 电影(DVD压制)、`503` 图像、`504` 游戏、`505` 电影(高清)、`506` 电影片段、`599` 其他。\n"
                    "`600` 其他(other(s))：`601` 电子书、`602` 漫画(comic(s))、`603` 图像、`604` 封面、`605` 3D打印模型、`699` 其他。",
        ["choices"]="默认,所有,音频,视频,应用,游戏,视频MV,视频3D,漫画,电子书,0,100,101,102,103,104,199,200,201,202,203,204,205,206,207,208,209,299"..
                    ",300,301,302,303,304,305,306,399,400,401,402,403,404,405,406,407,408,499"..
                    ",500,501,502,503,504,505,506,599,600,601,602,603,604,605,699", -- 
        ["save"]=true,
        ["display_type"] = 1,
    },
}

Filter_info ={
    ["order"]={ ["name"]="1", ["time"]="3", ["size"]="5", ["uploader"]="11", ["category"]="13",
                ["title"]="1", ["seeders"]="7", ["leechers"]="9", ["seeder"]="7", ["leecher"]="9",
                ["标题"]="1", ["时间"]="3", ["大小"]="5", ["做种节点"]="7", ["吸血节点"]="9", ["上传者"]="11", ["目录"]="13",
                [""]="7", ["t"]="3", ["z"]="5", ["s"]="7",
    },
    ["category"]={ ["all"]="0", ["audio"]="100", ["video"]="200", ["application"]="300", ["game"]="400",
                ["audios"]="100", ["videos"]="200", ["applications"]="300", ["games"]="400", ["others"]="600", ["adults"]="500",
                ["app"]="300", ["apps"]="300", ["other"]="600", ["adult"]="500", ["porn"]="500", ["porns"]="500",
                [""]="0", ["x"]="0", ["v"]="200", ["g"]="400", ["mv"]="203", ["3D"]="209", ["comics"]="602", ["comic"]="602",
                ["所有"]="0", ["音频"]="100", ["视频"]="200", ["应用"]="300", ["游戏"]="400", ["成人"]="500", ["视频MV"]="203", ["视频3D"]="209", ["漫画"]="602", ["电子书"]="601",
    },
    ["ascdesc"]={ ["asc"]="1", ["desc"]="0", [""]="0", ["+"]="1", ["-"]="0", ["升序"]="1", ["降序"]="0",
    },
    ["orderby"]={["标题降序"]="1", ["时间降序"]="3", ["大小降序"]="5", ["做种数降序"]="7", ["吸血数降序"]="9", ["上传者降序"]="11", ["类别降序"]="13",
                ["标题升序"]="2", ["时间升序"]="4", ["大小升序"]="6", ["做种数升序"]="8", ["吸血数升序"]="10", ["上传者升序"]="12", ["类别升序"]="14",
    },
}
Datetime={}

-- (() and{} or{})[1]

---------------------
-- 资源脚本部分
-- copy (as template) from & thanks to "../resource/comicat.lua" in "KikoPlay/resource"|KikoPlayScript
--

function search(keyword,page,scene,options)
    --kiko_HttpGet arg:
    --  url: string
    --  query: table, {["key"]=value} value: string
    --  header: table, {["key"]=value} value: string
    page= math.floor(tonumber(page) or 1)
    if page <1 then page= 1 end

    local orderFp = table.deepCopy(Filter_info.order)
    for ofk,ofv in pairs(Filter_info.order) do
        orderFp[ofk.."-"]= ofv
        orderFp[ofk.."+"]= tostring(math.floor((tonumber(ofv) or 7) +1))
    end

    local keywordPlain,listFilter = nil,nil
    local slf_category,slf_orderby,slf_qtext = nil,nil,nil
    if scene == "auto-download" then
        slf_category = settings["list_filter_category"]
        slf_orderby = settings["list_filter_orderby"]
        slf_qtext =settings["list_filter_qtext"]
    elseif true or scene == "search" then
        slf_category = ((string.isEmpty(options["list_filter_i33_category"]) or options["list_filter_i33_category"]=="默认")
                and{settings["list_filter_category"]} or{Filter_info.category[options["list_filter_i33_category"]] or options["list_filter_i33_category"]})[1]
        slf_orderby = ((string.isEmpty(options["list_filter_i23_orderby"]) or options["list_filter_i23_orderby"]=="默认")
                and{settings["list_filter_orderby"]} or{Filter_info.orderby[options["list_filter_i23_orderby"]] or options["list_filter_i23_orderby"]})[1]
        slf_qtext = ((string.isEmpty(options["list_filter_i07_qtext"]) or options["list_filter_qtext"]=="默认")
                and{settings["list_filter_qtext"]} or{options["list_filter_i07_qtext"]})[1]
    end
    if slf_qtext=="plain" then
        keywordPlain= string.trim(keyword)
        listFilter= slf_orderby .."/"..slf_category
    elseif true or slf_qtext=="filter" then
        local keywordT= string.split(keyword,"$")
        for _,ktV in ipairs(keywordT) do
            local ktVp= string.gsub(ktV, "%s+","")
            local ktvFil,ktvFir = string.find(ktVp, "f[ilter]*[:=]")
            local ktvOv,ktvCv = nil,nil
            local isSuccess=false
            if ktvFil~=nil and string.isEmpty(listFilter) then
                local lfSettings={
                    ["category"]= slf_category,
                    ["orderby"]= slf_orderby,
                    ["order"]= math.floor(tonumber(slf_orderby) - (tonumber(slf_orderby) -1) %2),
                    ["ascdesc"]= math.floor((tonumber(slf_orderby) -1) %2),
                }
                local ktvOir = nil
                _,ktvOir,ktvOv = string.find(ktVp, "([%d%a_%+%-]+)[/\\]?",ktvFir)
                ktvOv= string.gsub(ktvOv or "","[/\\]","")
                for fioK,fioV in pairs(orderFp) do
                    if string.isEmpty(ktvOv) then
                        kiko.log("[WARN]  TPB.Search-Keyword.filter-orderby: Not found.")
                        kiko.message("[警告]  无法找到 顺序限定。",1|8)
                        ktvOv= lfSettings.order
                        isSuccess= true
                        break;
                    elseif tonumber(ktvOv)~=nil then
                        if ktvOv==fioV then
                            isSuccess= true
                            break;
                        end
                    else
                        local ktvOvs= string.split(ktvOv or "","_")
                        if (ktvOvs[1] or "")==fioK or ktvOvs[1]==fioV then
                            if string.sub(ktvOvs[1],#(ktvOvs[1]))=="-" or string.sub(ktvOvs[1],#(ktvOvs[1]))=="+" then
                                isSuccess= true
                                ktvOv= fioV
                                break;
                            end
                            ktvOvs[1]= tonumber(fioV)
                        end
                        if type(ktvOvs[1])=="number" then
                            if string.isEmpty(ktvOvs[2]) then
                                ktvOvs[2]= lfSettings.ascdesc
                                isSuccess= true
                            else
                                for fioaK,fioaV in pairs(Filter_info.ascdesc) do
                                    if (ktvOvs[2] or "")==fioaK or ktvOvs[2]==fioaV then
                                        ktvOvs[2]= tonumber(fioaV)
                                        isSuccess= true
                                        break;
                                    end
                                end
                            end
                        end
                        if isSuccess then
                            ktvOv= tostring(math.floor(ktvOvs[1] + ktvOvs[2]))
                            break;
                        end
                    end
                end
                if not isSuccess then
                    kiko.log("[WARN]  TPB.Search-Keyword.filter-orderby: Invalid.")
                    kiko.message("[警告]  识别到 排序限定 无效。",1|8)
                    ktvOv= lfSettings.order
                    isSuccess= true
                end
                _,_,ktvCv = string.find(ktVp, "([%d%a]+)",ktvOir or ktvFir)
                isSuccess= false
                if string.isEmpty(ktvCv) then
                    kiko.log("[WARN]  TPB.Search-Keyword.filter-category: Not found.")
                    kiko.message("[警告]  无法找到 类别限定。",1|8)
                    ktvCv= lfSettings.category
                    isSuccess= true
                else
                    for ficK,ficV in pairs(Filter_info.category) do
                        if tonumber(ktvCv)~=nil then
                            if ktvCv==ficV then
                                isSuccess= true
                                break;
                            end
                        elseif (ktvCv or "")==ficK or ktvCv==ficV then
                            ktvCv=ficV
                            isSuccess= true
                            break;
                        end
                    end
                end
                if not isSuccess then
                    kiko.log("[WARN]  TPB.Search-Keyword.filter-category: Invalid.")
                    kiko.message("[警告]  识别到 类别限定 无效。",1|8)
                    ktvCv= lfSettings.category
                    isSuccess= true
                end
            end
            if isSuccess then
                listFilter= ktvOv .."/".. ktvCv
            elseif ktvFil~=nil and string.isEmpty(listFilter) then
                kiko.log("[WARN]  TPB.Search-Keyword.filter-syntax: Wrong syntax.")
                kiko.message("[警告]  识别到限定语句 错误。",1|8)
            elseif ktvFil~=nil and not string.isEmpty(listFilter) then
                kiko.log("[WARN]  TPB.Search-Keyword.filter-syntax: Too many syntax(es).")
                kiko.message("[警告]  识别到限定语句 重复。",1|8)
            elseif true then
                keywordPlain= (string.isEmpty(keywordPlain) and{""} or{keywordPlain .." "})[1] .. string.trim(ktV)
            end
        end
        keywordPlain= (string.isEmpty(keywordPlain) and{""} or{keywordPlain})[1]
        listFilter= (string.isEmpty(listFilter) and{slf_orderby
                .."/"..slf_category} or{listFilter})[1]
    end
    kiko.log("[INFO]  TPB: searching <"..keywordPlain.."> in filter <"..listFilter..">.")

    local err, reply=kiko.httpget("http://".. settings["aname_website_alias"] .."/search/"..
                string.gsub(keywordPlain, "[ %c%p%^%&%|<>]", "%%20") .."/".. page .."/"..
                (listFilter or "7/0"))
    if err~=nil or (reply or{}).hasError==true then
        kiko.log("[ERROR] TPB.reply-search.httpget: ".. (err or "").."<"..
                string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
        error((err or "").."<".. string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
    end
    local content = reply["content"]

    local os_time = os.time()
    local _,_,pageLx,pageRx,totalCount=string.find(content,"<span>Search results:%s*[^<]*</span>&nbsp;Displaying hits from (%d+) to (%d+) %(approx (%d+) found%)")
    if pageLx==nil or pageRx==nil or totalCount==nil then
        error("[ERROR] TPB.webPage.decode: None of page index / total count is found.")
    end
    if totalCount=="0" or pageLx==pageRx then
        return {}, 0
    end
    -- pageLx= math.floor(tonumber(pageLx) or 0)
    -- pageRx= math.floor(tonumber(pageRx) or 0)
    -- totalCount= math.floor(tonumber(totalCount) or 0)
    local pageCount=math.ceil(tonumber(totalCount) / (tonumber(pageRx) - tonumber(pageLx)))
    kiko.log("[INFO]  ".. (totalCount or "0") .." items on <".. keyword .."> are found, showing index ".. pageLx .."~".. pageRx ..".")

    local patternF,kregexF = nil,nil
    patternF=[[(?<=</thead>)\s*(<tr>[\s\S]+</tr>)\s*(?=</table>)]]
    kregexF = kiko.regex(patternF,"i")
    local spos,epos,_= kregexF:find(content)
    if spos==nil then
        error("[ERROR] TPB.webPage.decode: None of table rows is found.")
    end
    local npos=spos -- 每个循环块的结束index 为下一次开始index
    local itemsList={}
    while npos<epos do
        local lnpos=npos -- 每次搜索字符串的结束index 为下一次开始index
        local url,title,magnet,time,size,uploader = nil,nil,nil,nil,nil,nil
        patternF= [[<div class="[^"]*">\s*<a href="([^"]*)" class="[^"]*" title="[^"]*">([^"]*)</a>]]
        kregexF = kiko.regex(patternF,"i")
        _,lnpos,url,title= kregexF:find(content,lnpos)
        if lnpos==nil then break end
        patternF= [[<a href="(magnet:?[^"]*)" title=]]
        kregexF = kiko.regex(patternF,"i")
        _,lnpos,magnet= kregexF:find(content,lnpos)
        patternF= [[<font class="[^"]*">Uploaded ([^,]*), Size ([^,]*), ULed by\s*<[^>]*>([^<]*)</a> </font>]]
        kregexF = kiko.regex(patternF,"i")
        _,lnpos,time,size,uploader= kregexF:find(content,lnpos)
        title= string.unescape(title)
        size= string.gsub(size or "", "(%d*%.?%d*)&nbsp;([IiBbKkMmGgTtPp]*)", "%1 %2") -- 667.49&nbsp;MiB
        time= string.gsub(time or "", "&nbsp;", " ")
        time= string.gsub(time or "", "<b>", "")
        time= string.gsub(time or "", "</b>", "")
        time= string.gsub(time or "", "(%d*)%-(%d*) (%d*)$", "%3-%1-%2") -- 01-06&nbsp;2020
        local thour,tmin = nil,nil
        thour,tmin = string.match(time or ""," (%d*):(%d*)$")
        if (tonumber(thour) ~= nil and tonumber(thour) ~= nil) then
            local tdays,tmins,tz_total_min,sdday = nil,nil,nil,nil,nil
            tz_total_min = math.floor(tonumber(string.sub(os.date("%z",os_time) or"",1,3)) or 0) *60 +
                math.floor(tonumber(string.sub(os.date("%z",os_time) or"",4,5)) or 0)
                - 1 * 60 -- TODO: TPB并非世界时的时刻，相差1h，原因未知
            
            local t_ymd= string.gsub(time or "", "^(%d*)%-(%d*) ", os.date("%Y",os_time - tz_total_min *60).."-%1-%2 ") -- 01-06&nbsp;20:20
            if(t_ymd~=nil) then
                local t_stamp = Datetime.strToStamp(string.format("%sT%s:00Z%s",t_ymd, string.match(time, "%d*:%d*"),
                                    string.format("%+03d:%02d",math.floor(tz_total_min/60),math.floor(tz_total_min%60))))
                time= string.gsub(time or "", "^%d*%-%d* %d*:%d*", os.date("%Y-%m-%d %H:%M",t_stamp)) -- Today&nbsp;02:59
            
            end
            tmins = math.floor(tonumber(thour)) *60 + math.floor(tonumber(tmin)) + tz_total_min
            thour = math.floor(tmins/60%24)
            tmin = math.floor(tmins%60)
            -- tday = math.floor(tmins/60/24)
            tdays = nil
            tdays = ((string.match(time or "","Y%-day")) and{-1} or{tdays})[1]
            tdays = ((string.match(time or "","Today")) and{0} or{tdays})[1]
            if(tdays ~= nil) then
                sdday = os.date("%Y-%m-%d",os_time - tz_total_min *60 + tdays *3600*24)
                time= string.gsub(time or "", "Y%-day %d*:%d*", string.format("%s %02d:%02d", sdday, thour, tmin)) -- Y-day&nbsp;02:59
                time= string.gsub(time or "", "Today %d*:%d*", string.format("%s %02d:%02d", sdday, thour, tmin)) -- Today&nbsp;02:59
            end
        end
        local n_minsago,sdt_minsago = tonumber(string.match(time or "", "(%d*) mins* ago")), ""
        if n_minsago ~= nil then
            sdt_minsago = os.date("%Y-%m-%d %H:%M",os_time - n_minsago *60)
        end
        time= string.gsub(time or "", "(%d*) mins* ago", sdt_minsago) -- 20&nbsp;mins&nbsp;ago

        table.insert(itemsList,{
            ["title"]=title,
            ["size"]=size,
            ["time"]=time,
            ["magnet"]=magnet,
            ["url"]=url
        })
        _,lnpos=string.find(content,"<tr",lnpos)
        if lnpos==nil then break end
        npos=lnpos
        -- kiko.log(string.format("%s | %s | %s",#itemsList,npos,epos))
    end
    return itemsList, pageCount
end

function setoption(key, val)
    -- 显示设置更改信息
    kiko.log(string.format("[INFO]  Settings changed: %s = %s", key, val))

    if key=="aname_website_alias" then
        
        local hg_theme= "Fleabug/1" -- Flebag (2016)
        local err, reply=kiko.httpget("http://".. settings["aname_website_alias"] .."/search/".. hg_theme
                .."/"..settings["list_filter_orderby"] .."/"..settings["list_filter_category"])
        if err~=nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] TPB.reply-test.httpget: ".. (err or "").."<"..
                string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            kiko.dialog({
                ["title"]="测试 thePirateBay 的域名是否有效连接",
                ["tip"]="[错误]\t"..(err or "").."<".. string.format("%03d",(reply or{}).statusCode or 0)..
                        "> "..((reply or{}).errInfo or"").."！",
                ["text"]="+ thePirateBay 网站代理/镜像的合集(可能不安全) - https://piratebay-proxylist.com",
            })
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
        else
            kiko.dialog({
                ["title"]="测试 thePirateBay 的域名是否有效连接",
                ["tip"]="\t成功设置 `网址 - TPB域名` ！",
                ["text"]=nil,
            })
        end
    end
end

function scriptmenuclick(menuid)
    if menuid == "detect_valid_connect" then
        
        local diaTitle, diaTip, diaText = "检测 - 域名是否有效连接","",""
        local hg_theme= "Fleabug/1" -- Flebag (2016)
        local err, reply=kiko.httpget("http://".. settings["aname_website_alias"] .."/search/".. hg_theme
                .."/"..settings["list_filter_orderby"] .."/"..settings["list_filter_category"])
        if err~=nil or (reply or{}).hasError==true then
            kiko.log("[ERROR] TPB.reply-test.httpget: ".. (err or "").."<"..
                string.format("%03d",(reply or{}).statusCode or 0)..">"..((reply or{}).errInfo or""))
            diaTip= "[错误]\t"..(err or "").."<".. string.format("%03d",(reply or{}).statusCode or 0)..
                        "> "..((reply or{}).errInfo or"").."！"
            diaText= "+ thePirateBay 网站代理/镜像的合集(可能不安全) - https://piratebay-proxylist.com"
            -- error((err or "").."<".. string.format("%03d",(reply or{}).statusCode)..">"..(reply or{}).errInfo or"")
        else
            diaTip= "\t成功连接 `网址 - TPB域名` ！"
        end

        kiko.dialog({
            ["title"]= diaTitle,
            ["tip"]= diaTip,
            ["text"]=  (string.isEmpty(diaText) and{nil} or{diaText})[1],
        })
    -- elseif menuid == "link_repo_usage" then
    --     kiko.execute(true, "cmd", {"/c", "start", "https://github.com/---"})
    elseif menuid == "display_dialog_about" then
        local img_back_data= nil
        -- local header = {["Accept"] = "image/jpeg" }
        -- local err, reply = kiko.httpget("https://github.com/---", {} , header)
        -- if err ~= nil then
        --     img_back_data=nil
        -- else
        --     img_back_data=reply["content"]
        -- end
        kiko.dialog({
            ["title"]= "关于",
            ["tip"]= "\t\t\t\tEdited by: anonymous\n\n"..
                    "脚本 TPBsource (/bgm_calendar/traktlist.lua) 是一个媒体资源信息脚本，\n"..
                    "主要从 thePirateBay 刮削媒体资源信息。\n"..
                    "\n欢迎到 KikoPlay的QQ群 反馈！\n",-- 此脚本的GitHub页面 或
            ["text"]= -- "+ 此脚本的GitHub页面 - \n"..
                    -- "\t 用法、常见问题…\n"..
                    "\n本脚本基于：\n"..
                    "+ thePirateBay 网站\n"..
                    "+ thePirateBay 网站代理/镜像的合集(可能不安全) - https://piratebay-proxylist.com\n"..
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

-- copy from & thanks to "../resource/mikan.lua" in "KikoPlay/resource"|KikoPlayScript
-- 替换`&..`转义字符
function string.unescape(str)
    if type(str) ~= "string" then return str end
    str = string.gsub( str, '&lt;', '<' )
    str = string.gsub( str, '&gt;', '>' )
    str = string.gsub( str, '&quot;', '"' )
    str = string.gsub( str, '&apos;', "'" )
    str = string.gsub( str, '&#(%d+);', function(n) return utf8.char(n) end )
    str = string.gsub( str, '&#x(%x+);', function(n) return utf8.char(tonumber(n,16)) end )
    str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
    return str
end

-- copy from & thanks to - https://blog.csdn.net/fightsyj/article/details/85057634
--* string.split("abc","b")
--* @return: (table){} - 无匹配，返回 (table){input}
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
-- string.trim():: nil->nil | ""->""
function string.trim(input)
    if type(input)~="string" then
        return input
    end
    input= string.gsub(input,"^%s+","")
    input= string.gsub(input,"%s+$","")
    return input
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

--* (string)str :: "2022-03-01T07:00:00-05:00" -> timestamp
function Datetime.strToStamp(input)
    local dateTa={}
    local secZdt=0
    -- if isFromLocal==nil then isFromLocal=false end

    local p_stamp = os.time()
    local timezone = (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",1,3)) or 0)) *3600 +
                    (math.floor(tonumber(string.sub(os.date("%z",os.time()) or"",4,5)) or 0)) *60
    if string.isEmpty(input) then
        return p_stamp
    else
        local dataTap= os.date("*t",p_stamp)
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
                or{timezone})[1]
    end
    return os.time(dateTa) -secZdt +timezone
end
