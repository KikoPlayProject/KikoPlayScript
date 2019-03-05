# KikoPlay脚本仓库
---
这里存放KikoPlay的资源搜索脚本

## 如何使用
 下载ResScript目录中的lua脚本后，放到KikoPlay的script目录下，之后在KikoPlay脚本管理窗口中刷新或者重启KikoPlay

## 编写

KikoPlay使用lua脚本

脚本文件中需要包含如下内容：
 - scriptInfo table，包含脚本信息，其中["title"] = "...",["id"] = "..."是必需的
 - search 搜索函数，KikoPlay会调用进行搜索
     - 参数：keyword:string 搜索内容； page:number 搜索结果页码
     - 返回：
         - errorInfo: nil/string 是否出错/错误内容
         - pageCount: number 结果页数
         - searchResult: table, {Item}
             - Item:  table {"title"="","size"="","time"="","magnet"="",url=""}

KikoPlay提供了一个HTTP Get函数可供使用：kiko_HttpGet
 - 参数：
     - url: string
     - query: table, {["key"]="value"}
     - header: table, {["key"]="value"}
 - 返回：
     - err: 是否出错，无错误则为nil，否则为string错误内容
     - content: string, 请求结果

具体实例可查看ResScript中的脚本

## 反馈

编写脚本后可直接提交PR

如果有问题，创建issue或者联系我:
dx_8820832#yeah.net（#→@），或者加QQ群874761809反馈
