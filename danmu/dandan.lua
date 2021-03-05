info = {
    ["name"] = "Dandan",
    ["id"] = "Kikyou.d.Dandan",
	["desc"] = "弹弹Play弹幕脚本",
	["version"] = "0.1"
}

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

function search(keyword)
    local query = {
        ["anime"]=keyword
    }
    local header = {
        ["Accept"] = "application/json"
    }
    local err, reply = kiko.httpget("https://api.acplay.net/api/v2/search/episodes", query, header)
    if err ~= nil then error(err) end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then error(err) end
    local animes = obj["animes"]
    if animes == nil then return {} end
    local results = {}
    
    for _, item in ipairs(animes) do
        local animeTitle = item["animeTitle"]
        local eps = item["episodes"]
        if eps ~= nil then
            for _, ep in ipairs(eps) do
                table.insert(results, {
                    ["title"] = ep["episodeTitle"],
                    ["desc"] = animeTitle,
                    ["data"] = string.format("%d", ep["episodeId"])
                })
            end
        end
    end
    return results
end

function epinfo(source)
    return {source}
end

function danmu(source)
    local danmuUrl = "https://api.acplay.net/api/v2/comment/" .. source["data"]
    local err, reply = kiko.httpget(danmuUrl, {}, {["Accept"]="application/json"})
    if err ~= nil then error(err) end
    local danmuContent = reply["content"]

    local err, obj = kiko.json2table(danmuContent)
    local danmuArray = obj["comments"]
    if danmuArray == nil then return nil, {} end

    local danmus = {}
    for _, dmObj in ipairs(danmuArray) do
        local text = dmObj["m"]
        local attrs = string.split(dmObj["p"], ',')
        if #attrs >= 4 then
            local time = tonumber(attrs[1])*1000
            local dmType = tonumber(attrs[2])
            local color = tonumber(attrs[3])
            local sender = "[Dandan]" .. attrs[4]
            table.insert(danmus, {
                ["text"]=text,
                ["time"]=time,
                ["color"]=color,
                ["type"]=dmType,
                ["sender"]=sender
            })
        end
    end
    return nil, danmus
end
