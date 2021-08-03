# FEhViewer
English | [简体中文](https://github.com/honjow/FEhViewer/blob/nullsafety/README_cn.md)

[![](https://img.shields.io/github/downloads/honjow/FEhViewer/total.svg)](https://gitHub.com/honjow/FEhViewer/releases)
[![](https://img.shields.io/github/downloads/honjow/FEhViewer/latest/total)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/v/release/honjow/FEhViewer)](https://github.com/honjow/FEhViewer/releases/latest)
[![](https://img.shields.io/github/stars/honjow/FEhViewer)]()
[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/joinchat/AEj27KMQe0JiMmUx)
[![QQ](https://img.shields.io/badge/chat-QQ-blue.svg)](https://qm.qq.com/cgi-bin/qm/qr?k=fr6P5pYFbbdzh9djpE0QEMcX0sJd9ISj&jump_from=webapi)

## Introduction

An Unofficial e-hentai app make on flutter

## Descriptions

The main reference for UI is [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)

Because it is flutter, so it is also cross-platform support, the main platforms tested are \
iOS 14 : iPhone XR / 12 / iPad Pro 2018 \
Android 11 : MIUI12.5/ MI K40

Current Issues:

- List sliding may have a small lag. Not as smooth as native apps
- Does miss some essential features (still under development)

## Thanks

The code and logic of the following projects are used and referenced for development

- [E-HentaiViewer](https://github.com/kayanouriko/E-HentaiViewer)
- [EhViewer](https://github.com/seven332/EhViewer)

EhTagTranslation

- [EhTagTranslation/Database](https://github.com/EhTagTranslation/Database)

## Screenshot

### Home Page List

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.15.21.jpg" >

### Gallery

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.15.27.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.15.43.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.16.56.jpg" >

### Search

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.15.53.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.15.58.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.16.02.jpg" >

### Read

<img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.16.08.jpg" > <img width="200" src="https://raw.githubusercontent.com/honjow/FEhViewer/nullsafety/screenshot/2021-06-21%2019.54.50.jpg" >

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
Because the project introduces firebase, you need to place your own google-services.json file
