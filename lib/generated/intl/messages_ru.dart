// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(site) => "Текущий ${site}";

  static String m1(modelName) => "Модель ${modelName}";

  static String m2(rating) => "${rating} ⭐";

  static String m3(tagNamespace) => "${Intl.select(tagNamespace, {
            'reclass': 'reclass',
            'language': 'language',
            'parody': 'parody',
            'character': 'character',
            'group': 'group',
            'artist': 'artist',
            'male': 'male',
            'female': 'female',
            'mixed': 'mixed',
            'cosplayer': 'cosplayer',
            'other': 'other',
            'temp': 'temp',
          })}";

  static String m4(version) => "Update to ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "KEEP_IT_SAFE":
            MessageLookupByLibrary.simpleMessage("Никому не показывайте"),
        "QR_code_check": MessageLookupByLibrary.simpleMessage("QR code Check"),
        "about": MessageLookupByLibrary.simpleMessage("О приложении"),
        "add_quick_search":
            MessageLookupByLibrary.simpleMessage("Добавить в БП"),
        "add_tag_placeholder": MessageLookupByLibrary.simpleMessage(
            "Введите новые теги, разделенные запятой"),
        "add_tags": MessageLookupByLibrary.simpleMessage("Добавить теги"),
        "add_to_favorites":
            MessageLookupByLibrary.simpleMessage("Добавить в избранное"),
        "advanced": MessageLookupByLibrary.simpleMessage("Дополнительно"),
        "aggregate": MessageLookupByLibrary.simpleMessage("Объединить"),
        "aggregate_groups":
            MessageLookupByLibrary.simpleMessage("Объединить группы"),
        "all_Favorites": MessageLookupByLibrary.simpleMessage("Все"),
        "all_comment": MessageLookupByLibrary.simpleMessage("Все комментарии"),
        "all_preview": MessageLookupByLibrary.simpleMessage("Все превью"),
        "allow_media_scan": MessageLookupByLibrary.simpleMessage(
            "Разрешить видеть папку извне"),
        "always": MessageLookupByLibrary.simpleMessage("Постоянно"),
        "app_title": MessageLookupByLibrary.simpleMessage("FEhViewer"),
        "ask_me": MessageLookupByLibrary.simpleMessage("Спрашивать всегда"),
        "auth_biometricHint":
            MessageLookupByLibrary.simpleMessage("Подтвердите личность"),
        "auth_signInTitle":
            MessageLookupByLibrary.simpleMessage("Требуется авторизация"),
        "author": MessageLookupByLibrary.simpleMessage("Автор"),
        "autoLock":
            MessageLookupByLibrary.simpleMessage("Автоматическая блокировка"),
        "auto_select_profile":
            MessageLookupByLibrary.simpleMessage("Автоопределение профиля"),
        "avatar": MessageLookupByLibrary.simpleMessage("Аватар"),
        "back": MessageLookupByLibrary.simpleMessage("Назад"),
        "blurring_cover_background": MessageLookupByLibrary.simpleMessage(
            "Blurring of cover background"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "change_to_favorites":
            MessageLookupByLibrary.simpleMessage("Change to favorites"),
        "chapter": MessageLookupByLibrary.simpleMessage("Глава"),
        "check_for_update":
            MessageLookupByLibrary.simpleMessage("Check for Update"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
        "clear_filter": MessageLookupByLibrary.simpleMessage("Очистить"),
        "clear_search_history":
            MessageLookupByLibrary.simpleMessage("Очистить историю поиска"),
        "clipboard_detection":
            MessageLookupByLibrary.simpleMessage("Анализ буфера обмена"),
        "clipboard_detection_desc": MessageLookupByLibrary.simpleMessage(
            "Автоматически подцеплять ссылки из буфера обмена"),
        "collapse": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "color_picker_primary":
            MessageLookupByLibrary.simpleMessage("основной"),
        "color_picker_wheel": MessageLookupByLibrary.simpleMessage("wheel"),
        "copied_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Скопировано в буфер обмена"),
        "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
        "current_site": m0,
        "current_version":
            MessageLookupByLibrary.simpleMessage("Текущая версия"),
        "custom_hosts":
            MessageLookupByLibrary.simpleMessage("Пользовательские узлы"),
        "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
        "dark_mode_effect":
            MessageLookupByLibrary.simpleMessage("Вид тёмной темы"),
        "default_avatar_style":
            MessageLookupByLibrary.simpleMessage("Стиль аватара по умолчанию"),
        "default_favorites":
            MessageLookupByLibrary.simpleMessage("Избранное по умолчанию"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "delete_task":
            MessageLookupByLibrary.simpleMessage("Менеджер загрузок"),
        "delete_task_and_content":
            MessageLookupByLibrary.simpleMessage("Удалить задание и файлы"),
        "delete_task_only":
            MessageLookupByLibrary.simpleMessage("Удалить только задание"),
        "disabled": MessageLookupByLibrary.simpleMessage("Выключено"),
        "domain_fronting":
            MessageLookupByLibrary.simpleMessage("Фронтинг домена"),
        "donate": MessageLookupByLibrary.simpleMessage("Пожертвовать"),
        "done": MessageLookupByLibrary.simpleMessage("Готово"),
        "double_click_back": MessageLookupByLibrary.simpleMessage(
            "Нажмите еще раз, чтобы выйти"),
        "double_page_model": MessageLookupByLibrary.simpleMessage(
            "Модель просмотра двух страниц"),
        "download": MessageLookupByLibrary.simpleMessage("Загрузки"),
        "download_location":
            MessageLookupByLibrary.simpleMessage("Каталог загрузок"),
        "download_ori_image": MessageLookupByLibrary.simpleMessage(
            "Загружать изображения исходного качества"),
        "download_ori_image_summary": MessageLookupByLibrary.simpleMessage(
            "Это опасно! Вы можете получить ошибку 509"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Скачано"),
        "downloading": MessageLookupByLibrary.simpleMessage("Скачивание"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "edit_comment":
            MessageLookupByLibrary.simpleMessage("Изменить комментарий"),
        "eh": MessageLookupByLibrary.simpleMessage("E·H"),
        "ehentai_my_tags": MessageLookupByLibrary.simpleMessage("Мои теги"),
        "ehentai_settings":
            MessageLookupByLibrary.simpleMessage("EHentai настройки"),
        "expand": MessageLookupByLibrary.simpleMessage("Показать"),
        "export": MessageLookupByLibrary.simpleMessage("Экспортировать"),
        "favcat": MessageLookupByLibrary.simpleMessage("Избранное"),
        "favorites_order":
            MessageLookupByLibrary.simpleMessage("Упорядочить избранное"),
        "favorites_order_Use_favorited": MessageLookupByLibrary.simpleMessage(
            "По дате добавления в избранное"),
        "favorites_order_Use_posted":
            MessageLookupByLibrary.simpleMessage("По дате обновления галереи"),
        "fixed_height_of_list_items": MessageLookupByLibrary.simpleMessage(
            "Фиксированная высота элементов списка"),
        "follow_system": MessageLookupByLibrary.simpleMessage("Как в системе"),
        "fullscreen": MessageLookupByLibrary.simpleMessage("На полный экран"),
        "galery_site": MessageLookupByLibrary.simpleMessage("Каталог галереи"),
        "gallery_comments":
            MessageLookupByLibrary.simpleMessage("Комментарии галереи"),
        "global_setting":
            MessageLookupByLibrary.simpleMessage("Как в настройках"),
        "gray_black": MessageLookupByLibrary.simpleMessage("Тёмная"),
        "group": MessageLookupByLibrary.simpleMessage("Категории"),
        "groupName": MessageLookupByLibrary.simpleMessage("Название категории"),
        "groupType": MessageLookupByLibrary.simpleMessage("Тип категории"),
        "hide": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "hours": MessageLookupByLibrary.simpleMessage("час(ов)"),
        "image_download_type":
            MessageLookupByLibrary.simpleMessage("Тип загрузки"),
        "image_hide":
            MessageLookupByLibrary.simpleMessage("Скрыть изображение"),
        "image_limits":
            MessageLookupByLibrary.simpleMessage("Ограничения изображения"),
        "input_empty":
            MessageLookupByLibrary.simpleMessage("Буфер обмена пуст"),
        "input_error": MessageLookupByLibrary.simpleMessage("Ошибка ввода"),
        "instantly": MessageLookupByLibrary.simpleMessage("Сразу"),
        "jump_to_page":
            MessageLookupByLibrary.simpleMessage("Перейти на страницу"),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "last_favorites": MessageLookupByLibrary.simpleMessage(
            "Последнее использованное избранное, долгий тап чтобы выбрать вручную"),
        "latest_version":
            MessageLookupByLibrary.simpleMessage("Latest version"),
        "layout": MessageLookupByLibrary.simpleMessage("Layout"),
        "left_to_right": MessageLookupByLibrary.simpleMessage("Слева направо"),
        "license": MessageLookupByLibrary.simpleMessage("Лицензии"),
        "light": MessageLookupByLibrary.simpleMessage("Светлая"),
        "link_redirect":
            MessageLookupByLibrary.simpleMessage("Перенаправление ссылок"),
        "link_redirect_summary": MessageLookupByLibrary.simpleMessage(
            "Перенаправление ссылок на галереи на выбранные сайты"),
        "list_load_more_fail": MessageLookupByLibrary.simpleMessage(
            "Загрузка не удалась... нажмите, чтобы попробовать еще раз"),
        "list_mode": MessageLookupByLibrary.simpleMessage("Отображение"),
        "listmode_grid": MessageLookupByLibrary.simpleMessage("Сетка"),
        "listmode_medium":
            MessageLookupByLibrary.simpleMessage("Список - Средний"),
        "listmode_small":
            MessageLookupByLibrary.simpleMessage("Список - Компактный"),
        "listmode_waterfall": MessageLookupByLibrary.simpleMessage("Водопад"),
        "listmode_waterfall_large":
            MessageLookupByLibrary.simpleMessage("Водопад - Крупный"),
        "loading": MessageLookupByLibrary.simpleMessage("Загрузка"),
        "local_favorite":
            MessageLookupByLibrary.simpleMessage("Локальное Избранное"),
        "login": MessageLookupByLibrary.simpleMessage("Войти"),
        "login_web":
            MessageLookupByLibrary.simpleMessage("Войти через браузер"),
        "mange_hidden_images": MessageLookupByLibrary.simpleMessage(
            "Управление скрытыми изображениями"),
        "manually_sel_favorites": MessageLookupByLibrary.simpleMessage(
            "Вручную выбирать группу избранного"),
        "max_history": MessageLookupByLibrary.simpleMessage("Maximum history"),
        "min": MessageLookupByLibrary.simpleMessage("минут"),
        "model": m1,
        "morePreviews": MessageLookupByLibrary.simpleMessage("Показать ещё"),
        "multi_download":
            MessageLookupByLibrary.simpleMessage("Многопоточная загрузка"),
        "mytags_on_website":
            MessageLookupByLibrary.simpleMessage("Мои теги на сайте"),
        "newGroup": MessageLookupByLibrary.simpleMessage("Новая категория"),
        "newText": MessageLookupByLibrary.simpleMessage("Новый тег"),
        "new_comment":
            MessageLookupByLibrary.simpleMessage("Новый комментарий"),
        "no": MessageLookupByLibrary.simpleMessage("Нет"),
        "noMorePreviews": MessageLookupByLibrary.simpleMessage("Конец списка"),
        "no_limit": MessageLookupByLibrary.simpleMessage("No Limit"),
        "notFav": MessageLookupByLibrary.simpleMessage("Добавить в избранное"),
        "not_login": MessageLookupByLibrary.simpleMessage("Not Login"),
        "off": MessageLookupByLibrary.simpleMessage("Выключены"),
        "ok": MessageLookupByLibrary.simpleMessage("ОК"),
        "on": MessageLookupByLibrary.simpleMessage("Включены"),
        "open_supported_links": MessageLookupByLibrary.simpleMessage(
            "Открывать поддерживаемые ссылки"),
        "open_supported_links_summary": MessageLookupByLibrary.simpleMessage(
            "Начиная с Android 12, приложения могут обрабатывать ссылки только если они одобрены. В противном случае ссылки будут обработаны через браузер по умолчанию. Вы можете вручную одобрить ссылки здесь"),
        "open_with_other_apps":
            MessageLookupByLibrary.simpleMessage("Открыть в другом приложении"),
        "orientation_auto": MessageLookupByLibrary.simpleMessage("Свободная"),
        "orientation_landscapeLeft":
            MessageLookupByLibrary.simpleMessage("Альбомная-слева"),
        "orientation_landscapeRight":
            MessageLookupByLibrary.simpleMessage("Альбомная-справа"),
        "orientation_portraitUp":
            MessageLookupByLibrary.simpleMessage("Портретная"),
        "orientation_system":
            MessageLookupByLibrary.simpleMessage("Как в системе"),
        "original_image": MessageLookupByLibrary.simpleMessage("Оригинальное"),
        "p_Archiver": MessageLookupByLibrary.simpleMessage("Архиватор"),
        "p_Download": MessageLookupByLibrary.simpleMessage("Скачать"),
        "p_Rate": MessageLookupByLibrary.simpleMessage("Оценить"),
        "p_Similar": MessageLookupByLibrary.simpleMessage("Похожие"),
        "p_Torrent": MessageLookupByLibrary.simpleMessage("Торрент"),
        "page_range": MessageLookupByLibrary.simpleMessage("Диапазон страниц"),
        "page_range_error":
            MessageLookupByLibrary.simpleMessage("Ошибка в диапазоне страниц"),
        "passwd": MessageLookupByLibrary.simpleMessage("Пароль"),
        "paused": MessageLookupByLibrary.simpleMessage("На паузе"),
        "phash_check":
            MessageLookupByLibrary.simpleMessage("Perceptual Hash Check"),
        "pls_i_passwd":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите пароль"),
        "pls_i_username":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите логин"),
        "preload_image": MessageLookupByLibrary.simpleMessage(
            "Предварительная загрузка изображений"),
        "previews": MessageLookupByLibrary.simpleMessage("Превью"),
        "processing": MessageLookupByLibrary.simpleMessage("В процессе"),
        "pure_black": MessageLookupByLibrary.simpleMessage("Чёрная"),
        "quick_search": MessageLookupByLibrary.simpleMessage("Быстрый поиск"),
        "read": MessageLookupByLibrary.simpleMessage("Читалка"),
        "read_from_clipboard":
            MessageLookupByLibrary.simpleMessage("Вставить из буфера обмена"),
        "read_setting":
            MessageLookupByLibrary.simpleMessage("Настройки читалки"),
        "reading_direction":
            MessageLookupByLibrary.simpleMessage("Режим чтения"),
        "rebuild_tasks_data":
            MessageLookupByLibrary.simpleMessage("Пересобрать задания"),
        "redirect_thumb_link":
            MessageLookupByLibrary.simpleMessage("Redirect Thumb Link"),
        "redirect_thumb_link_summary": MessageLookupByLibrary.simpleMessage(
            "Redirect Thumb Link To ehgt.org"),
        "redownload": MessageLookupByLibrary.simpleMessage("Скачать заново"),
        "reload_image":
            MessageLookupByLibrary.simpleMessage("Загрузить заново"),
        "remove_from_favorites":
            MessageLookupByLibrary.simpleMessage("Удалить из избранного"),
        "reply_to_comment": MessageLookupByLibrary.simpleMessage("Ответить"),
        "resample_image": MessageLookupByLibrary.simpleMessage("Сжатое"),
        "reset_cost":
            MessageLookupByLibrary.simpleMessage("Сбросить стоимость"),
        "restore_tasks_data":
            MessageLookupByLibrary.simpleMessage("Возобновить задания"),
        "right_to_left": MessageLookupByLibrary.simpleMessage("Справа налево"),
        "s_Advanced_Options":
            MessageLookupByLibrary.simpleMessage("Дополнительные параметры"),
        "s_Between": MessageLookupByLibrary.simpleMessage("Среди"),
        "s_Disable_default_filters": MessageLookupByLibrary.simpleMessage(
            "Отключить стандартные фильтры"),
        "s_Minimum_Rating":
            MessageLookupByLibrary.simpleMessage("Минимальная оценка"),
        "s_Only_Show_Galleries_With_Torrents":
            MessageLookupByLibrary.simpleMessage(
                "Показывать только галереи с торрентами"),
        "s_Search_Downvoted_Tags":
            MessageLookupByLibrary.simpleMessage("Искать с нежеланными тегами"),
        "s_Search_Fav_Name":
            MessageLookupByLibrary.simpleMessage("Искать в названии"),
        "s_Search_Fav_Note":
            MessageLookupByLibrary.simpleMessage("Искать в заметках"),
        "s_Search_Fav_Tags":
            MessageLookupByLibrary.simpleMessage("Искать в тегах"),
        "s_Search_Gallery_Description":
            MessageLookupByLibrary.simpleMessage("Поиск в описании галерей"),
        "s_Search_Gallery_Name":
            MessageLookupByLibrary.simpleMessage("Поиск в названии галерей"),
        "s_Search_Gallery_Tags":
            MessageLookupByLibrary.simpleMessage("Поиск в тегах галерей"),
        "s_Search_Low_Power_Tags": MessageLookupByLibrary.simpleMessage(
            "Искать с малым количеством тегов"),
        "s_Search_Torrent_Filenames": MessageLookupByLibrary.simpleMessage(
            "Искать в названиях торрентов"),
        "s_Show_Expunged_Galleries":
            MessageLookupByLibrary.simpleMessage("Показывать скрытые галереи"),
        "s_and": MessageLookupByLibrary.simpleMessage("и"),
        "s_pages": MessageLookupByLibrary.simpleMessage("страницы"),
        "s_stars": m2,
        "save_into_album":
            MessageLookupByLibrary.simpleMessage("Сохранить в галерею"),
        "saved_successfully":
            MessageLookupByLibrary.simpleMessage("Успешно сохранено"),
        "screen_orientation":
            MessageLookupByLibrary.simpleMessage("Ориентация экрана"),
        "search": MessageLookupByLibrary.simpleMessage("Поиск"),
        "searchTexts": MessageLookupByLibrary.simpleMessage("Поиск тегов"),
        "search_history":
            MessageLookupByLibrary.simpleMessage("История поиска"),
        "search_type": MessageLookupByLibrary.simpleMessage("Искать тип"),
        "second": MessageLookupByLibrary.simpleMessage("секунд"),
        "security": MessageLookupByLibrary.simpleMessage("Безопасность"),
        "security_blurredInRecentTasks":
            MessageLookupByLibrary.simpleMessage("Защита экрана приложения"),
        "setting_on_website":
            MessageLookupByLibrary.simpleMessage("Настройки на сайте"),
        "share": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "share_image":
            MessageLookupByLibrary.simpleMessage("Поделиться изображением"),
        "show_comment_avatar": MessageLookupByLibrary.simpleMessage(
            "Показать аватар комментатора"),
        "show_filter": MessageLookupByLibrary.simpleMessage("Показать фильтр"),
        "show_jpn_title": MessageLookupByLibrary.simpleMessage(
            "Показывать названия на японском"),
        "show_page_interval": MessageLookupByLibrary.simpleMessage(
            "Показывать интервал между страницами"),
        "skip": MessageLookupByLibrary.simpleMessage("Пропустить"),
        "sync_group":
            MessageLookupByLibrary.simpleMessage("Синхронизация группы"),
        "sync_history":
            MessageLookupByLibrary.simpleMessage("Синхронизация истории"),
        "sync_quick_search": MessageLookupByLibrary.simpleMessage(
            "Синхронизация быстрого поиска"),
        "sync_read_progress": MessageLookupByLibrary.simpleMessage(
            "Синхронизация прогресса чтения"),
        "system_share":
            MessageLookupByLibrary.simpleMessage("Поделиться через...."),
        "t_Clear_all_history":
            MessageLookupByLibrary.simpleMessage("Очистить всю историю"),
        "tab_download": MessageLookupByLibrary.simpleMessage("Загрузки"),
        "tab_favorite": MessageLookupByLibrary.simpleMessage("Избранное"),
        "tab_gallery": MessageLookupByLibrary.simpleMessage("Галерея"),
        "tab_history": MessageLookupByLibrary.simpleMessage("История"),
        "tab_popular": MessageLookupByLibrary.simpleMessage("Популярное"),
        "tab_setting": MessageLookupByLibrary.simpleMessage("Настройки"),
        "tab_sort": MessageLookupByLibrary.simpleMessage(
            "Сделайте долгий тап и перемещайте для сортировки"),
        "tab_toplist": MessageLookupByLibrary.simpleMessage("Лучшее"),
        "tab_watched": MessageLookupByLibrary.simpleMessage("Отслеживаемое"),
        "tabbar_setting":
            MessageLookupByLibrary.simpleMessage("Настройки нижней панели"),
        "tablet_layout": MessageLookupByLibrary.simpleMessage("Tablet layout"),
        "tagNamespace": m3,
        "tag_add_to_mytag":
            MessageLookupByLibrary.simpleMessage("Добавить в мои теги"),
        "tag_dialog_Default_color":
            MessageLookupByLibrary.simpleMessage("Цвет по умолчанию"),
        "tag_dialog_Hide": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "tag_dialog_TagColor": MessageLookupByLibrary.simpleMessage("Цвет"),
        "tag_dialog_Watch": MessageLookupByLibrary.simpleMessage(
            "Показывать материалы с тегом"),
        "tag_dialog_tagWeight":
            MessageLookupByLibrary.simpleMessage("Значимость тега"),
        "tag_limit": MessageLookupByLibrary.simpleMessage("Tag Limit"),
        "tag_vote_down":
            MessageLookupByLibrary.simpleMessage("Дизлайкнуть тег"),
        "tag_vote_up": MessageLookupByLibrary.simpleMessage("Лайкнуть тег"),
        "tag_withdraw_vote":
            MessageLookupByLibrary.simpleMessage("убрать лайк/дизлайк с тега"),
        "tags": MessageLookupByLibrary.simpleMessage("Теги"),
        "tap_to_turn_page_anima": MessageLookupByLibrary.simpleMessage(
            "Анимированные переходы страниц"),
        "theme": MessageLookupByLibrary.simpleMessage("Тема"),
        "tolist_alltime": MessageLookupByLibrary.simpleMessage("За всё время"),
        "tolist_past_month": MessageLookupByLibrary.simpleMessage("За месяц"),
        "tolist_past_year": MessageLookupByLibrary.simpleMessage("За год"),
        "tolist_yesterday":
            MessageLookupByLibrary.simpleMessage("За вчерашний день"),
        "top_to_bottom": MessageLookupByLibrary.simpleMessage("Вертикально"),
        "uc_Chinese": MessageLookupByLibrary.simpleMessage("Китайский"),
        "uc_Dutch": MessageLookupByLibrary.simpleMessage("Голландский"),
        "uc_English": MessageLookupByLibrary.simpleMessage("Английский"),
        "uc_French": MessageLookupByLibrary.simpleMessage("Французский"),
        "uc_German": MessageLookupByLibrary.simpleMessage("Немецкий"),
        "uc_Hungarian": MessageLookupByLibrary.simpleMessage("Венгерский"),
        "uc_Italian": MessageLookupByLibrary.simpleMessage("Итальянский"),
        "uc_Japanese": MessageLookupByLibrary.simpleMessage("Японский"),
        "uc_Korean": MessageLookupByLibrary.simpleMessage("Корейский"),
        "uc_NA": MessageLookupByLibrary.simpleMessage("N/A"),
        "uc_Original": MessageLookupByLibrary.simpleMessage("Оригинальная"),
        "uc_Other": MessageLookupByLibrary.simpleMessage("Другой"),
        "uc_Polish": MessageLookupByLibrary.simpleMessage("Польский"),
        "uc_Portuguese": MessageLookupByLibrary.simpleMessage("Португальский"),
        "uc_Rewrite": MessageLookupByLibrary.simpleMessage("Переписано"),
        "uc_Russian": MessageLookupByLibrary.simpleMessage("Русский"),
        "uc_Spanish": MessageLookupByLibrary.simpleMessage("Испанский"),
        "uc_Thai": MessageLookupByLibrary.simpleMessage("Тайский"),
        "uc_Translated": MessageLookupByLibrary.simpleMessage("Переведено"),
        "uc_Vietnamese": MessageLookupByLibrary.simpleMessage("Вьетнамский"),
        "uc_ar_0": MessageLookupByLibrary.simpleMessage(
            "Ручной выбор, Ручной запуск (По умолчанию)"),
        "uc_ar_1": MessageLookupByLibrary.simpleMessage(
            "Ручной выбор, Автоматический запуск"),
        "uc_ar_2": MessageLookupByLibrary.simpleMessage(
            "Автоматический выбор исходных изображений, Ручной запуск"),
        "uc_ar_3": MessageLookupByLibrary.simpleMessage(
            "Автоматический выбор исходных изображений, Автоматический запуск"),
        "uc_ar_4": MessageLookupByLibrary.simpleMessage(
            "Автоматический выбор сжатых изображений, Ручной запуск"),
        "uc_ar_5": MessageLookupByLibrary.simpleMessage(
            "Автоматический выбор сжатых изображенийe, Автоматический запуск"),
        "uc_archiver_desc": MessageLookupByLibrary.simpleMessage(
            "Изначально роль архиватора состоит в том, чтобы рассчитать траты и выбрать исходный или сжатый архив, а затем представить ссылку, по которой можно перейти или скопировать в другое место. Вы можете изменить это здесь"),
        "uc_archiver_set":
            MessageLookupByLibrary.simpleMessage("Настройки архиватора"),
        "uc_artist": MessageLookupByLibrary.simpleMessage("artist"),
        "uc_auto": MessageLookupByLibrary.simpleMessage("Автоматически"),
        "uc_character": MessageLookupByLibrary.simpleMessage("character"),
        "uc_comments_show_votes":
            MessageLookupByLibrary.simpleMessage("Показ голосов"),
        "uc_comments_sort_order":
            MessageLookupByLibrary.simpleMessage("Порядок сортировки"),
        "uc_crt_profile":
            MessageLookupByLibrary.simpleMessage("Создать новый профиль"),
        "uc_cs_0": MessageLookupByLibrary.simpleMessage("Сначала старые"),
        "uc_cs_1": MessageLookupByLibrary.simpleMessage("Сначала новые"),
        "uc_cs_2": MessageLookupByLibrary.simpleMessage("Самые лайкнутые"),
        "uc_del_profile":
            MessageLookupByLibrary.simpleMessage("Удалить профиль"),
        "uc_dm_0": MessageLookupByLibrary.simpleMessage("Компактный"),
        "uc_dm_1": MessageLookupByLibrary.simpleMessage(
            "Отображение миниатюр изображений"),
        "uc_dm_2": MessageLookupByLibrary.simpleMessage("Расширенный"),
        "uc_dm_3": MessageLookupByLibrary.simpleMessage("Минималистичный"),
        "uc_dm_4": MessageLookupByLibrary.simpleMessage("Минималистичный+"),
        "uc_exc_lang":
            MessageLookupByLibrary.simpleMessage("Исключенные языки"),
        "uc_exc_lang_desc": MessageLookupByLibrary.simpleMessage(
            "Если вы хотите скрыть галереи на определенных языках из списка галерей и результатов поиска, выберите их из списка выше.\n Обратите внимание, что соответствующие галереи никогда не появятся независимо от вашего поискового запроса"),
        "uc_exc_up":
            MessageLookupByLibrary.simpleMessage("Исключенные загрузчики"),
        "uc_exc_up_desc": MessageLookupByLibrary.simpleMessage(
            "Если вы хотите скрыть галереи от определенных загрузчиков из списка галерей и поиска, добавьте их выше. Введите одно имя пользователя в строку. Обратите внимание, что галереи от этих загрузчиков никогда не появятся, независимо от вашего поискового запроса"),
        "uc_fav": MessageLookupByLibrary.simpleMessage("Избранные"),
        "uc_fav_sort":
            MessageLookupByLibrary.simpleMessage("Сортировка по умолчанию"),
        "uc_fav_sort_desc": MessageLookupByLibrary.simpleMessage(
            "Вы также можете выбрать порядок сортировки галерей по умолчанию на странице избранного. Обратите внимание, что избранное, добавленное до обновления в марте 2016 года, не сохраняло временную метку и будет использовать время публикации в галерее независимо от этого параметра"),
        "uc_female": MessageLookupByLibrary.simpleMessage("female"),
        "uc_front_page":
            MessageLookupByLibrary.simpleMessage("Главная страница"),
        "uc_front_page_dis_mode": MessageLookupByLibrary.simpleMessage(
            "Режим отображения главной страницы"),
        "uc_fs_0": MessageLookupByLibrary.simpleMessage(
            "По времени обновления галереии"),
        "uc_fs_1": MessageLookupByLibrary.simpleMessage(
            "По времени добавления в избранное"),
        "uc_gallery_comments":
            MessageLookupByLibrary.simpleMessage("Комментарии галереи"),
        "uc_group": MessageLookupByLibrary.simpleMessage("group"),
        "uc_hath_local_host": MessageLookupByLibrary.simpleMessage(
            "Hentai@Home Local Network Host"),
        "uc_hath_local_host_desc": MessageLookupByLibrary.simpleMessage(
            "Эта настройка может быть использована, если у вас в локальной сети запущен клиент H@H с тем же публичным IP адресом, с которым вы пользуетесь приложением. Некоторые маршрутизаторы глючат и не могут направить запросы к собственному IP; с помощью этого вы можете обойти данную проблема.\nЕсли клиент запущен на том же ПК, на котором запущено данное приложение, следует использовать адрес 127.0.0.1:port. Если клиент запущен на другом ПК в той же локальной сети, используйте его локальный IP адрес. Некоторые настройки браузера предотвращают запросы к внешним сайтам с IP адресов в локальной сети, для того, чтобы это работало, необходимо добавить сайт в список исключений"),
        "uc_img_cussize_desc": MessageLookupByLibrary.simpleMessage(
            "Хотя сайт автоматически уменьшит масштаб изображений в соответствии с разрешением экрана, вы также можете вручную ограничить максимальное разрешение изображения. Как и при автоматическом масштабировании, это не приводит к изменению разрешения изображения в приложении, так как изменение разрешения происходит на стороне браузера. (0 = нет ограничений)"),
        "uc_img_horiz": MessageLookupByLibrary.simpleMessage("По горизонтали"),
        "uc_img_load_setting": MessageLookupByLibrary.simpleMessage(
            "Настройки загрузки изображения"),
        "uc_img_size_setting": MessageLookupByLibrary.simpleMessage(
            "Настройки размера изображения"),
        "uc_img_vert": MessageLookupByLibrary.simpleMessage("По вертикали"),
        "uc_ip_addr_port":
            MessageLookupByLibrary.simpleMessage("IP Адрес:Порт"),
        "uc_language": MessageLookupByLibrary.simpleMessage("language"),
        "uc_lt_0": MessageLookupByLibrary.simpleMessage(
            "При наведении курсора на миниатюру (страницы загружаются быстрее, но может возникнуть небольшая задержка, прежде чем миниатюра появится)"),
        "uc_lt_0_s": MessageLookupByLibrary.simpleMessage("При наведении мыши"),
        "uc_lt_1": MessageLookupByLibrary.simpleMessage(
            "При загрузке страницы (загрузка страниц занимает больше времени, но отсутствует задержка при загрузке миниатюр)"),
        "uc_lt_1_s":
            MessageLookupByLibrary.simpleMessage("При загрузке страницы"),
        "uc_male": MessageLookupByLibrary.simpleMessage("male"),
        "uc_mose_over_thumb": MessageLookupByLibrary.simpleMessage(
            "Наведение курсора мыши на миниатюры"),
        "uc_mpv":
            MessageLookupByLibrary.simpleMessage("Многостраничная читалка"),
        "uc_mpv_always":
            MessageLookupByLibrary.simpleMessage("Всегда использовать"),
        "uc_mpv_stype":
            MessageLookupByLibrary.simpleMessage("Стиль отображения"),
        "uc_mpv_thumb_pane":
            MessageLookupByLibrary.simpleMessage("Лента миниатюр"),
        "uc_ms_0": MessageLookupByLibrary.simpleMessage(
            "Выровнять по левому краю;\n масштабировать только в том случае, если изображение больше ширины браузера"),
        "uc_ms_1": MessageLookupByLibrary.simpleMessage(
            "Выровнять по центру;\n масштабировать только в том случае, если изображение больше ширины браузера"),
        "uc_ms_2": MessageLookupByLibrary.simpleMessage(
            "Выровнять по центру;\n всегда масштабировать изображения в соответствии с шириной браузера"),
        "uc_mt_0": MessageLookupByLibrary.simpleMessage("Показать"),
        "uc_mt_1": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "uc_name_display": MessageLookupByLibrary.simpleMessage(
            "Отображение названия галереи"),
        "uc_name_display_desc": MessageLookupByLibrary.simpleMessage(
            "Многие галереи имеют как английское/латинизированное название, так и название, написанное японским шрифтом. Какое название галереи вы хотели бы видеть по умолчанию?"),
        "uc_oi_0": MessageLookupByLibrary.simpleMessage("Неа"),
        "uc_oi_1": MessageLookupByLibrary.simpleMessage("Yup, I can take it"),
        "uc_ori_image":
            MessageLookupByLibrary.simpleMessage("Исходные изображения"),
        "uc_ori_image_desc": MessageLookupByLibrary.simpleMessage(
            "Использовать исходные изображения вместо сжатых, где это применимо?"),
        "uc_parody": MessageLookupByLibrary.simpleMessage("parody"),
        "uc_pixels": MessageLookupByLibrary.simpleMessage("pixels"),
        "uc_pn_0": MessageLookupByLibrary.simpleMessage("Нет"),
        "uc_pn_1": MessageLookupByLibrary.simpleMessage("Да"),
        "uc_profile": MessageLookupByLibrary.simpleMessage("Профиль"),
        "uc_qb_0": MessageLookupByLibrary.simpleMessage("Неа"),
        "uc_qb_1": MessageLookupByLibrary.simpleMessage("Ага"),
        "uc_rating": MessageLookupByLibrary.simpleMessage("Цвета рейтинга"),
        "uc_rating_desc": MessageLookupByLibrary.simpleMessage(
            "По умолчанию галереи, которые вы оценили, будут отмечены красными звездочками для оценок от 2 звезд и ниже, зелеными - для оценок от 2,5 до 4 звезд и синими - для оценок от 4,5 до 5 звезд. Вы можете настроить это, введя желаемую цветовую комбинацию ниже.\n Каждая буква представляет собой одну звезду. Значение RRGGB по умолчанию означает R(ed) для первой и второй звезды, G(reen) для третьей и четвертой и B(lue) для пятой. Вы также можете использовать (Y)ellow для обычных звезд. Любая комбинация из пяти букв R / G / B / Y работает"),
        "uc_reclass": MessageLookupByLibrary.simpleMessage("reclass"),
        "uc_rename": MessageLookupByLibrary.simpleMessage("Переименовать"),
        "uc_res_res": MessageLookupByLibrary.simpleMessage("Сжатие"),
        "uc_res_res_desc": MessageLookupByLibrary.simpleMessage(
            "Обычно изображения сжимаются до 1280 пикселей по горизонтали для просмотра в режиме онлайн. В качестве альтернативы вы можете выбрать одно из следующих разрешений. Чтобы избежать нагрузки на сервера, разрешение выше 1280x доступно лишь для донатеров, владельцев hath perk и людей с UID ниже 3 000 000"),
        "uc_sc_0":
            MessageLookupByLibrary.simpleMessage("При наведении или нажатии"),
        "uc_sc_1": MessageLookupByLibrary.simpleMessage("Всегда"),
        "uc_search_r_count":
            MessageLookupByLibrary.simpleMessage("Счетчик результатов поиска"),
        "uc_search_r_count_desc": MessageLookupByLibrary.simpleMessage(
            "Сколько результатов вы хотели бы получить для страниц индекса/поиска и страниц поиска торрентов? (Hath Perk: Paging Enlargement Required)"),
        "uc_selected": MessageLookupByLibrary.simpleMessage("Выбранный"),
        "uc_set_as_def": MessageLookupByLibrary.simpleMessage(
            "Установить как профиль по умолчанию"),
        "uc_show_page_num":
            MessageLookupByLibrary.simpleMessage("Показывать номера страниц"),
        "uc_tag": MessageLookupByLibrary.simpleMessage("Теги галереи"),
        "uc_tag_ft":
            MessageLookupByLibrary.simpleMessage("Порог фильтрации тегов"),
        "uc_tag_ft_desc": MessageLookupByLibrary.simpleMessage(
            "Вы можете аккуратно фильтровать теги, добавляя их в (мои теги) с отрицательным приоритетом. Если в галерее есть теги, суммарный приоритет которых превышает это значение, она не появится при поиске. Этот порог может быть установлен в диапазоне от 0 до -9999"),
        "uc_tag_namesp": MessageLookupByLibrary.simpleMessage("Группы тегов"),
        "uc_tag_short_order": MessageLookupByLibrary.simpleMessage(
            "Порядок сортировки тегов галереи"),
        "uc_tag_wt":
            MessageLookupByLibrary.simpleMessage("Tag Watching Threshold"),
        "uc_tag_wt_desc": MessageLookupByLibrary.simpleMessage(
            "Недавно загруженные галереи будут отображаться в отслеживаемом, если в них есть хотя бы один тег с положительным приоритетом, и сумма приоритета в его просмотренных тегах составляет это значение или выше. Этот порог может быть установлен в диапазоне от 0 до 9999"),
        "uc_tb_0": MessageLookupByLibrary.simpleMessage("По алфавиту"),
        "uc_tb_1": MessageLookupByLibrary.simpleMessage("По количеству тегов"),
        "uc_thor_hath": MessageLookupByLibrary.simpleMessage("Через H@H"),
        "uc_thumb_row":
            MessageLookupByLibrary.simpleMessage("Количество строк"),
        "uc_thumb_scaling":
            MessageLookupByLibrary.simpleMessage("Масштабирование миниатюр"),
        "uc_thumb_scaling_desc": MessageLookupByLibrary.simpleMessage(
            "Просто миниатюры и миниатюры из расширенного списка галерей можно масштабировать до настраиваемого значения от 75% до 150%"),
        "uc_thumb_setting": MessageLookupByLibrary.simpleMessage(
            "Настройки миниатюр изображений"),
        "uc_thumb_size": MessageLookupByLibrary.simpleMessage("Размер"),
        "uc_tl_0":
            MessageLookupByLibrary.simpleMessage("Название по умолчанию"),
        "uc_tl_1": MessageLookupByLibrary.simpleMessage(
            "Название на японском (если доступно)"),
        "uc_ts_0": MessageLookupByLibrary.simpleMessage("Нормальный"),
        "uc_ts_1": MessageLookupByLibrary.simpleMessage("Большой"),
        "uc_uh_0": MessageLookupByLibrary.simpleMessage(
            "Любой клиент (Рекомендуется)"),
        "uc_uh_0_s": MessageLookupByLibrary.simpleMessage("Любой клиент"),
        "uc_uh_1": MessageLookupByLibrary.simpleMessage(
            "Только клиенты с портами по умолчанию (Может быть достаточно медленным. Используйте, если брандмауэр/прокси блокируют нестандартные порты)"),
        "uc_uh_1_s": MessageLookupByLibrary.simpleMessage(
            "Только клиенты с портами по умолчанию"),
        "uc_uh_2": MessageLookupByLibrary.simpleMessage(
            "Нет [Современный метод/HTTPS] (Только для донатеров. Вы не сможете просматривать очень много страниц. Рекомендуется только если есть проблемы с другими методами)"),
        "uc_uh_2_s": MessageLookupByLibrary.simpleMessage(
            "Нет [Современный метод/HTTPS]"),
        "uc_uh_3": MessageLookupByLibrary.simpleMessage(
            "Нет [Устаревший метод/HTTP] (Только для донатеров. Может не работать в современных браузерах. Рекомендуется только для устаревших браузеров)"),
        "uc_uh_3_s":
            MessageLookupByLibrary.simpleMessage("Нет [Устаревший метод/HTTP]"),
        "uc_viewport_or": MessageLookupByLibrary.simpleMessage(
            "Переопределение ширины приложения"),
        "uc_viewport_or_desc": MessageLookupByLibrary.simpleMessage(
            "Позволяет переопределить виртуальную ширину приложения для мобильных устройств. Обычно она автоматически определяется вашим устройством на основе его точек на дюйм. Допустимые значения при 100%-ном масштабе миниатюр находятся в диапазоне от 640 до 1400"),
        "uc_xt_desc": MessageLookupByLibrary.simpleMessage(
            "Если вы хотите исключить определенные группы тегов из поиска по тегам по умолчанию, вы можете отметить их выше. Обратите внимание, что это не препятствует появлению галерей с тегами из этих групп, это просто делает так, что при поиске тегов он упустит их"),
        "unlimited": MessageLookupByLibrary.simpleMessage("Без ограничения"),
        "update_to_version": m4,
        "uploader": MessageLookupByLibrary.simpleMessage("Загрузчик"),
        "user_login": MessageLookupByLibrary.simpleMessage("Вход в аккаунт"),
        "user_name": MessageLookupByLibrary.simpleMessage("Логин"),
        "version": MessageLookupByLibrary.simpleMessage("Версия"),
        "vibrate_feedback": MessageLookupByLibrary.simpleMessage("Вибрация"),
        "vote_down_successfully":
            MessageLookupByLibrary.simpleMessage("Дизлайк успешно поставлен"),
        "vote_successfully":
            MessageLookupByLibrary.simpleMessage("Голос успешно отдан"),
        "vote_up_successfully":
            MessageLookupByLibrary.simpleMessage("Лайк успешно поставлен"),
        "webdav_Account":
            MessageLookupByLibrary.simpleMessage("Аккаунт WebDAV"),
        "welcome_text": MessageLookupByLibrary.simpleMessage("~ах~ ах~ ах~~~")
      };
}
