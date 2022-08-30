# FEhViewer
English | [简体中文](https://github.com/honjow/FEhViewer/blob/master/README_cn.md)

[![](https://img.shields.io/github/downloads/honjow/FEhViewer/total.svg)](https://gitHub.com/honjow/FEhViewer/releases)
[![](https://img.shields.io/github/downloads/honjow/FEhViewer/latest/total)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/v/release/honjow/FEhViewer)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/stars/honjow/FEhViewer)]()
[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/joinchat/AEj27KMQe0JiMmUx)
[![QQ](https://img.shields.io/badge/chat-QQ-blue.svg)](https://qm.qq.com/cgi-bin/qm/qr?k=fr6P5pYFbbdzh9djpE0QEMcX0sJd9ISj&jump_from=webapi)

## Introduction

An Unofficial e-hentai app make on flutter

## 🔍 Translations Wanted 🔍
Please submit a pull request if you want to help with translation.

App Strings: `lib/l10n/{lang}.arb`

## Installation for iOS
1. Get the ipa file from [Releases](https://github.com/honjow/FEhViewer/releases/latest).
2. Use some software like [AltStore](https://altstore.io) to install the ipa file on your device. Or [AltStore.json](https://config-feh.vercel.app/AltStore.json)

## Descriptions

The main reference for UI is [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)

Current Issues:

- List sliding may have a small lag. Not as smooth as native apps
- Does miss some essential features (still under development)

## Thanks

The code and logic of the following projects are used and referenced for development

- [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)
- [EhViewer](https://github.com/seven332/EhViewer)

EhTagTranslation

- [EhTagTranslation/Database](https://github.com/EhTagTranslation/Database)

Translation
- [KeepSOBP](https://github.com/KeepSOBP) Korean translation
- [pursel](https://github.com/pursel), [Gigas002](https://github.com/Gigas002) -- Russian translation

## Screenshot

### Home Page List

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/home1.jpg" >

### Gallery

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/gallery3.jpg" >

### Search

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search2.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/search3.jpg" >

### Read

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/read1.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/master/screenshot/read2.jpg" >

## Function

- [x] Popula,Watch,Home,Favorites
- [x] List View,Waterfall View Switch
- [x] Gallery information view
- [x] Gallery Image view
- [x] Automatically turn pages
- [x] eh/ex switch
- [x] Tag search
- [x] Login
- [x] Search
- [x] Search term matching tag
- [x] Advanced search
- [x] Save and share images
- [x] Cache optimization
- [x] Advanced settings
- [x] post comments, vote up ，vote down
- [x] watched and user tag
- [x] Download

## TODO


## Dependency projects/plugins (partial)

- network: [dio](https://pub.dev/packages/dio)
- Status Management: [getx](https://pub.dev/packages/get)
- db: [sqflite](https://pub.dev/packages/sqflite)
- Data Persistence: [shared_preferences](https://pub.dev/packages/shared_preferences)
- intl: [intl](https://pub.dev/packages/intl)
- Image: [cached_network_image](https://pub.dev/packages/cached_network_image)、[extended_image](https://pub.dev/packages/extended_image)

## About compiling

flutter version is the latest release version \
rename `/lib/config/config.dart.sample` to `/lib/config/config.dart`