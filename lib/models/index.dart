import 'package:quiver/core.dart';

export 'advance_search.dart';
export 'auto_lock.dart';
export 'block_config.dart';
export 'block_rule.dart';
export 'cache_config.dart';
export 'chapter.dart';
export 'commit_vote_res.dart';
export 'custom_profile.dart';
export 'custom_tab_config.dart';
export 'dns_cache.dart';
export 'dns_config.dart';
export 'download_archiver_task_info.dart';
export 'download_config.dart';
export 'eh_config.dart';
export 'eh_home.dart';
export 'eh_layout.dart';
export 'eh_mytag_set.dart';
export 'eh_mytags.dart';
export 'eh_profile.dart';
export 'eh_setting_item.dart';
export 'eh_settings.dart';
export 'eh_usertag.dart';
export 'fav_add.dart';
export 'fav_config.dart';
export 'favcat.dart';
export 'gallery_cache.dart';
export 'gallery_comment.dart';
export 'gallery_image.dart';
export 'gallery_list.dart';
export 'gallery_provider.dart';
export 'gallery_tag.dart';
export 'gallery_torrent.dart';
export 'history_index.dart';
export 'history_index_gid.dart';
export 'image_hide.dart';
export 'item_config.dart';
export 'layout_config.dart';
export 'local_fav.dart';
export 'mpv.dart';
export 'mvp_image.dart';
export 'mysql_config.dart';
export 'mysql_connection_info.dart';
export 'openl_translation.dart';
export 'profile.dart';
export 'simple_tag.dart';
export 'tab_config.dart';
export 'tab_item.dart';
export 'tag_group.dart';
export 'uconfig.dart';
export 'user.dart';
export 'webdav_profile.dart';

T? checkOptional<T>(Optional<T?>? optional, T? Function()? def) {
  // No value given, just take default value
  if (optional == null) return def?.call();

  // We have an input value
  if (optional.isPresent) return optional.value;

  // We have a null inside the optional
  return null;
}
