info = {
    ["name"] = "Dandan",
    ["id"] = "Kikyou.d.Dandan",
	["desc"] = "弹弹Play弹幕脚本",
	["version"] = "0.7",
    ["min_kiko"] = "2.2.0",
    ["label_color"] = "0x25AAE1",
}


settings = {
    ["withRelated"] = {
        ["title"] = "获取全部弹幕",
        ["desc"] = "获取全部来源的弹幕（包含弹弹之外的来源）",
        ["default"] = "n",
        ["choices"] = "y,n"
    },
    ["appId"]={
        ["title"]="AppId",
        ["desc"]="弹弹Play开放平台AppId",
    },
    ["appSecret"]={
        ["title"]="AppSecret",
        ["desc"]="弹弹Play开放平台AppSecret",
    },
}

function hex2str(hex)
    local str = ""
    for i = 1, #hex, 2 do
        local byteStr = hex:sub(i, i + 1)
        local byte = tonumber(byteStr, 16)
        if byte then
            str = str .. string.char(byte)
        else
            error("Invalid hex string at position " .. i)
        end
    end
    return str
end

function get_header(path)
    local ts = os.time()
    local appid = settings["appId"]
    local appsecret = settings["appSecret"]
    local secret = string.format("%s%d%s%s", appid, ts, path, appsecret)
    local _, secret_hash = kiko.hashdata(secret, false, 0, 'sha256')
    local _, hash_base64 = kiko.base64(hex2str(secret_hash), 'to')
    return {
        ["Accept"] = "application/json",
        ["X-AppId"] = appid,
        ["X-Signature"] = hash_base64,
        ["X-Timestamp"] = ts
    }
end

function search(keyword)
    local err, obj = nil, nil
    if kiko.envinfo()["kservice"] and type(kiko.dsearch) == "function" then
        err, obj = kiko.dsearch(keyword)
        if err ~= nil then error(err) end
    else
        local query = { ["anime"] = keyword }
        local header = get_header("/api/v2/search/episodes")
        local reply
        err, reply = kiko.httpget("https://api.dandanplay.net/api/v2/search/episodes", query, header)
        if err ~= nil then error(err) end
        err, obj = kiko.json2table(reply["content"])
        if err ~= nil then error(err) end
        if obj["success"] ~= true then
            error(obj["errorMessage"] or "弹弹搜索失败")
        end
    end
    local animes = obj["animes"]
    if animes == nil then return {} end
    local results = {}
    
    for _, item in ipairs(animes) do
        local animeTitle = item["animeTitle"]
        local eps = item["episodes"]
        if eps ~= nil then
            local _, data_str = kiko.table2json(eps, 'compact')
            table.insert(results, {
                ["title"] = animeTitle,
                ["desc"] = string.format("共 %d 集", #eps),
                ["data"] = data_str
            })
        end
    end
    return results
end

function epinfo(source)
    local err, eps = kiko.json2table(source["data"])
    if err ~= nil then error(err) end
    local results = {}
    for _, ep in ipairs(eps) do
        table.insert(results, {
            ["title"] = ep["episodeTitle"],
            ["data"] = string.format("%d", ep["episodeId"])
        })
    end
    return results
end

function danmu(source)
    local err, obj = nil, nil
    if kiko.envinfo()["kservice"] and type(kiko.dcomment) == "function" then
        err, obj = kiko.dcomment(tonumber(source["data"]), settings["withRelated"] == 'y')
        if err ~= nil then error(err) end
        if type(obj) ~= "table" or type(obj["comments"]) ~= "table" then
            error("请更新 KikoPlay 以使用弹弹弹幕服务")
        end
    else
        local query = {}
        if settings["withRelated"] == 'y' then
            query["withRelated"] = "true"
        end
        local path = "/api/v2/comment/" .. source["data"]
        local reply
        err, reply = kiko.httpget("https://api.dandanplay.net" .. path, query, get_header(path))
        if err ~= nil then error(err) end
        err, obj = kiko.json2table(reply["content"])
        if err ~= nil then error(err) end
    end

    local danmuArray = obj["comments"]
    if danmuArray == nil then return nil, {} end

    local danmus = {}
    for _, dmObj in ipairs(danmuArray) do
        local text = dmObj["m"]
        local attrs = string.split(dmObj["p"], ',')
        if #attrs >= 4 then
            local time = tonumber(attrs[1])*1000
            local mode = tonumber(attrs[2])
            local dmType = 0 --rolling
            if mode == 4 then
                dmType = 2  --bottom
            elseif mode == 5 then
                dmType = 1  --top
            end
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
