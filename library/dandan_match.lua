info = {
    ["name"] = "弹弹Match",
    ["id"] = "Kikyou.l.DDMatch",
	["desc"] = "弹弹Play动画关联脚本，利用弹弹Play API根据文件信息获取匹配的动画信息",
	["version"] = "0.1",
}

function setoption(key, val)
    kiko.log(string.format("Setting changed: %s = %s", key, val))
end

function getEpInfo(epTitle)
    local _, _, tp, index, epName = string.find(epTitle, "([^%d]+)(%d+).-%s(.+)")
    local epType = 1  -- 1: EP, 2: SP
    if tp == 'S' then
        epType = 2
    end
    local epIndex = tonumber(index)
    return epIndex, epType, epName
end

function search(keyword)
    local err, reply = kiko.httpget("https://api.acplay.net/api/v2/search/episodes", {["anime"]=keyword})
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    if not obj['success'] then
        error(obj['errorMessage'])
    end
    local animes = {}
    for _, anime in pairs(obj['animes']) do
        local animeName = anime["animeTitle"]
        local extra = anime["typeDescription"]
        local data = tostring(anime["animeId"])
        local epList = {}
        for __, ep in pairs(anime["episodes"]) do
            local epIndex, epType, epName = getEpInfo(ep["episodeTitle"])
            table.insert(epList,{
                ["index"]=epIndex,
                ["name"]=epName,
                ["type"]=epType
            })
        end
        table.insert(animes, {
            ["name"]=animeName,
            ["data"]=data,
            ["extra"]=extra,
            ["eps"]=epList
        })
    end
    return animes
end

function getFileTitle(path)
    local pos = 0
    for i = #path,1,-1 do
        local ch = string.sub(path, i, i)
        if ch == '\\' or ch == '/' then
            pos = i
            break
        end
    end
    local pos_dt = 0
    local titleExt = string.sub(path, pos+1)
    for i = 1,#titleExt do
        local ch = string.sub(titleExt, i, i)
        if ch == '.'  then
            pos_dt = i
            break
        end
    end
    return string.sub(titleExt, 1, pos_dt-1)
end

function match(path)
    local err, fileHash = kiko.hashdata(path, true, 16*1024*1024)
    local post = {
        ["fileName"] = getFileTitle(path),
        ["fileHash"] = fileHash
    }
    local header = {
        ["Content-Type"]="application/json",
        ["Accept"]="application/json"
    }
    local err, post_data = kiko.table2json(post)
    local err, reply = kiko.httppost("https://api.acplay.net/api/v2/match", post_data, header)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        error(err)
    end
    if not obj["isMatched"] then
        return {["success"]=false};
    end
    local matchObj = obj["matches"][1]
    if matchObj == nil then
        return {["success"]=false};
    end
    local anime = matchObj["animeTitle"]
    local animeId = tostring(matchObj["animeId"])
    local epIndex, epType, epName = getEpInfo(matchObj["episodeTitle"])
    return {
        ["success"]=true,
        ["anime"]={
            ["name"]=anime,
            ["data"]=animeId
        },
        ["ep"]={
            ["name"]=epName,
            ["index"]=epIndex,
            ["type"]=epType
        }
    }
end