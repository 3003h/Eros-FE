// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(site) => "当前 ${site}";

  static String m1(modelName) => "模式 ${modelName}";

  static String m2(rating) => "${rating} ⭐";

  static String m3(tagNamespace) => "${Intl.select(tagNamespace, {
            'reclass': '重新分类',
            'language': '语言',
            'parody': '原作',
            'character': '角色',
            'group': '社团',
            'artist': '艺术家',
            'male': '男性',
            'female': '女性',
            'mixed': '混杂',
            'cosplayer': '扮演者',
            'other': '其它',
            'temp': '临时',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "KEEP_IT_SAFE": MessageLookupByLibrary.simpleMessage("注意数据安全"),
        "QR_code_check": MessageLookupByLibrary.simpleMessage("二维码检查"),
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "add_quick_search": MessageLookupByLibrary.simpleMessage("添加搜索"),
        "add_tag_placeholder":
            MessageLookupByLibrary.simpleMessage("输入新标签, 用逗号分隔"),
        "add_tags": MessageLookupByLibrary.simpleMessage("添加标签"),
        "add_to_favorites": MessageLookupByLibrary.simpleMessage("添加收藏夹"),
        "advanced": MessageLookupByLibrary.simpleMessage("高级"),
        "aggregate": MessageLookupByLibrary.simpleMessage("聚合"),
        "aggregate_groups": MessageLookupByLibrary.simpleMessage("聚合分组"),
        "all_Favorites": MessageLookupByLibrary.simpleMessage("所有收藏"),
        "all_comment": MessageLookupByLibrary.simpleMessage("所有评论"),
        "all_preview": MessageLookupByLibrary.simpleMessage("所有预览"),
        "allow_media_scan": MessageLookupByLibrary.simpleMessage("允许媒体扫描"),
        "always": MessageLookupByLibrary.simpleMessage("始终"),
        "app_title": MessageLookupByLibrary.simpleMessage("FEhViewer"),
        "ask_me": MessageLookupByLibrary.simpleMessage("询问"),
        "auth_biometricHint": MessageLookupByLibrary.simpleMessage("验证身份"),
        "auth_signInTitle": MessageLookupByLibrary.simpleMessage("需要进行身份验证"),
        "author": MessageLookupByLibrary.simpleMessage("作者"),
        "autoLock": MessageLookupByLibrary.simpleMessage("自动锁定"),
        "auto_select_profile": MessageLookupByLibrary.simpleMessage("自动选择配置"),
        "avatar": MessageLookupByLibrary.simpleMessage("头像"),
        "back": MessageLookupByLibrary.simpleMessage("返回"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "change_to_favorites": MessageLookupByLibrary.simpleMessage("修改收藏夹"),
        "chapter": MessageLookupByLibrary.simpleMessage("章节"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("清除缓存"),
        "clear_filter": MessageLookupByLibrary.simpleMessage("重置"),
        "clear_search_history": MessageLookupByLibrary.simpleMessage("清空搜索历史"),
        "clipboard_detection": MessageLookupByLibrary.simpleMessage("剪贴板检测"),
        "clipboard_detection_desc":
            MessageLookupByLibrary.simpleMessage("自动检测剪贴板画廊链接"),
        "collapse": MessageLookupByLibrary.simpleMessage("折叠"),
        "color_picker_primary": MessageLookupByLibrary.simpleMessage("基本"),
        "color_picker_wheel": MessageLookupByLibrary.simpleMessage("色盘"),
        "copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "current_site": m0,
        "current_version": MessageLookupByLibrary.simpleMessage("当前版本"),
        "custom_hosts": MessageLookupByLibrary.simpleMessage("自定义hosts"),
        "dark": MessageLookupByLibrary.simpleMessage("深色模式"),
        "dark_mode_effect": MessageLookupByLibrary.simpleMessage("深色模式效果"),
        "default_avatar_style": MessageLookupByLibrary.simpleMessage("默认头像样式"),
        "default_favorites": MessageLookupByLibrary.simpleMessage("默认收藏夹设置"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "delete_task": MessageLookupByLibrary.simpleMessage("删除任务"),
        "delete_task_and_content":
            MessageLookupByLibrary.simpleMessage("删除任务和下载内容"),
        "delete_task_only": MessageLookupByLibrary.simpleMessage("仅删除任务"),
        "disabled": MessageLookupByLibrary.simpleMessage("停用"),
        "domain_fronting": MessageLookupByLibrary.simpleMessage("域名前置"),
        "donate": MessageLookupByLibrary.simpleMessage("捐赠"),
        "done": MessageLookupByLibrary.simpleMessage("完成"),
        "double_click_back": MessageLookupByLibrary.simpleMessage("再按一次返回退出"),
        "double_page_model": MessageLookupByLibrary.simpleMessage("双页模式"),
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "download_location": MessageLookupByLibrary.simpleMessage("下载路径"),
        "download_ori_image": MessageLookupByLibrary.simpleMessage("下载原图"),
        "download_ori_image_summary":
            MessageLookupByLibrary.simpleMessage("危险! 会导致下载配额迅速流失, 出现 509 错误"),
        "downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "downloading": MessageLookupByLibrary.simpleMessage("下载中"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "edit_comment": MessageLookupByLibrary.simpleMessage("编辑评论"),
        "eh": MessageLookupByLibrary.simpleMessage("E·H"),
        "ehentai_my_tags": MessageLookupByLibrary.simpleMessage("我的标签"),
        "ehentai_settings": MessageLookupByLibrary.simpleMessage("EHentai 设置"),
        "expand": MessageLookupByLibrary.simpleMessage("展开"),
        "export": MessageLookupByLibrary.simpleMessage("导出"),
        "favcat": MessageLookupByLibrary.simpleMessage("收藏夹"),
        "favorites_order": MessageLookupByLibrary.simpleMessage("收藏夹排序"),
        "favorites_order_Use_favorited":
            MessageLookupByLibrary.simpleMessage("按照收藏时间"),
        "favorites_order_Use_posted":
            MessageLookupByLibrary.simpleMessage("按照发布时间"),
        "fixed_height_of_list_items":
            MessageLookupByLibrary.simpleMessage("固定列表项高度"),
        "follow_system": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "fullscreen": MessageLookupByLibrary.simpleMessage("全屏"),
        "galery_site": MessageLookupByLibrary.simpleMessage("画廊站点"),
        "gallery_comments": MessageLookupByLibrary.simpleMessage("画廊评论"),
        "global_setting": MessageLookupByLibrary.simpleMessage("全局设置"),
        "gray_black": MessageLookupByLibrary.simpleMessage("灰黑"),
        "group": MessageLookupByLibrary.simpleMessage("分组"),
        "groupName": MessageLookupByLibrary.simpleMessage("分组名称"),
        "groupType": MessageLookupByLibrary.simpleMessage("类型"),
        "hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "hours": MessageLookupByLibrary.simpleMessage("小时"),
        "image_download_type": MessageLookupByLibrary.simpleMessage("下载类型"),
        "image_hide": MessageLookupByLibrary.simpleMessage("图片隐藏"),
        "image_limits": MessageLookupByLibrary.simpleMessage("图片限制"),
        "input_empty": MessageLookupByLibrary.simpleMessage("输入空"),
        "input_error": MessageLookupByLibrary.simpleMessage("输入格式有误"),
        "instantly": MessageLookupByLibrary.simpleMessage("立即"),
        "jump_to_page": MessageLookupByLibrary.simpleMessage("页面跳转"),
        "language": MessageLookupByLibrary.simpleMessage("语言设置"),
        "last_favorites": MessageLookupByLibrary.simpleMessage("使用上次选择，长按选择其他"),
        "left_to_right": MessageLookupByLibrary.simpleMessage("从左到右"),
        "license": MessageLookupByLibrary.simpleMessage("开源许可"),
        "light": MessageLookupByLibrary.simpleMessage("浅色模式"),
        "link_redirect": MessageLookupByLibrary.simpleMessage("链接重定向"),
        "link_redirect_summary":
            MessageLookupByLibrary.simpleMessage("将画廊链接重定向到选定的站点"),
        "list_load_more_fail":
            MessageLookupByLibrary.simpleMessage("加载失败, 点击重试"),
        "list_mode": MessageLookupByLibrary.simpleMessage("列表样式"),
        "listmode_grid": MessageLookupByLibrary.simpleMessage("网格"),
        "listmode_medium": MessageLookupByLibrary.simpleMessage("列表 - 中"),
        "listmode_small": MessageLookupByLibrary.simpleMessage("列表 - 小"),
        "listmode_waterfall": MessageLookupByLibrary.simpleMessage("瀑布流"),
        "listmode_waterfall_large":
            MessageLookupByLibrary.simpleMessage("瀑布流 - 大"),
        "loading": MessageLookupByLibrary.simpleMessage("载入中"),
        "local_favorite": MessageLookupByLibrary.simpleMessage("本地收藏"),
        "login": MessageLookupByLibrary.simpleMessage("登录"),
        "login_web": MessageLookupByLibrary.simpleMessage("通过网页登录"),
        "mange_hidden_images": MessageLookupByLibrary.simpleMessage("管理隐藏图片"),
        "manually_sel_favorites": MessageLookupByLibrary.simpleMessage("手动选择"),
        "max_history": MessageLookupByLibrary.simpleMessage("最大历史记录"),
        "min": MessageLookupByLibrary.simpleMessage("分钟"),
        "model": m1,
        "morePreviews": MessageLookupByLibrary.simpleMessage("更多预览"),
        "multi_download": MessageLookupByLibrary.simpleMessage("同时下载图片数量"),
        "mytags_on_website": MessageLookupByLibrary.simpleMessage("网页上的标签设置"),
        "newGroup": MessageLookupByLibrary.simpleMessage("新建分组"),
        "newText": MessageLookupByLibrary.simpleMessage("新关键词"),
        "new_comment": MessageLookupByLibrary.simpleMessage("发布新评论"),
        "no": MessageLookupByLibrary.simpleMessage("不"),
        "noMorePreviews": MessageLookupByLibrary.simpleMessage("无更多预览"),
        "notFav": MessageLookupByLibrary.simpleMessage("未收藏"),
        "not_login": MessageLookupByLibrary.simpleMessage("未登录"),
        "off": MessageLookupByLibrary.simpleMessage("关闭"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "on": MessageLookupByLibrary.simpleMessage("打开"),
        "open_supported_links": MessageLookupByLibrary.simpleMessage("打开支持的链接"),
        "open_supported_links_summary": MessageLookupByLibrary.simpleMessage(
            "从 Android 12 开始, 应用只有在获得批准的情况下，才能作为网络链接的处理应用。否则会使用默认浏览器处理。您可以在此手动批准"),
        "open_with_other_apps": MessageLookupByLibrary.simpleMessage("其他应用打开"),
        "orientation_auto": MessageLookupByLibrary.simpleMessage("自动旋转"),
        "orientation_landscapeLeft":
            MessageLookupByLibrary.simpleMessage("横屏(左)"),
        "orientation_landscapeRight":
            MessageLookupByLibrary.simpleMessage("横屏(右)"),
        "orientation_portraitUp": MessageLookupByLibrary.simpleMessage("竖屏"),
        "orientation_system": MessageLookupByLibrary.simpleMessage("系统默认"),
        "original_image": MessageLookupByLibrary.simpleMessage("原图"),
        "p_Archiver": MessageLookupByLibrary.simpleMessage("归档"),
        "p_Download": MessageLookupByLibrary.simpleMessage("下载"),
        "p_Rate": MessageLookupByLibrary.simpleMessage("评分"),
        "p_Similar": MessageLookupByLibrary.simpleMessage("相似"),
        "p_Torrent": MessageLookupByLibrary.simpleMessage("种子"),
        "page_range": MessageLookupByLibrary.simpleMessage("跳转范围"),
        "page_range_error": MessageLookupByLibrary.simpleMessage("输入范围有误"),
        "passwd": MessageLookupByLibrary.simpleMessage("密码"),
        "paused": MessageLookupByLibrary.simpleMessage("已暂停"),
        "phash_check": MessageLookupByLibrary.simpleMessage("感知哈希检查"),
        "pls_i_passwd": MessageLookupByLibrary.simpleMessage("请输入密码"),
        "pls_i_username": MessageLookupByLibrary.simpleMessage("请输入用户名"),
        "preload_image": MessageLookupByLibrary.simpleMessage("预载图片数量"),
        "previews": MessageLookupByLibrary.simpleMessage("预览"),
        "processing": MessageLookupByLibrary.simpleMessage("处理中"),
        "pure_black": MessageLookupByLibrary.simpleMessage("纯黑"),
        "quick_search": MessageLookupByLibrary.simpleMessage("快速搜索"),
        "read": MessageLookupByLibrary.simpleMessage("阅读"),
        "read_from_clipboard": MessageLookupByLibrary.simpleMessage("从剪贴板读取"),
        "read_setting": MessageLookupByLibrary.simpleMessage("阅读设置"),
        "reading_direction": MessageLookupByLibrary.simpleMessage("阅读方向"),
        "rebuild_tasks_data": MessageLookupByLibrary.simpleMessage("重建下载任务数据"),
        "redownload": MessageLookupByLibrary.simpleMessage("重新下载"),
        "reload_image": MessageLookupByLibrary.simpleMessage("重新载入图片"),
        "remove_from_favorites":
            MessageLookupByLibrary.simpleMessage("从收藏夹中删除"),
        "reply_to_comment": MessageLookupByLibrary.simpleMessage("回复"),
        "resample_image": MessageLookupByLibrary.simpleMessage("重采样图片"),
        "reset_cost": MessageLookupByLibrary.simpleMessage("重置花费"),
        "restore_tasks_data": MessageLookupByLibrary.simpleMessage("恢复下载任务数据"),
        "right_to_left": MessageLookupByLibrary.simpleMessage("从右到左"),
        "s_Advanced_Options": MessageLookupByLibrary.simpleMessage("高级选项"),
        "s_Between": MessageLookupByLibrary.simpleMessage("从"),
        "s_Disable_default_filters":
            MessageLookupByLibrary.simpleMessage("禁用默认排除选项"),
        "s_Minimum_Rating": MessageLookupByLibrary.simpleMessage("最低评分"),
        "s_Only_Show_Galleries_With_Torrents":
            MessageLookupByLibrary.simpleMessage("仅显示有种子的画廊"),
        "s_Search_Downvoted_Tags":
            MessageLookupByLibrary.simpleMessage("搜索差评标签"),
        "s_Search_Fav_Name": MessageLookupByLibrary.simpleMessage("搜索名称"),
        "s_Search_Fav_Note": MessageLookupByLibrary.simpleMessage("搜索标注"),
        "s_Search_Fav_Tags": MessageLookupByLibrary.simpleMessage("搜索标签"),
        "s_Search_Gallery_Description":
            MessageLookupByLibrary.simpleMessage("搜索画廊描述"),
        "s_Search_Gallery_Name": MessageLookupByLibrary.simpleMessage("搜索画廊名字"),
        "s_Search_Gallery_Tags": MessageLookupByLibrary.simpleMessage("搜索画廊标签"),
        "s_Search_Low_Power_Tags":
            MessageLookupByLibrary.simpleMessage("搜索低愿力标签"),
        "s_Search_Torrent_Filenames":
            MessageLookupByLibrary.simpleMessage("搜索种子名字"),
        "s_Show_Expunged_Galleries":
            MessageLookupByLibrary.simpleMessage("搜索被删除的画廊"),
        "s_and": MessageLookupByLibrary.simpleMessage("到"),
        "s_pages": MessageLookupByLibrary.simpleMessage("页数"),
        "s_stars": m2,
        "save_into_album": MessageLookupByLibrary.simpleMessage("保存到相册"),
        "saved_successfully": MessageLookupByLibrary.simpleMessage("保存成功"),
        "screen_orientation": MessageLookupByLibrary.simpleMessage("屏幕方向"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "searchTexts": MessageLookupByLibrary.simpleMessage("搜索关键词"),
        "search_history": MessageLookupByLibrary.simpleMessage("搜索历史"),
        "search_type": MessageLookupByLibrary.simpleMessage("搜索类型"),
        "second": MessageLookupByLibrary.simpleMessage("秒"),
        "security": MessageLookupByLibrary.simpleMessage("安全"),
        "security_blurredInRecentTasks":
            MessageLookupByLibrary.simpleMessage("最近任务中模糊处理"),
        "setting_on_website": MessageLookupByLibrary.simpleMessage("网页上的设置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "share_image": MessageLookupByLibrary.simpleMessage("分享图片"),
        "show_comment_avatar": MessageLookupByLibrary.simpleMessage("显示评论头像"),
        "show_filter": MessageLookupByLibrary.simpleMessage("显示筛选"),
        "show_jpn_title": MessageLookupByLibrary.simpleMessage("显示日文标题"),
        "show_page_interval": MessageLookupByLibrary.simpleMessage("显示页面间隔"),
        "skip": MessageLookupByLibrary.simpleMessage("跳过"),
        "sync_group": MessageLookupByLibrary.simpleMessage("同步分组"),
        "sync_history": MessageLookupByLibrary.simpleMessage("同步历史记录"),
        "sync_quick_search": MessageLookupByLibrary.simpleMessage("同步快速搜索"),
        "sync_read_progress": MessageLookupByLibrary.simpleMessage("同步阅读进度"),
        "system_share": MessageLookupByLibrary.simpleMessage("系统分享"),
        "t_Clear_all_history": MessageLookupByLibrary.simpleMessage("清除所有历史"),
        "tab_download": MessageLookupByLibrary.simpleMessage("下载"),
        "tab_favorite": MessageLookupByLibrary.simpleMessage("收藏"),
        "tab_gallery": MessageLookupByLibrary.simpleMessage("画廊"),
        "tab_history": MessageLookupByLibrary.simpleMessage("历史"),
        "tab_popular": MessageLookupByLibrary.simpleMessage("热门"),
        "tab_setting": MessageLookupByLibrary.simpleMessage("设置"),
        "tab_sort": MessageLookupByLibrary.simpleMessage("长按并拖动以进行排序"),
        "tab_toplist": MessageLookupByLibrary.simpleMessage("排行"),
        "tab_watched": MessageLookupByLibrary.simpleMessage("订阅"),
        "tabbar_setting": MessageLookupByLibrary.simpleMessage("主页标签设置"),
        "tablet_layout": MessageLookupByLibrary.simpleMessage("平板布局"),
        "tagNamespace": m3,
        "tag_add_to_mytag": MessageLookupByLibrary.simpleMessage("添加到我的标签"),
        "tag_dialog_Default_color":
            MessageLookupByLibrary.simpleMessage("默认颜色"),
        "tag_dialog_Hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "tag_dialog_TagColor": MessageLookupByLibrary.simpleMessage("标签颜色"),
        "tag_dialog_Watch": MessageLookupByLibrary.simpleMessage("订阅"),
        "tag_dialog_tagWeight": MessageLookupByLibrary.simpleMessage("标签权重"),
        "tag_vote_down": MessageLookupByLibrary.simpleMessage("投反对票"),
        "tag_vote_up": MessageLookupByLibrary.simpleMessage("投赞成票"),
        "tag_withdraw_vote": MessageLookupByLibrary.simpleMessage("撤销投票"),
        "tags": MessageLookupByLibrary.simpleMessage("标签"),
        "tap_to_turn_page_anima":
            MessageLookupByLibrary.simpleMessage("点击翻页动画"),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "tolist_alltime": MessageLookupByLibrary.simpleMessage("总排行"),
        "tolist_past_month": MessageLookupByLibrary.simpleMessage("月排行"),
        "tolist_past_year": MessageLookupByLibrary.simpleMessage("年排行"),
        "tolist_yesterday": MessageLookupByLibrary.simpleMessage("日排行"),
        "top_to_bottom": MessageLookupByLibrary.simpleMessage("从上到下"),
        "uc_Chinese": MessageLookupByLibrary.simpleMessage("汉语"),
        "uc_Dutch": MessageLookupByLibrary.simpleMessage("荷兰语"),
        "uc_English": MessageLookupByLibrary.simpleMessage("英语"),
        "uc_French": MessageLookupByLibrary.simpleMessage("法语"),
        "uc_German": MessageLookupByLibrary.simpleMessage("德语"),
        "uc_Hungarian": MessageLookupByLibrary.simpleMessage("匈牙利语"),
        "uc_Italian": MessageLookupByLibrary.simpleMessage("意大利语"),
        "uc_Japanese": MessageLookupByLibrary.simpleMessage("日语"),
        "uc_Korean": MessageLookupByLibrary.simpleMessage("韩语"),
        "uc_NA": MessageLookupByLibrary.simpleMessage("无语言"),
        "uc_Original": MessageLookupByLibrary.simpleMessage("原始"),
        "uc_Other": MessageLookupByLibrary.simpleMessage("其他"),
        "uc_Polish": MessageLookupByLibrary.simpleMessage("波兰语"),
        "uc_Portuguese": MessageLookupByLibrary.simpleMessage("葡萄牙语"),
        "uc_Rewrite": MessageLookupByLibrary.simpleMessage("重写"),
        "uc_Russian": MessageLookupByLibrary.simpleMessage("俄语"),
        "uc_Spanish": MessageLookupByLibrary.simpleMessage("西班牙语"),
        "uc_Thai": MessageLookupByLibrary.simpleMessage("泰语"),
        "uc_Translated": MessageLookupByLibrary.simpleMessage("翻译"),
        "uc_Vietnamese": MessageLookupByLibrary.simpleMessage("越南语"),
        "uc_ar_0": MessageLookupByLibrary.simpleMessage("手动选择，手动下载（默认）"),
        "uc_ar_1": MessageLookupByLibrary.simpleMessage("手动选择，自动下载"),
        "uc_ar_2": MessageLookupByLibrary.simpleMessage("自动选择原始画质，手动下载"),
        "uc_ar_3": MessageLookupByLibrary.simpleMessage("自动选择原始画质，自动下载"),
        "uc_ar_4": MessageLookupByLibrary.simpleMessage("自动选择压缩画质，手动下载"),
        "uc_ar_5": MessageLookupByLibrary.simpleMessage("自动选择压缩画质，自动下载"),
        "uc_archiver_desc": MessageLookupByLibrary.simpleMessage(
            "默认归档下载方式为手动选择（原画质或压缩画质），然后手动复制或点击下载链接。你可以修改归档下载方式。"),
        "uc_archiver_set": MessageLookupByLibrary.simpleMessage("归档设置"),
        "uc_artist": MessageLookupByLibrary.simpleMessage("艺术家"),
        "uc_auto": MessageLookupByLibrary.simpleMessage("自动"),
        "uc_character": MessageLookupByLibrary.simpleMessage("角色"),
        "uc_comments_show_votes": MessageLookupByLibrary.simpleMessage("显示投票数"),
        "uc_comments_sort_order": MessageLookupByLibrary.simpleMessage("排序方式"),
        "uc_crt_profile": MessageLookupByLibrary.simpleMessage("新建"),
        "uc_cs_0": MessageLookupByLibrary.simpleMessage("最早的评论"),
        "uc_cs_1": MessageLookupByLibrary.simpleMessage("最新的评论"),
        "uc_cs_2": MessageLookupByLibrary.simpleMessage("最高分的评论"),
        "uc_del_profile": MessageLookupByLibrary.simpleMessage("删除配置"),
        "uc_dm_0": MessageLookupByLibrary.simpleMessage("紧凑"),
        "uc_dm_1": MessageLookupByLibrary.simpleMessage("缩略图"),
        "uc_dm_2": MessageLookupByLibrary.simpleMessage("扩展"),
        "uc_dm_3": MessageLookupByLibrary.simpleMessage("最小化"),
        "uc_dm_4": MessageLookupByLibrary.simpleMessage("最小化+订阅标签"),
        "uc_exc_lang": MessageLookupByLibrary.simpleMessage("排除语言"),
        "uc_exc_lang_desc": MessageLookupByLibrary.simpleMessage(
            "如果您希望以图库列表中的某些语言隐藏图库并进行搜索，请从下面的列表中选择它们。\n请注意，无论搜索查询如何，匹配的图库都不会出现。"),
        "uc_exc_up": MessageLookupByLibrary.simpleMessage("屏蔽的上传者"),
        "uc_exc_up_desc": MessageLookupByLibrary.simpleMessage(
            "如果你希望在图库中和搜索中隐藏某个上传者的话，请把他们的用户名填写在上方，每行一个。\n注意：无论你如何搜索，这些上传者都不会出现。"),
        "uc_fav": MessageLookupByLibrary.simpleMessage("收藏"),
        "uc_fav_sort": MessageLookupByLibrary.simpleMessage("默认排序"),
        "uc_fav_sort_desc": MessageLookupByLibrary.simpleMessage(
            "请注意，2016 年 3 月改版之前加入收藏夹的图库并未保存收藏时间，会以图库发布时间代替。"),
        "uc_female": MessageLookupByLibrary.simpleMessage("女性"),
        "uc_front_page": MessageLookupByLibrary.simpleMessage("首页设置"),
        "uc_front_page_dis_mode":
            MessageLookupByLibrary.simpleMessage("首页显示样式"),
        "uc_fs_0": MessageLookupByLibrary.simpleMessage("按最新更新时间排序"),
        "uc_fs_1": MessageLookupByLibrary.simpleMessage("按收藏时间排序"),
        "uc_gallery_comments": MessageLookupByLibrary.simpleMessage("图库评论"),
        "uc_group": MessageLookupByLibrary.simpleMessage("社团"),
        "uc_hath_local_host":
            MessageLookupByLibrary.simpleMessage("Hentai@Home 本地网络服务器"),
        "uc_hath_local_host_desc": MessageLookupByLibrary.simpleMessage(
            "    如果你本地安装了 H@H 客户端，本地 IP 与浏览网站的公共 IP 相同，一些路由器不支持回流导致无法访问到自己，你可以设置这里来解决。\n    如果在同一台电脑上访问网站和运行客户端，请使用本地回环地址（127.0.0.1:端口号）。如果客户端在网络上的其他计算机运行，请使用那台机器的内网 IP。某些浏览器的配置可能阻止外部网站访问本地网络，你必须将网站列入白名单才能工作。"),
        "uc_img_cussize_desc": MessageLookupByLibrary.simpleMessage(
            "虽然图片会自动根据窗口缩小，你也可以手动设置最大大小，图片并没有重新采样（0 为不限制）"),
        "uc_img_horiz": MessageLookupByLibrary.simpleMessage("宽/横向"),
        "uc_img_load_setting": MessageLookupByLibrary.simpleMessage("图片加载设置"),
        "uc_img_size_setting": MessageLookupByLibrary.simpleMessage("图片大小设置"),
        "uc_img_vert": MessageLookupByLibrary.simpleMessage("高/纵向"),
        "uc_ip_addr_port":
            MessageLookupByLibrary.simpleMessage("IP Address:Port"),
        "uc_language": MessageLookupByLibrary.simpleMessage("语言"),
        "uc_lt_0":
            MessageLookupByLibrary.simpleMessage("鼠标悬停时 (页面加载快，缩略图加载有延迟)"),
        "uc_lt_0_s": MessageLookupByLibrary.simpleMessage("鼠标悬停时"),
        "uc_lt_1": MessageLookupByLibrary.simpleMessage(
            "页面加载时 (页面加载时间更长，但是显示的时候无需等待)"),
        "uc_lt_1_s": MessageLookupByLibrary.simpleMessage("页面加载时"),
        "uc_male": MessageLookupByLibrary.simpleMessage("男性"),
        "uc_mose_over_thumb": MessageLookupByLibrary.simpleMessage("缩略图何时加载"),
        "uc_mpv": MessageLookupByLibrary.simpleMessage("多页查看器"),
        "uc_mpv_always": MessageLookupByLibrary.simpleMessage("总是使用"),
        "uc_mpv_stype": MessageLookupByLibrary.simpleMessage("显示样式"),
        "uc_mpv_thumb_pane": MessageLookupByLibrary.simpleMessage("缩略图侧栏"),
        "uc_ms_0": MessageLookupByLibrary.simpleMessage("左对齐\n仅当图像大于浏览器宽度时缩放"),
        "uc_ms_1": MessageLookupByLibrary.simpleMessage("居中对齐\n仅当图像大于浏览器宽度时缩放"),
        "uc_ms_2": MessageLookupByLibrary.simpleMessage("居中对齐\n始终缩放图像以适应浏览器宽度"),
        "uc_mt_0": MessageLookupByLibrary.simpleMessage("显示"),
        "uc_mt_1": MessageLookupByLibrary.simpleMessage("隐藏"),
        "uc_name_display": MessageLookupByLibrary.simpleMessage("图库的名字显示"),
        "uc_name_display_desc": MessageLookupByLibrary.simpleMessage(
            "很多图库都同时拥有英文或者日文标题，你想默认显示哪一个？"),
        "uc_oi_0": MessageLookupByLibrary.simpleMessage("否"),
        "uc_oi_1": MessageLookupByLibrary.simpleMessage("好的，我可以接受更多的配额消耗"),
        "uc_ori_image": MessageLookupByLibrary.simpleMessage("原始图像"),
        "uc_ori_image_desc":
            MessageLookupByLibrary.simpleMessage("当可用的时候，使用原始图像代替压缩过的版本?"),
        "uc_parody": MessageLookupByLibrary.simpleMessage("原作"),
        "uc_pixels": MessageLookupByLibrary.simpleMessage("像素"),
        "uc_pn_0": MessageLookupByLibrary.simpleMessage("否"),
        "uc_pn_1": MessageLookupByLibrary.simpleMessage("是"),
        "uc_profile": MessageLookupByLibrary.simpleMessage("配置"),
        "uc_qb_0": MessageLookupByLibrary.simpleMessage("否"),
        "uc_qb_1": MessageLookupByLibrary.simpleMessage("是"),
        "uc_rating": MessageLookupByLibrary.simpleMessage("评分颜色"),
        "uc_rating_desc": MessageLookupByLibrary.simpleMessage(
            "默认设置下，你评为 2 星及以下的图库显示为红星，2.5 ~ 4 星显示为绿星，4.5 ~ 5 星显示为蓝星。你可以将其设定为其他颜色组合。\n每一个字幕代表一颗星, 默认的 RRGGB 表示第一第二颗星显示为红色 R(ed)，第三第四颗星显示是绿色 G(reen)，第五颗星显示为蓝色 B(lue)。你也可以使用黄色 (Y)ellow，R/G/B/Y 任何五个组合都是有效的。"),
        "uc_reclass": MessageLookupByLibrary.simpleMessage("重新分类"),
        "uc_rename": MessageLookupByLibrary.simpleMessage("重命名"),
        "uc_res_res": MessageLookupByLibrary.simpleMessage("重新采样分辨率"),
        "uc_res_res_desc": MessageLookupByLibrary.simpleMessage(
            "通常情况，图像将重采样到 1280 像素宽度以用于在线浏览，您也可以选择以下重新采样分辨率。但是为了避免负载过高，高于 1280 像素将只供给于赞助者、特殊贡献者，以及 UID 小于 3,000,000 的用户。"),
        "uc_sc_0": MessageLookupByLibrary.simpleMessage("悬停或点击时"),
        "uc_sc_1": MessageLookupByLibrary.simpleMessage("总是"),
        "uc_search_r_count": MessageLookupByLibrary.simpleMessage("搜索结果数"),
        "uc_search_r_count_desc": MessageLookupByLibrary.simpleMessage(
            "主页/搜索页面每页显示多少条数据？（Hath Perk：需要「页面扩大」）"),
        "uc_selected": MessageLookupByLibrary.simpleMessage("当前"),
        "uc_set_as_def": MessageLookupByLibrary.simpleMessage("设为默认"),
        "uc_show_page_num": MessageLookupByLibrary.simpleMessage("显示图库页码"),
        "uc_tag": MessageLookupByLibrary.simpleMessage("图库标签"),
        "uc_tag_ft": MessageLookupByLibrary.simpleMessage("标签筛选阈值"),
        "uc_tag_ft_desc": MessageLookupByLibrary.simpleMessage(
            "你可以通过将标签加入「我的标签」并设置一个负权重来软过滤它们。如果一个作品所有的标签权重之和低于设定值，此作品将从视图中被过滤。这个值可以设定为 0 ~ -9999。"),
        "uc_tag_namesp": MessageLookupByLibrary.simpleMessage("标签组"),
        "uc_tag_short_order": MessageLookupByLibrary.simpleMessage("图库标签排序"),
        "uc_tag_wt": MessageLookupByLibrary.simpleMessage("标签订阅阈值"),
        "uc_tag_wt_desc": MessageLookupByLibrary.simpleMessage(
            "你可以通过将标签加入「我的标签」并设置一个正权重来订阅它们。如果一个最近上传的作品所有标签的权重之和高于设定值，则它将会被包含在「订阅」里。这个值可以设定为 0 ~ 9999。"),
        "uc_tb_0": MessageLookupByLibrary.simpleMessage("按字母排序"),
        "uc_tb_1": MessageLookupByLibrary.simpleMessage("按标签权重"),
        "uc_thor_hath": MessageLookupByLibrary.simpleMessage("通过H@H加载"),
        "uc_thumb_row": MessageLookupByLibrary.simpleMessage("行数"),
        "uc_thumb_scaling": MessageLookupByLibrary.simpleMessage("缩略图缩放"),
        "uc_thumb_scaling_desc": MessageLookupByLibrary.simpleMessage(
            "缩略图和扩展模式下的图库列表缩略图可以缩放为 75% 到 150% 之间的自定义值。"),
        "uc_thumb_setting": MessageLookupByLibrary.simpleMessage("缩略图设置"),
        "uc_thumb_size": MessageLookupByLibrary.simpleMessage("大小"),
        "uc_tl_0": MessageLookupByLibrary.simpleMessage("默认标题"),
        "uc_tl_1": MessageLookupByLibrary.simpleMessage("日文标题（如果有）"),
        "uc_ts_0": MessageLookupByLibrary.simpleMessage("普通"),
        "uc_ts_1": MessageLookupByLibrary.simpleMessage("大图"),
        "uc_uh_0": MessageLookupByLibrary.simpleMessage("所有客户端（推荐）"),
        "uc_uh_0_s": MessageLookupByLibrary.simpleMessage("所有客户端"),
        "uc_uh_1": MessageLookupByLibrary.simpleMessage(
            "仅使用默认端口的客户端（可能稍慢。当防火墙或代理阻止非标准接口的流量时启用此项。）"),
        "uc_uh_1_s": MessageLookupByLibrary.simpleMessage("仅使用默认端口的客户端"),
        "uc_uh_2": MessageLookupByLibrary.simpleMessage(
            "否 [现代/HTTPS]（仅限赞助者。配额消耗会加快，只有出现严重的问题时才启用。）"),
        "uc_uh_2_s": MessageLookupByLibrary.simpleMessage("否 [传统/HTTP]"),
        "uc_uh_3": MessageLookupByLibrary.simpleMessage(
            "否 [传统/HTTP]（仅限赞助者。可能无法在现代浏览器中使用，只推荐在过时的浏览器中启用。）"),
        "uc_uh_3_s": MessageLookupByLibrary.simpleMessage("否 [传统/HTTP]"),
        "uc_viewport_or": MessageLookupByLibrary.simpleMessage("移动端虚拟宽度"),
        "uc_viewport_or_desc": MessageLookupByLibrary.simpleMessage(
            "允许你覆盖移动设备的虚拟宽度，默认是根据 DPI 自动计算的，100% 缩略图比例下的合理值在 640 到 1400 之间。"),
        "uc_xt_desc": MessageLookupByLibrary.simpleMessage(
            "如果要从默认标签搜索中排除某些标签组，可以检查以下内容。请注意，这不会阻止在这些标签组中的标签的展示区出现，它只是在搜索标签时排除这些标签组。"),
        "unlimited": MessageLookupByLibrary.simpleMessage("不限制"),
        "uploader": MessageLookupByLibrary.simpleMessage("上传者"),
        "user_login": MessageLookupByLibrary.simpleMessage("用户登录"),
        "user_name": MessageLookupByLibrary.simpleMessage("用户名"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "vibrate_feedback": MessageLookupByLibrary.simpleMessage("震动反馈"),
        "vote_down_successfully": MessageLookupByLibrary.simpleMessage("点踩成功"),
        "vote_successfully": MessageLookupByLibrary.simpleMessage("投票成功"),
        "vote_up_successfully": MessageLookupByLibrary.simpleMessage("点赞成功"),
        "webdav_Account": MessageLookupByLibrary.simpleMessage("WebDAV账户"),
        "welcome_text":
            MessageLookupByLibrary.simpleMessage("小撸怡情~大撸伤身~强撸灰飞烟灭~~")
      };
}
