info = {
    ["name"] = "弹弹Match",
    ["id"] = "Kikyou.m.DDMatch",
	["desc"] = "弹弹Play动画关联脚本，利用弹弹Play API根据文件信息获取匹配的动画信息",
	["version"] = "0.1",
    ["min_kiko"] = "2.0.0",
}

settings = {
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

function setoption(key, val)
    kiko.log(string.format("Setting changed: %s = %s", key, val))
end

function getEpInfo(epTitle)
    local _, _, index, epName = string.find(epTitle, "第(%d+)话%s*(.*)")
    if index ~= nil then
        return tonumber(index), 1, epName or ""
    end
    local _, _, index, epName = string.find(epTitle, "第(%d+)集%s*(.*)")
    if index ~= nil then
        return tonumber(index), 1, epName or ""
    end
    local _, _, index, epName = string.find(epTitle, "S(%d+)%s*(.*)")
    if index ~= nil then
        return tonumber(index), 2, epName or ""
    end
    return 1, 1, epTitle
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

bgmIdCache = {}
function getBgmId(animeId)
    if bgmIdCache[animeId] ~= nil then
        return bgmIdCache[animeId]
    end

    local err, reply = nil, nil
    local path = "/api/v2/bangumi/" .. animeId
    if kiko.envinfo()["kservice"] then
        
        local header = {
            ["Accept"] = "application/json"
        }
        local options = {
            ["set_dandan_header"] = true,
            ["dandan_path"] = path,
        }
        err, reply = kiko.httpget("https://api.dandanplay.net" .. path, {}, header, options)
    else
        local header = get_header(path)
        err, reply = kiko.httpget("https://api.dandanplay.net" .. path, {}, header)
    end

    if err ~= nil then 
        kiko.log(err)
        return nil
    end
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil or obj["errorCode"] ~= 0 then
        kiko.log(err)
        return nil
    end
    local bgmPath = obj["bangumi"]["bangumiUrl"]
    kiko.log("BGM Path: " .. bgmPath)
    local bgmId = string.match(bgmPath, "https?://bangumi.tv/subject/(%d+)")
    if bgmId == nil then
        kiko.log("Failed to extract BGM ID from path: " .. bgmPath)
        bgmIdCache[animeId] = ""
        return nil
    end
    bgmIdCache[animeId] = bgmId
    return bgmId
end

function match(path)
    local err, fileHash = kiko.hashdata(path, true, 16*1024*1024)
    local post = {
        ["fileName"] = getFileTitle(path),
        ["fileSize"] = kiko.dir.fileinfo(path)["size"],
        ["fileHash"] = fileHash
    }
    local err, post_data = kiko.table2json(post)
    
    local err, reply = nil, nil
    if kiko.envinfo()["kservice"] then
        local header = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
        local options = {
            ["set_dandan_header"] = true,
            ["dandan_path"] = "/api/v2/match",
        }
        err, reply = kiko.httppost("https://api.dandanplay.net/api/v2/match", post_data, header, {}, options)
    else
        local header = get_header("/api/v2/match")
        header["Content-Type"] = "application/json"
        err, reply = kiko.httppost("https://api.dandanplay.net/api/v2/match", post_data, header)
    end
    
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
    local bgmId = getBgmId(animeId)
    local epIndex, epType, epName = getEpInfo(matchObj["episodeTitle"])
    local match_res = {
        ["success"]=true,
        ["anime"]={
            ["name"]=anime,
        },
        ["ep"]={
            ["name"]=epName,
            ["index"]=epIndex,
            ["type"]=epType
        }
    }
    if bgmId ~= nil and bgmId ~= "" then
        match_res["anime"]["data"] = bgmId
        match_res["anime"]["scriptId"] = "Kikyou.l.Bangumi"
    end
    return match_res
end