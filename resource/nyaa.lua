info = {
    ["name"] = "Nyaa",
    ["id"] = "Kikyou.r.Nyaa",
	["desc"] = "Nyaa搜索, nyaa.si",
	["version"] = "0.1",
}
function search(keyword,page)
    --kiko_HttpGet arg:
    --  url: string
    --  query: table, {["key"]=value} value: string
    --  header: table, {["key"]=value} value: string
    local err,reply=kiko.httpget("https://nyaa.si/",{["f"]="0",["c"]="0_0",["q"]=keyword,["p"]=math.ceil(page)})
    if err~=nil then error(err) end
    local content = reply["content"]
    local _,_,pageCount=string.find(content,"(%d+)</a>%s*</li>%s*<li class=\"next\">")
    if pageCount==nil then
        pageCount=1
    end
    local rowPos=1
    local itemsList={}
    rowPos=string.find(content,"<tr class=\"default\">",rowPos,true)
    while rowPos~=nil do
        local _,cpos,url,title=string.find(content,"<td colspan=\"2\">.-<a href=\"(/view/%d+)\" title=\"(.-)\">",rowPos)
        url="https://nyaa.si" .. url
        title=string.gsub(title,"&amp;","&")
        title=string.gsub(title,"&it;","<")
        title=string.gsub(title,"&gt;",">")
        title=string.gsub(title,"&quot;","\"")
        title=string.gsub(title,"&nbsp;"," ")
        local _,cpos,magnet=string.find(content,"<a href=\"(magnet.-)\">",cpos)
        magnet=string.gsub(magnet,"&amp;","&")
        local _,cpos,size=string.find(content,"<td class=\"text%-center\">(.-)</td>",cpos)
        local _,cpos,time=string.find(content,"<td class=\"text%-center\".->(.-)</td>",cpos)
        rowPos=cpos
        table.insert(itemsList,{
            ["title"]=title,
            ["size"]=size,
            ["time"]=time,
            ["magnet"]=magnet,
            ["url"]=url
        })
        rowPos=string.find(content,"<tr class=\"default\">",rowPos,true)
    end
    if rawlen(itemsList)==0 then
        pageCount=0
    end
    return itemsList, tonumber(pageCount)
end