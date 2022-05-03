# KikoPlay脚本仓库
---
这里是KikoPlay的脚本仓库  
KikoPlay支持Lua脚本，有三种类型：
 - 弹幕脚本： 位于script/danmu目录下，提供弹幕搜索、下载、发送弹幕等功能
 - 资料脚本：位于script/library目录下，提供动画（或者其他类型的条目）搜索、详细信息获取、分集信息获取、标签获取、自动关联等功能
 - 资源脚本：位于script/resource目录下，提供资源搜索功能
 - 番组日历脚本：位于script/bgm_calendar，提供每日放送列表。0.8.2起新增

关于脚本开发的详细内容，请参考[KikoPlay脚本开发参考](reference.md)
## 反馈

有新脚本可直接提交PR

如果有问题，创建issue或者联系我:
dx_8820832#yeah.net（#→@），或者到QQ群874761809反馈

## 新脚本

 - [TMDb](library/tmdb.lua) 从[themoviedb.org](themoviedb.org)获取信息，具体用法参考[这里](https://github.com/kafovin/KikoPlayScript)
 - [TVmazeList](bgm_calendar/tvmazelist.lua) 从 tvmaze.com 刮削剧集的日历时间表，具体用法参考[这里](https://github.com/kafovin/KikoPlayScript)