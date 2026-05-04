info = {
    ["name"] = "Bilibili",
    ["id"] = "Kikyou.d.Bilibili",
	["desc"] = "Bilibili弹幕脚本",
	["version"] = "0.4",
    ["min_kiko"] = "2.1.0",
    ["label_color"] = "0xDC478A",
    ["icon"] = [[<svg t="1774450898386" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1692" width="64" height="64"><path d="M360.896 183.968L269.984 95.872s-14.208-17.472 9.824-37.248c24.16-19.648 25.376-10.912 33.504-5.472s135.2 130.816 135.2 130.816h-87.616z m301.952 3.264l90.912-88.096s14.208-17.472-9.824-37.248c-24.032-19.648-25.376-10.912-33.504-5.472s-135.2 130.816-135.2 130.816h87.616z m341.152 163.104c-3.264-137.984-123.168-164.192-123.168-164.192s-614.336-4.96-742.496 0C10.176 222.304 20 350.336 20 350.336s1.696 274.272-0.128 413.12c13.824 138.848 120.864 160.928 120.864 160.928s42.72 0.864 73.92 0.864c3.264 8.992 5.696 52.544 54.24 52.544 48.416 0 54.24-52.544 54.24-52.544s354.88-1.696 384.352-1.696c1.696 14.816 8.992 54.976 57.536 54.24 48.416-0.864 51.712-57.536 51.712-57.536s16.384-1.696 65.664 0c114.944-21.376 121.6-156.064 121.6-156.064s-1.568-275.872 0-413.856z m-98.912 439.232c0 21.728-17.248 39.456-38.464 39.456H167.2c-21.248 0-38.464-17.6-38.464-39.456V326.336c0-21.728 17.248-39.456 38.464-39.456h699.424c21.248 0 38.464 17.6 38.464 39.456v463.232zM202.4 457.152l205.344-39.456 15.52 77.184-203.648 39.456z m638.976 0l-205.344-39.456-15.648 77.184 203.776 39.456z m-418.08 191.392s45.152 81.312 95.264-26.336c48.416 105.088 101.824 27.904 101.824 27.904l30.336 19.776s-56.672 91.136-131.424 22.208c-63.232 68.928-129.728-21.952-129.728-21.952l33.728-21.6z" fill="#ffffff" p-id="1693"></path></svg>]]
}

supportedURLsRe = {
    "(https?://)?www\\.bilibili\\.com/video/av[0-9]+/?",
    "(https?://)?www\\.bilibili\\.com/video/BV[\\dA-Za-z]+/?",
    "av[0-9]+",
    "BV[\\dA-Za-z]+",
    "(https?://)?www\\.bilibili\\.com/bangumi/media/md[0-9]+/?",
    "(https?://)?www\\.bilibili\\.com/bangumi/play/ss[0-9]+/?",
    "(https?://)?www\\.bilibili\\.com/bangumi/play/ep[0-9]+/?"
}

sampleSupporedURLs = {
    "https://www.bilibili.com/video/av1728704",
    "https://www.bilibili.com/video/BV11x411P7TB",
    "av24213033",
    "BV11x411P7TB",
    "https://www.bilibili.com/bangumi/media/md28221404",
    "https://www.bilibili.com/bangumi/play/ss36429",
    "https://www.bilibili.com/bangumi/play/ep409605"
}

function str2time(time_str)
    local pos = 0
    for i = 1,#time_str do
        local ch = string.sub(time_str, i, i)
        if ch == ':'  then
            pos = i
            break
        end
    end
    if pos == 0 then
        return tonumber(time_str) or 0
    else
        local minute = tonumber(string.sub(time_str, 1, pos-1)) or 0
        local second = tonumber(string.sub(time_str, pos+1)) or 0
        return minute*60+second
    end
end

function search(keyword)
    local query = {
        ["keyword"]=keyword
    }
    local header = {
        ["Accept"]="application/json"
    }
    local err, reply = kiko.httpget("https://api.bilibili.com/x/web-interface/search/all", query, header)
    if err ~= nil then  error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    local ret = obj["data"]["result"]
    if ret == nil then
        return {}
    end
    local bangumiResult, ftResult, videoResult = ret["media_bangumi"], ret["media_ft"], ret["video"]
    local results = {}
    if bangumiResult and ftResult then
        local bgmResult = table.move(ftResult, 1, #ftResult, #bangumiResult+1, bangumiResult)
        for _, sobj in ipairs(bgmResult) do
            local data = {
                ["media_id"] = string.format("%d", sobj["media_id"]),
                ["season_id"] = string.format("%d", sobj["season_id"]),
                ["stype"] = "collection"
            }
            local _, data_str = kiko.table2json(data, 'compact')
            table.insert(results, {
                ["title"] = string.gsub(sobj["title"], "<([^<>]*)em([^<>]*)>", ""),
                ["desc"] = sobj["desc"],
                ["url"] = sobj["url"],
                ["data"] = data_str
            })
        end
    end
    if videoResult then
        for _, sobj in ipairs(videoResult) do
            local data = {
                ["aid"] = string.format("%d", sobj["id"]),
                ["bvid"] = sobj["bvid"],
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data, 'compact')
            table.insert(results, {
                ["title"] = string.gsub(sobj["title"], "<([^<>]*)em([^<>]*)>", ""),
                ["desc"] = sobj["description"],
                ["duration"] = str2time(sobj["duration"]),
                ["url"] = sobj["arcurl"],
                ["tags"] = {{
                    ["text"] = "UP:" .. sobj["author"],
                    ["link"] = string.format("https://space.bilibili.com/%d", sobj["mid"])
                },},
                ["data"] = data_str
            })
        end
    end
    return results
end

function epinfo(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    if source_obj["stype"]=="collection" or source_obj["stype"]=="collection_ss" then
        local query = { ["season_id"] = source_obj["season_id"] }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("https://api.bilibili.com/pgc/view/web/season", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local results = {}
        for _, bobj in ipairs(obj["result"]["episodes"]) do
            local index = bobj["title"]
            local title = bobj["long_title"]
            local data = {
                ["aid"] = string.format("%d", bobj["aid"]),
                ["cid"] = string.format("%d", bobj["cid"]),
                ["bvid"] = bobj["bvid"],
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data, 'compact')
            local fTitle = string.format("%s-%s", index, title)
            if title == nil or #title == 0 then
                fTitle = index
            end
            table.insert(results, {
                ["title"] = fTitle,
                ["duration"] = bobj["duration"]/1000,
                ["url"] = bobj["link"],
                ["srcid"] = string.format("%d", bobj["cid"]),
                ["data"] = data_str
            })
        end
        return results
    elseif source_obj["stype"]=="collection_ep" then
        local query = { ["ep_id"] = source_obj["ep_id"] }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("https://api.bilibili.com/pgc/view/web/season", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local results = {}
        for _, bobj in ipairs(obj["result"]["episodes"]) do
            local index = bobj["title"]
            local title = bobj["long_title"]
            local data = {
                ["aid"] = string.format("%d", bobj["aid"]),
                ["cid"] = string.format("%d", bobj["cid"]),
                ["bvid"] = bobj["bvid"],
                ["stype"] = "video"
            }
            local _, data_str = kiko.table2json(data, 'compact')
            local fTitle = string.format("%s-%s", index, title)
            if title == nil or #title == 0 then
                fTitle = index
            end
            table.insert(results, {
                ["title"] = fTitle,
                ["duration"] = bobj["duration"]/1000,
                ["url"] = bobj["link"],
                ["srcid"] = string.format("%d", bobj["cid"]),
                ["data"] = data_str
            })
        end
        return results
    elseif source_obj["stype"]=="video" then
        local query = {}
        local url = ""
        if source_obj["aid"] ~= nil then
            query["aid"] = source_obj["aid"]
            url = string.format("https://www.bilibili.com/video/av%s", source_obj["aid"])
        else
            query["bvid"] = source_obj["bvid"]
            url = string.format("https://www.bilibili.com/video/%s", source_obj["bvid"])
        end
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("http://api.bilibili.com/x/web-interface/view", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local obj = obj["data"]
        local aid = string.format("%d", obj["aid"])
        local results = {}
        for i, bobj in ipairs(obj["pages"]) do
            local data = {
                ["cid"] = string.format("%d", bobj["cid"]),
                ["stype"] = "video"
            }
            if i == 1 then
                data["aid"] = aid
                data["bvid"] = obj["bvid"]
            end
            local _, data_str = kiko.table2json(data, 'compact')
            table.insert(results, {
                ["title"] = bobj["part"],
                ["duration"] = bobj["duration"] or 0,
                ["url"] = url,
                ["tags"] = source["tags"] or {},
                ["data"] = data_str,
                ["srcid"] = string.format("%d", bobj["cid"])
            })
        end
        return results
    else
        return {}
    end
end

function urlinfo(url)
    local pattens = {
        ["https?://www%.bilibili%.com/video/av[0-9]+/?"]="av",
        ["www%.bilibili%.com/video/av[0-9]+/?"]="av",
        ["https?://www%.bilibili%.com/video/BV[%dA-Za-z]+/?"]="bv",
        ["www%.bilibili%.com/video/BV[%dA-Za-z]+/?"]="bv",
        ["av%d+"]="av",
        ["BV[%dA-Za-z]+"]="bv",
        ["https?://www%.bilibili%.com/bangumi/media/md[0-9]+/?"]="bgm",
        ["www%.bilibili%.com/bangumi/media/md[0-9]+/?"]="bgm",
        ["https?://www%.bilibili%.com/bangumi/play/ss[0-9]+/?"]="bgm_play_ss",
        ["www%.bilibili%.com/bangumi/play/ss[0-9]+/?"]="bgm_play_ss",
        ["https?://www%.bilibili%.com/bangumi/play/ep[0-9]+/?"]="bgm_play_ep",
        ["www%.bilibili%.com/bangumi/play/ep[0-9]+/?"]="bgm_play_ep"
    }
    local matched = nil
    for pv, k in pairs(pattens) do
        s, e = string.find(url, pv)
        if s then
            if e - s + 1 == #url then
                matched = k
                break
            end
        end
    end
    if matched == nil then error("不支持的URL") end
    if matched == "av" then
        local _, _, aid = string.find(url, "av(%d+)")
        return epinfo({
            ["data"] = string.format("{\"aid\":\"%s\", \"stype\": \"video\"}", aid)
        })
    elseif matched == "bgm" then
        local _, _, bgmid = string.find(url, "md(%d+)")
        local query = { ["media_id"] = bgmid }
        local header = { ["Accept"]="application/json" }
        local err, reply = kiko.httpget("https://api.bilibili.com/pgc/review/user", query, header)
        if err ~= nil then error(err) end
        local content = reply["content"]
        local err, obj = kiko.json2table(content)
        if err ~= nil then error(err) end
        local obj = obj["result"]["media"]
        local season_id = obj["season_id"]
        if season_id == nil then error("invalid media_id") end
        return epinfo({
            ["data"] = string.format("{\"season_id\":\"%s\", \"stype\": \"collection\"}", season_id)
        })
    elseif matched == "bgm_play_ss" then
        local _, _, bgmid = string.find(url, "ss(%d+)")
        return epinfo({
            ["data"] = string.format("{\"season_id\":\"%s\", \"stype\": \"collection_ss\"}", bgmid)
        })
    elseif matched == "bgm_play_ep" then
        local _, _, bgmid = string.find(url, "ep(%d+)")
        return epinfo({
            ["data"] = string.format("{\"ep_id\":\"%s\", \"stype\": \"collection_ep\"}", bgmid)
        })
    elseif matched == "bv" then
        local _, _, bvid = string.find(url, "(BV[%dA-Za-z]+)")
        return epinfo({
            ["data"] = string.format("{\"bvid\":\"%s\", \"stype\": \"video\"}", bvid)
        })
    end
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    local cid = source_obj["cid"]
    if cid == nil then return {} end
    local err, reply = kiko.httpget(string.format("http://comment.bilibili.com/%s.xml", cid))
    if err ~= nil then error(err) end
    local content = reply["content"]
    local danmus = {}
    local xmlreader = kiko.xmlreader(content)
    local dm_state = 0
    while not xmlreader:atend() do
        if xmlreader:startelem() and xmlreader:name()=="state" then
            dm_state = tonumber(xmlreader:elemtext()) or 0
        end
        if xmlreader:startelem() and xmlreader:name()=="d" then
            if xmlreader:hasattr("p") then
                local attrs = string.split(xmlreader:attr("p"), ',')
                if #attrs >= 8 then
                    local text = xmlreader:elemtext()
                    local time = tonumber(attrs[1]) * 1000
                    local mode = tonumber(attrs[2])
                    local dmType = 0 --rolling
                    if mode == 4 then
                        dmType = 2  --bottom
                    elseif mode == 5 then
                        dmType = 1  --top
                    end
                    local size = tonumber(attrs[3])
                    if size == 18 then
                        size = 1
                    elseif size == 36 then
                        size = 2
                    else 
                        size = 0
                    end
                    local color = tonumber(attrs[4])
                    local date = attrs[5]
                    local sender = "[Bilibili]" .. attrs[7]
                    table.insert(danmus, {
                        ["text"]=text,
                        ["time"]=time,
                        ["color"]=color,
                        ["fontsize"]=size,
                        ["type"]=dmType,
                        ["date"]=date,
                        ["sender"]=sender
                    })
                end
            end
        end
        xmlreader:readnext()
    end
    if dm_state ~= 0 then
        if source["valid"] == nil or source["valid"] == true then
            kiko.log(string.format("cid: %s 可能已失效，state: %d", cid, dm_state))
            source["valid"] = false
            return source, danmus
        end
    else
        if source["valid"] ~= nil and source["valid"] == false then
            kiko.log(string.format("cid: %s 已恢复，state: %d", cid, dm_state))
            source["valid"] = true
            return source, danmus
        end
    end
    return nil, danmus
end
