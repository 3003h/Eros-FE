import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EHConst {
  static const List settingList = [
    {"name": "eh", "title": "EH设置", "icon": CupertinoIcons.book_solid},
    {"name": "myTag", "title": "我的标签", "icon": CupertinoIcons.tags_solid},
    {"name": "download", "title": "下载设置", "icon": EHCupertinoIcons.download},
    {"name": "advans", "title": "高级设置", "icon": CupertinoIcons.gear_big},
    {"name": "about", "title": "关于", "icon": EHCupertinoIcons.info_solid},
  ];

  static const urls = {
    "default": "https://exhentai.org/",
    "homepage": "https://exhentai.org/",
    "watched": "https://exhentai.org/watched",
    "popular": "https://exhentai.org/popular",
    "favorites": "https://exhentai.org/favorites.php",
    "config": "https://exhentai.org/uconfig.php",
    "downloads": "downloads://index?page=0",
    "login": "https://forums.e-hentai.org/index.php?act=Login&CODE=01",
    "api": "https://exhentai.org/api.php",
    "gallerypopups": "https://exhentai.org/gallerypopups.php"
  };
}
