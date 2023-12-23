info = {
    ["name"] = "异世界动漫",
    ["id"] = "Kikyou.d.ysjdm",
	["desc"] = "异世界动漫弹幕脚本，www.mikudm.com",
	["version"] = "0.3"
}

settings = {
    ["latest_addr"] = {
        ["title"] = "异世界动漫最新地址",
        ["desc"] = "地址不要添加'http://'前缀",
        ["default"] = "www.mikudm.com",
    }
}

supportedURLsRe = {
    "(https?://)?www\\.mikudm\\.com/index.php/vod/(detail|play)/id/\\d+(/sid/\\d+/nid/\\d+)?.html"
}

sampleSupporedURLs = {
    "https://www.mikudm.com/index.php/vod/detail/id/1417.html",
    "https://www.mikudm.com/index.php/vod/play/id/1559/sid/1/nid/1.html"
}

function search(keyword)
    local err, reply = kiko.httpget(string.format("https://%s/index.php/vod/search.html", settings["latest_addr"]), {["wd"]=keyword})
    if err ~= nil then error(err) end
    local content = reply["content"]
    local parser = kiko.htmlparser(content)
    local spos, epos = string.find(content, "<div class=\"searchlist_titbox")
    local results = {}
    while spos do
        parser:seekto(spos - 1)
        parser:readnext()
        parser:readnext()
        parser:readnext()
        if parser:curnode()=="a" then
            local data = { ["collection"] = string.format("https://%s/", settings["latest_addr"]) .. parser:curproperty("href") }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = parser:curproperty("title"),
                ["data"] = data_str
            })
        end
        spos, epos = string.find(content, "<div class=\"searchlist_titbox", epos)
    end
    return results
end

function epinfo(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    if source_obj["ep"] ~= nil then return {source} end
    if source_obj["collection"]==nil then error("epinfo error: no collection url") end
    local err, reply = kiko.httpget(source_obj["collection"])
    if err ~= nil then error(err) end
    local content = reply["content"]
    local parser = kiko.htmlparser(content)
    local spos, epos = string.find(content, "<div class=\"playlist_full")
    local results = {}
    if spos then
        parser:seekto(spos - 1)
        parser:readnext()
        parser:readnext()
        parser:readnext()
        while parser:curnode()=="li" and parser:start() do
            parser:readnext()
            local data = { ["ep"] = string.format("https://%s/", settings["latest_addr"]) .. parser:curproperty("href") }
            local _, data_str = kiko.table2json(data)
            table.insert(results, {
                ["title"] = parser:readcontent(),
                ["data"] = data_str
            })
            parser:readnext()
            parser:readnext()
            parser:readnext()
        end
    end
    return results
end

function urlinfo(url)
    local pattens = {
        ["https?://?" .. settings["latest_addr"] .. "/index.php/vod/detail/id/%d+.html"] = "collection",
        [settings["latest_addr"] .. "/index.php/vod/detail/id/%d+.html"] = "collection",
        ["https?://?" .. settings["latest_addr"] .. "/index.php/vod/play/id/%d+/sid/%d+/nid/%d+.html"] = "ep",
        [settings["latest_addr"] .. "/index.php/vod/play/id/%d+/sid/%d+/nid/%d+.html"] = "ep",
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

    if matched == "ep" then 
        local data = { ["ep"] = url }
        local _, data_str = kiko.table2json(data)
        return {{["data"] = data_str, ["title"] = "unknown"}}
    elseif matched == "collection" then
        local data = { ["collection"] = url }
        local _, data_str = kiko.table2json(data)
        return epinfo({["data"] = data_str})
    end
end

function downloadDanmu(id)
    local dm_url= "https://bf.sbdm.cc/dmku/"
    local err, reply = kiko.httpget(dm_url, {["ac"]="get", ["id"]=id})
    if err ~= nil then error(err) end
    local err, obj = kiko.json2table(reply["content"]) 
    if err ~= nil then error(err) end
    local danmuList = {}
    for _, dm in ipairs(obj["danmuku"]) do
        if dm[6] ~= "127.0.0.1" then
            local color = 0xffffff
            local _, _ , r, g, b = string.find(dm[3], "rgb%((%d+),%s*(%d+),%s*(%d+)%)")
            if r ~= nil and g ~= nil and b ~= nil then
                color = tonumber(r) << 16 | tonumber(g) << 8 | tonumber(b)
            end
            local dmType = 0
            if dm[2] == "top" then
                dmType = 1
            elseif dm[2] == "bottom" then
                dmType = 2
            end
            table.insert(danmuList, {
                ["text"]=dm[5],
                ["time"]=tonumber(dm[1]) * 1000,
                ["color"]=color,
                ["type"]=dmType,
                ["date"]=dm["create_time"],
                ["sender"]="[YSJDM]"
            })
        end
    end
    return danmuList
end

function danmu(source)
    local err, source_obj = kiko.json2table(source["data"])
    if err ~= nil then error(err) end

    if source_obj["dm_id"] ~= nil then
        return nil, downloadDanmu(source_obj["dm_id"])
    end

    local ep_url = source_obj["ep"]
    if ep_url == nil then return nil, {} end
    local err, reply = kiko.httpget(ep_url)
    if err ~= nil then error(err) end
    local content = reply["content"]
    if source["title"] == "unknown" then
        local _, _, title = string.find(content, "<title>(.*)</title>")
    if title ~= nil then source["title"] = title end
    end
    local _, _, player_info = string.find(content, "player_aaaa%s*=%s*(%{.-%})")
    if player_info == nil then error("视频信息解析失败: player_info") end
    local err, player_info_obj = kiko.json2table(player_info)
    if err ~= nil then error("视频信息解析失败: " .. err) end
    local video_url = player_info_obj["url"]
    if video_url == nil then error("视频信息解析失败: video_url") end

    local err, reply = kiko.httpget("https://bf.sbdm.cc/m3u8.php", {["url"]=video_url}, {["Referer"]=string.format("https://%s/", settings["latest_addr"])})
    if err ~= nil then error(err) end
    local content = reply["content"]
    local _, _, dm_id = string.find(content, "\"id\"%s*:%s*\"(.-)\",")
    if dm_id == nil then error("视频信息解析失败: dm_id") end

    source_obj["dm_id"] = dm_id
    local _, data_str = kiko.table2json(source_obj)
    source["data"] = data_str
    return source, downloadDanmu(source_obj["dm_id"])
end