# FEhViewer
[English](https://github.com/honjow/FEhViewer/blob/master/README.md) | 简体中文

[![](https://img.shields.io/github/downloads/honjow/FEhViewer/total.svg)](https://gitHub.com/honjow/FEhViewer/releases)
[![](https://img.shields.io/github/downloads/honjow/FEhViewer/latest/total)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/v/release/honjow/FEhViewer)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/stars/honjow/FEhViewer)]()
[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/joinchat/AEj27KMQe0JiMmUx)
[![QQ](https://img.shields.io/badge/chat-QQ-blue.svg)](https://qm.qq.com/cgi-bin/qm/qr?k=fr6P5pYFbbdzh9djpE0QEMcX0sJd9ISj&jump_from=webapi)

## 应用简介

一个 flutter 编写的 e-hentai app

## iOS 安装
1. 下载最新 ipa 文件 [Releases](https://github.com/honjow/FEhViewer/releases/latest).
2. 使用 [AltStore](https://altstore.io) 之类的 app 安装到设备上. 或者直接使用 [AltStore.json](https://config-feh.vercel.app/AltStore.json)


## 说明

其实主要是想写给自己用，因为用的 ios，感觉现有的几个项目感觉不能满足自己的使用 \
然后对原生开发不咋熟悉，就起了用 flutter 自己搞一个的想法 \
就这样从入门到入土，有了现在的版本

UI 方面主要参考的[E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)

现有问题:

- 列表滑动可能会有小卡顿。没有原生应用那么流畅
- 确失一些必要功能(还在开发完善中)
- 里站连接体验不佳

## 感谢

应用借鉴和参考以下项目的部分代码和逻辑进行开发

- [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)
- [EhViewer](https://github.com/seven332/EhViewer)

ehentai译文数据库

- [EhTagTranslation/Database](https://github.com/EhTagTranslation/Database)

翻译
- [KeepSOBP](https://github.com/KeepSOBP) 韩语翻译

其它
- [xioxin](https://github.com/xioxin) Dio Domain Fronting 拦截器

## 应用截图

### 主页列表

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/home1.jpg" >

### 画廊

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery3.jpg" >

### 搜索

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search3.jpg" >

### 阅读

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/read1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/read2.jpg" >

## 功能

- [x] 热门,关注,主页,收藏
- [x] 自定义分组，组合多种条件，分组独立样式
- [x] 列表视图,瀑布流视图,网格视图等切换
- [x] 浅色深色模式
- [x] 画廊信息查看
- [x] 图片浏览
- [x] 自动翻页
- [x] 里站表站切换
- [x] 搜索，高级搜索，图片文件搜索
- [x] 标签翻译，自动匹配标签搜索
- [x] 用户登录
- [x] 缓存优化
- [x] 高级设置
- [x] 生物认证锁定
- [x] 发表评论，对评论赞和踩，评论翻译
- [x] 评论显示论坛头像，快速@回复(带锚点)，自动显示引用评论
- [x] EH设置，同步网站
- [x] Mytag设置，编辑关注、隐藏、颜色、权重等。长按Tag快速设置
- [x] Domain Fronting 域前置 支持直连，自定义hosts
- [x] 下载，下载原图，归档包下载，直接阅读已下载
- [x] WebDAV同步历史，快速搜索，阅读进度，分组配置
- [x] 可屏蔽带二维码的图片。可标记广告图片，记录pHash值，后续屏蔽相似图片


## TODO



## 依赖项目/插件（部分）

- 网络 [dio](https://pub.dev/packages/dio)
- 状态管理 [getx](https://pub.dev/packages/get)
- 数据库 [sqflite](https://pub.dev/packages/sqflite)
- 持久化 [shared_preferences](https://pub.dev/packages/shared_preferences)
- 国际化 [intl](https://pub.dev/packages/intl)
- 图片 [cached_network_image](https://pub.dev/packages/cached_network_image)、[extended_image](https://pub.dev/packages/extended_image)

## 编译相关

flutter版本为最新release版本 \
`/lib/config/config.dart` 文件为存放敏感信息数据的文件，github里看到是加密处理的 \
如果需要自行编译的话，复制 `/lib/config.dart.sample` 为 `/lib/config/config.dart` 进行操作
