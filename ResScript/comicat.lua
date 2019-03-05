scriptInfo = {
    ["title"] = "漫猫BT",
    ["id"] = "Kikyou.Comicat",
	["description"] = "漫猫BT搜索, www.comicat.org",
	["version"] = "0.1",
}
--return: 
--  errorInfo: nil/string
--  pageCount: number
--  searchResult: table, {Item}
--      Item:  table {"title"="","size"="","time"="","magnet"="",url=""}
function search(keyword,page)
    --kiko_HttpGet arg:
    --  url: string
    --  query: table, {["key"]=value} value: string
    --  header: table, {["key"]=value} value: string
    local err,content=kiko_HttpGet("http://www.comicat.org/search.php",{["keyword"]=keyword,["page"]=page},{})
    if err~=nil then
        return err,0,{}
    end
    local _,_,pageCount=string.find(content,"<span class=\"text_bold\">.-共找到(%d+)条匹配资源</span>")
    if pageCount==nil then
        return "Comicat WebPage Decode Failed",0,{}
    end
    if pageCount=="0" then
        return nil,0,{}
    end
    pageCount=math.ceil(pageCount/50)
    local spos,epos=string.find(content,"<tbody class=\"tbody\" id=\"data_list\">.-</tbody>")
    if spos==nil then
        return "Comicat WebPage Decode Failed",0,{}
    end
    local npos=spos
    local itemsList={}
    while npos<epos do 
        local lnpos=npos
        local _,lnpos,time=string.find(content,"<td nowrap=\"nowrap\">%s*(.-)%s*</td>",lnpos)
        local _,lnpos,hash,title=string.find(content,"<a href=\"show%-(%w+)%.html\" target=\"_blank\">%s*(.-)%s*</a>",lnpos)
        title=string.gsub(title,"<.->"," ")
        title=string.gsub(title,"&amp;","&")
        title=string.gsub(title,"&it;","<")
        title=string.gsub(title,"&gt;",">")
        title=string.gsub(title,"&quot;","\"")
        title=string.gsub(title,"&nbsp;"," ")
        local _,lnpos,size=string.find(content,"<td>%s*(.-)%s*</td>",lnpos)
        local magnet="magnet:?xt=urn:btih:" .. hash .. "&tr=http://open.acgtracker.com:1096/announce"
        local url="http://www.comicat.org/show-" .. hash.. ".html"
        table.insert(itemsList,{
            ["title"]=title,
            ["size"]=size,
            ["time"]=time,
            ["magnet"]=magnet,
            ["url"]=url
        })
        local _,lnpos=string.find(content,"<tr",lnpos)
        if lnpos==nil then break end
        npos=lnpos
    end
    return nil,pageCount,itemsList
end