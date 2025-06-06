export 'download_archiver_task_info.dart';
export 'eh_mytag_set.dart';
export 'local_fav.dart';
export 'gallery_provider.dart';
export 'eh_config.dart';
export 'simple_tag.dart';
export 'block_rule.dart';
export 'fav_add.dart';
export 'layout_config.dart';
export 'image_hide.dart';
export 'item_config.dart';
export 'fav_config.dart';
export 'commit_vote_res.dart';
export 'gallery_image.dart';
export 'auto_lock.dart';
export 'custom_tab_config.dart';
export 'dns_config.dart';
export 'gallery_cache.dart';
export 'uconfig.dart';
export 'chapter.dart';
export 'gallery_comment.dart';
export 'eh_usertag.dart';
export 'openl_translation.dart';
export 'gallery_tag.dart';
export 'dns_cache.dart';
export 'eh_settings.dart';
export 'mpv.dart';
export 'tab_item.dart';
export 'mvp_image.dart';
export 'eh_profile.dart';
export 'gallery_list.dart';
export 'custom_profile.dart';
export 'eh_home.dart';
export 'user.dart';
export 'history_index.dart';
export 'download_config.dart';
export 'gallery_torrent.dart';
export 'advance_search.dart';
export 'webdav_profile.dart';
export 'tag_group.dart';
export 'history_index_gid.dart';
export 'tab_config.dart';
export 'favcat.dart';
export 'cache_config.dart';
export 'mysql_config.dart';
export 'profile.dart';
export 'block_config.dart';
export 'eh_layout.dart';
export 'eh_setting_item.dart';
export 'mysql_connection_info.dart';
export 'eh_mytags.dart';
import 'package:quiver/core.dart';

T? checkOptional<T>(Optional<T?>? optional, T? Function()? def) {
  // No value given, just take default value
  if (optional == null) return def?.call();

  // We have an input value
  if (optional.isPresent) return optional.value;

  // We have a null inside the optional
  return null;
}
