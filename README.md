# FEhViewer

# 应用简介

一个用 flutter 编写的 e-hentai/exhentai app

# 说明

其实主要是想写给自己用，因为用的 ios，没有现有的几个项目感觉不能满足自己的使用 \
然后对原生开发不咋熟悉，就起了用 flutter 自己搞一个的想法 \
就这样从入门到入土，折腾一个多月有了现在的版本，虽然问题还缺失的功能还不少。但至少是个能看的版本了

UI 界面方面不少都参考的[E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)\
所以一眼看过去比较像，毕竟之前主要用的都是它

因为是 flutter 所以也是跨平台支持的，测试的平台主要有\
iOS 14 : iPhone XR / iPad Pro 2018\
Android 10 : MIUI12/ MI K30

现有问题:

- 画廊图片大图浏览时不会预下载，只能切换到那张才下载（水平不行还在像想办法做这个功能）
- 可能会有卡顿。没有原生应用那么流畅
- 确失一些必要功能(还在开发中)

# 感谢

应用借鉴和参考以下项目的部分代码和逻辑进行开发

- [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)
- [EhViewer](https://github.com/seven332/EhViewer)

ehentai 标签汉化项目

- [EhTagTranslator](https://github.com/Mapaler/EhTagTranslator)

# 应用截图

![fehv-w50](https://i.loli.net/2020/07/30/YnpIjzJDQ7mRg53.png)

# 功能

- [x] 热门,列表画廊,收藏浏览
- [x] 画廊信息查看
- [x] 图片浏览（其实还有问题，但是能大概看了）
- [x] 里站表站切换
- [x] 标签搜索
- [x] 登录

# TODO

- [ ] 搜索/高级搜索
- [ ] 评论
- [ ] 缓存优化
- [ ] 高级设置
- [ ] watched 和用户 tag
- [ ] 下载功能

# 依赖项目/插件（部分）

- 网络 [dio](https://pub.dev/packages/dio)
- 状态管理 [provider](https://pub.dev/packages/provider)
- 数据库 [sqflite](https://pub.dev/packages/sqflite)
- 持久化 [shared_preferences](https://pub.dev/packages/shared_preferences)
- 国际化 [intl](https://pub.dev/packages/intl)
- 图片 [cached_network_image](https://pub.dev/packages/cached_network_image)、[extended_image](https://pub.dev/packages/extended_image)
