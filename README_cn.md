# FEhViewer
[English](https://github.com/honjow/FEhViewer/blob/nullsafety/README.md) | 简体中文

[![](https://img.shields.io/github/downloads/honjow/FEhViewer/total.svg)](https://gitHub.com/honjow/FEhViewer/releases)
[![](https://img.shields.io/github/downloads/honjow/FEhViewer/latest/total)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/v/release/honjow/FEhViewer)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/stars/honjow/FEhViewer)]()
[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/joinchat/AEj27KMQe0JiMmUx)
[![QQ](https://img.shields.io/badge/chat-QQ-blue.svg)](https://qm.qq.com/cgi-bin/qm/qr?k=fr6P5pYFbbdzh9djpE0QEMcX0sJd9ISj&jump_from=webapi)

## 应用简介

一个 flutter 编写的 e-hentai app

## 说明

其实主要是想写给自己用，因为用的 ios，感觉现有的几个项目感觉不能满足自己的使用 \
然后对原生开发不咋熟悉，就起了用 flutter 自己搞一个的想法 \
就这样从入门到入土，有了现在的版本，虽然问题还缺失的功能还不少。但至少是个能看的版本了

UI 方面主要参考的[E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)

因为是 flutter 所以也是跨平台支持的，测试的平台主要有 \
iOS 14 : iPhone XR / 12 / iPad Pro 2018 \
Android 11 : MIUI12.5/ MI K40

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

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/home1.jpg" >

### 画廊

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/gallery1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/gallery2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/gallery3.jpg" >

### 搜索

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/search1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/search2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/search3.jpg" >

### 阅读

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/read1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/read2.jpg" >

## 功能

- [x] 热门,关注,主页,收藏
- [x] 列表视图,瀑布流视图切换
- [x] 画廊信息查看
- [x] 图片浏览
- [x] 自动翻页
- [x] 里站表站切换
- [x] 标签搜索
- [x] 登录
- [x] 搜索
- [x] 搜索词匹配tag
- [x] 高级搜索
- [x] 单张图片保存于与分享
- [x] 缓存优化
- [x] 高级设置
- [x] 发表评论 赞和踩
- [x] watched 和用户 tag
- [x] Domain Fronting 域前置 支持直连， 自定义hosts
- [x] 下载


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
因项目引入 firebase, 需要放置自己的google-services.json文件等 \
或者直接去掉 firebase 相关功能
