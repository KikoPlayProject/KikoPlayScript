scriptInfo = {
    ["title"] = "Mikan",
    ["id"] = "Kikyou.Mikan",
	["description"] = "Mikan Project搜索, mikanani.me",
	["version"] = "0.1",
}
function search(keyword,page)
    --kiko_HttpGet arg:
    --  url: string
    --  query: table, {["key"]=value} value: string
    --  header: table, {["key"]=value} value: string
    local err,content=kiko_HttpGet("https://mikanani.me/Home/Search",{["searchstr"]=keyword},{})
    if err~=nil then
        return err,0,{}
    end
    local rowPos=1
    local itemsList={}
    rowPos=string.find(content,"<tr class=\"js-search-results-row\"",rowPos,true)
    while rowPos~=nil do
        local _,cpos,url,title=string.find(content,"<a href=\"(.-)\".->(.-)</a>",rowPos)
        url="https://mikanani.me" .. url
        title=string.gsub(title,"&amp;","&")
        title=string.gsub(title,"&it;","<")
        title=string.gsub(title,"&gt;",">")
        title=string.gsub(title,"&quot;","\"")
        title=string.gsub(title,"&nbsp;"," ")
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
    return nil,pageCount,itemsList
end