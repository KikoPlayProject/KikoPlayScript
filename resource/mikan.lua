info = {
    ["name"] = "Mikan",
    ["id"] = "Kikyou.r.Mikan",
	["desc"] = "Mikan Project资源搜索, mikanani.me",
	["version"] = "0.1",
}
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
--[[
local gsub, char = string.gsub, string.char
local entityMap  = {["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local entitySwap = function(orig,n,s)
  return (n=='' and entityMap[s])
         or (n=="#" and tonumber(s)) and string.char(s)
         or (n=="#x" and tonumber(s,16)) and string.char(tonumber(s,16))
         or orig
end
function unescape(str)
  return (gsub( str, '(&(#?x?)([%d%a]+);)', entitySwap ))
end
--]]
function search(keyword,page)
    --kiko_HttpGet arg:
    --  url: string
    --  query: table, {["key"]=value} value: string
    --  header: table, {["key"]=value} value: string
    local err,reply=kiko.httpget("https://mikanani.me/Home/Search",{["searchstr"]=keyword})
    if err~=nil then error(err) end
    local content = reply["content"]
    local rowPos=1
    local itemsList={}
    rowPos=string.find(content,"<tr class=\"js-search-results-row\"",rowPos,true)
    while rowPos~=nil do
        local _,cpos,url,title=string.find(content,"<a href=\"(.-)\".->(.-)</a>",rowPos)
        url="https://mikanani.me" .. url
        --title=string.gsub(title,"&amp;","&")
        --title=string.gsub(title,"&it;","<")
        --title=string.gsub(title,"&gt;",">")
        --title=string.gsub(title,"&quot;","\"")
        --title=string.gsub(title,"&nbsp;"," ")
        title=unescape(title)
        local _,cpos,magnet=string.find(content,"data%-clipboard%-text=\"(.-)\"",cpos)
        magnet=string.gsub(magnet,"&amp;","&")
        local _,cpos,size=string.find(content,"<td>%s*(.-)%s*</td>",cpos)
        local _,cpos,time=string.find(content,"<td>%s*(.-)%s*</td>",cpos)
        rowPos=cpos
        table.insert(itemsList,{
            ["title"]=title,
            ["size"]=size,
            ["time"]=time,
            ["magnet"]=magnet,
            ["url"]=url
        })
        rowPos=string.find(content,"<tr class=\"js-search-results-row\"",rowPos,true)
    end
    local pageCount=1
    if rawlen(itemsList)==0 then
        pageCount=0
    end
    return itemsList, pageCount
end