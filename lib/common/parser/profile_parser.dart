import 'package:collection/collection.dart';
import 'package:eros_fe/models/base/eh_models.dart';
// import 'package:eros_fe/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

EhSettings parseEhSettings(String html) {
  final profileSet = <EhProfile>[];

  final Document document = parse(html);

  // 解析profile
  final Element? profileSetElm =
      document.querySelector('#profile_form > select');
  late String selectedValue = '';
  late String defaultProfile = '';
  if (profileSetElm != null) {
    final profiles = profileSetElm.children;
    for (final pf in profiles) {
      final value = pf.attributes['value'];
      if (value == null) {
        continue;
      }
      final isSelected = pf.attributes['selected'] == 'selected';

      final name = pf.text.replaceAllMapped(
          RegExp(r'(.+)\(Default\)'), (match) => match.group(1) ?? '');
      if (isSelected) {
        selectedValue = value;
      }

      if (pf.text.trim().endsWith('(Default)')) {
        defaultProfile = value;
      }

      profileSet.add(EhProfile(
          name: name.trim(), selected: isSelected, value: int.parse(value)));
    }
  }

  final inputElms = document.getElementsByTagName('input');

  // 解析图片加载设置
  final uh = _parseUConfigChecked('uh', document);

  // 图片大小设置
  final xr = _parseUConfigChecked('xr', document);
  final rx = _parseUConfigInput('rx', inputElms);
  final ry = _parseUConfigInput('ry', inputElms);

  // 图库的名字显示
  final tl = _parseUConfigChecked('tl', document);

  // 归档下载方式
  final ar = _parseUConfigChecked('ar', document);

  // 首页样式
  final dm = _parseUConfigChecked('dm', document);

  // 首页上看到哪些类别 ct

  // 收藏夹中默认排序 fs
  final fs = _parseUConfigChecked('fs', document);

  final fav = <EhSettingItem>[];
  for (int idx = 0; idx <= 9; idx++) {
    final favValue = _parseUConfigInput('favorite_$idx', inputElms);
    if (favValue != null) {
      fav.add(EhSettingItem(type: 'favorite', ser: '$idx', value: favValue));
    }
  }

  //
  final ru = _parseUConfigInput('ru', inputElms);

  // 排除标签组
  final xn = <EhSettingItem>[];
  for (int idx = 1; idx <= 50; idx++) {
    final Element? elm = document.querySelector('#xn_$idx');
    if (elm != null) {
      xn.add(EhSettingItem(
        type: 'xn',
        ser: '$idx',
        value: elm.attributes['checked'] == 'checked' ? '1' : '0',
        name: elm.parent?.text.trim(),
      ));
    }
  }

  // 排除语言 xl
  final xl = <EhSettingItem>[];
  for (int idx = 0; idx <= 2303; idx++) {
    final Element? elmXl = document.querySelector('#xl_$idx');
    if (elmXl?.attributes['checked'] == 'checked') {
      xl.add(EhSettingItem(type: 'xl', ser: '$idx', value: '1'));
    }
  }

  final ft = _parseUConfigInput('ft', inputElms);
  final wt = _parseUConfigInput('wt', inputElms);

  final xu = document.querySelector('#xu')?.text.trim();
  // print('xu:$xu');

  final xuQuota = document
      .querySelector('#xu')
      ?.parent
      ?.nextElementSibling
      ?.querySelectorAll('strong');
  // print('============== xlQuota ${xuQuota?.map((e) => e.text)}');
  final int xuQuotaUsing = int.parse(xuQuota?[0].text ?? '0');
  final int xuQuotaMax = int.parse(xuQuota?[1].text ?? '1000');

  // 搜索结果数 rc
  // todo 需要测试无Hath Perk情况
  final rc = _parseUConfigChecked('rc', document);

  // lt 鼠标悬停缩略图何时加载
  final lt = _parseUConfigChecked('lt', document);

  // ts 缩略图大小
  final ts = _parseUConfigChecked('ts', document);

  // tr 行数
  final tr = _parseUConfigChecked('tr', document);

  final tp = _parseUConfigInput('tp', inputElms);
  final vp = _parseUConfigInput('vp', inputElms);

  // 评论排序方式 cs
  final cs = _parseUConfigChecked('cs', document);

  // 显示评论投票数 sc
  final sc = _parseUConfigChecked('sc', document);

  // 图库标签排序方式 tb
  final tb = _parseUConfigChecked('tb', document);

  // 图库缩略图标签 pn
  final pn = _parseUConfigChecked('pn', document);

  final hh = _parseUConfigInput('hh', inputElms);

  // 原始图像代替压缩过的版本 oi
  final oi = _parseUConfigChecked('oi', document);

  // 总是使用多页查看器 qb
  final qb = _parseUConfigChecked('qb', document);
  // print('mpv qb $qb');

  // 显示样式 ms
  final ms = _parseUConfigChecked('ms', document);

  // 显示缩略图侧栏 mt
  final mt = _parseUConfigChecked('mt', document);

  return EhSettings(
    profilelist: profileSet,
    profileSelected: selectedValue,
    defaultProfile: defaultProfile,
    loadImageThroughHAtH: uh,
    imageSize: xr,
    galleryNameDisplay: tl,
    archiverSettings: ar,
    frontPageSettings: dm,
    sortOrderFavorites: fs,
    searchResultCount: rc,
    mouseOverThumbnails: lt,
    thumbnailSize: ts,
    thumbnailRows: tr,
    sortOrderComments: cs,
    showCommentVotes: sc,
    sortOrderTags: tb,
    showGalleryPageNumbers: pn,
    hentaiAtHomeLocalNetworkHost: hh,
    originalImages: oi,
    alwaysUseMpv: qb,
    mpvStyle: ms,
    mpvThumbnailPane: mt,
    thumbnailScaling: tp,
    viewportOverride: vp,
    excludedUploaders: xu,
    xuQuotaMax: xuQuotaMax,
    xuQuotaUsing: xuQuotaUsing,
    tagWatchingThreshold: wt,
    tagFilteringThreshold: ft,
    ratings: ru,
    imageSizeHorizontal: rx,
    imageSizeVertical: ry,
    xn: xn,
    xl: xl,
    favorites: fav,
  );
}

String _parseUConfigChecked(String name, Document document, {int max = 10}) {
  int sel = 0;
  for (int idx = 0; idx <= max; idx++) {
    final Element? elm = document.querySelector('#${name}_$idx');
    if (elm?.attributes['checked'] == 'checked') {
      sel = idx;
      break;
    }
  }
  // logger.d('$name:$sel');
  return sel.toString();
}

String? _parseUConfigInput(String name, List<Element> inputElms) {
  return inputElms
      .firstWhereOrNull((elm) => elm.attributes['name'] == name)
      ?.attributes['value'];
}
