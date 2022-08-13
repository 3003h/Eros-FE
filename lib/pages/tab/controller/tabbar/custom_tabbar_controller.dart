import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../fetch_list.dart';
import '../default_tabview_controller.dart';
import 'custom_sublist_controller.dart';

final CustomProfile profileChinese = CustomProfile(
    uuid: generateUuidv4(), name: '汉语', searchText: const ['l:chinese']);

/// 控制所有自定义列表
class CustomTabbarController extends DefaultTabViewController {
  final WebdavController webdavController = Get.find();

  final executor = Executor(concurrency: 1);

  CustomTabConfig? get customTabConfig => Global.profile.customTabConfig;
  set customTabConfig(CustomTabConfig? val) =>
      Global.profile = Global.profile.copyWith(customTabConfig: val);

  final RxList<CustomProfile> profiles = <CustomProfile>[].obs;
  Map<String, CustomProfile> get profileMap {
    Map<String, CustomProfile> _map = {};
    for (final profile in profiles) {
      _map[profile.uuid] = profile;
    }
    return _map;
  }

  // 登记删除的profile和时间
  final RxList<CustomProfile> delProfiles = <CustomProfile>[].obs;

  // 显示的分组
  List<CustomProfile> get profilesShow =>
      profiles.whereNot((element) => element.hideTab ?? false).toList();

  final _currProfileUuid = ''.obs;
  String get currProfileUuid => _currProfileUuid.value;
  set currProfileUuid(String val) => _currProfileUuid.value = val;

  final _index = 0.obs;
  int get index => _index.value;
  set index(int val) => _index.value = val;

  final _reorderable = false.obs;
  bool get reorderable => _reorderable.value;
  set reorderable(bool val) => _reorderable.value = val;

  Map<String, CustomSubListController> subControllerMap = {};
  CustomSubListController? get currSubController =>
      subControllerMap[currProfileUuid];

  @override
  int get maxPage => currSubController?.maxPage ?? 1;

  @override
  int get minPage => currSubController?.minPage ?? 0;

  @override
  int get curPage => currSubController?.curPage ?? 0;

  late PageController pageController;

  final LinkScrollBarController linkScrollBarController =
      LinkScrollBarController();

  @override
  void onInit() {
    super.onInit();

    logger.d('CustomProfile onInit');

    heroTag = EHRoutes.gallery;

    // 初始化分组
    profiles.value = customTabConfig?.profiles ??
        [
          CustomProfile(
                  name: L10n.of(Get.context!).tab_popular,
                  uuid: generateUuidv4())
              .copyWithListType(GalleryListType.popular),
          CustomProfile(
                  name: L10n.of(Get.context!).tab_gallery,
                  uuid: generateUuidv4())
              .copyWithListType(GalleryListType.gallery),
          CustomProfile(
                  name: L10n.of(Get.context!).tab_watched,
                  uuid: generateUuidv4())
              .copyWithListType(GalleryListType.watched),
          if (Get.find<LocaleService>().isLanguageCodeZh) profileChinese,
          CustomProfile(
              uuid: generateUuidv4(),
              name: 'Anthology',
              searchText: const ['o:anthology'])
        ];

    ever<List<CustomProfile>>(profiles, (value) {
      customTabConfig = customTabConfig?.copyWith(profiles: value) ??
          CustomTabConfig(profiles: value);
      Global.saveProfile();
    });

    index = customTabConfig?.lastIndex ?? 0;
    ever<int>(_index, (value) {
      customTabConfig = customTabConfig?.copyWith(lastIndex: value) ??
          CustomTabConfig(lastIndex: value);
      Global.saveProfile();
    });

    delProfiles(hiveHelper.getProfileDelList());
    debounce<List<CustomProfile>>(delProfiles, (value) {
      hiveHelper.setProfileDelList(value);
    }, time: const Duration(seconds: 2));

    if (profiles.isNotEmpty) {
      currProfileUuid = profiles[min(max(index, 0), profiles.length - 1)].uuid;
    }

    for (final profile in profiles) {
      Get.lazyPut(() => CustomSubListController(profileUuid: profile.uuid),
          tag: profile.uuid);
    }
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
    linkScrollBarController.dispose();
  }

  void onPageChanged(int index) {
    currProfileUuid = profiles[index].uuid;
    this.index = index;
  }

  @override
  Future<void> showJumpToPage() async {
    void _jump() {
      logger.d('jumpToPage');
      final String _input = pageJumpTextEditController.text.trim();

      if (_input.isEmpty) {
        showToast(L10n.of(Get.context!).input_empty);
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast(L10n.of(Get.context!).input_error);
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage - 1) {
        FocusScope.of(Get.context!).requestFocus(FocusNode());
        currSubController?.loadFromPage(_toPage);
        Get.back();
      } else {
        showToast(L10n.of(Get.context!).page_range_error);
      }
    }

    return await showJumpDialog(jump: _jump, maxPage: maxPage);
  }

  @override
  Future<void> firstLoad() async {}

  Future<void> pressedBar() async {
    await Get.toNamed(
      EHRoutes.customProfiles,
      id: isLayoutLarge ? 1 : null,
    );
  }

  // 编辑分组（新增或者修改现有）
  Future<void> toEditPage({String? uuid}) async {
    final topRoute =
        SecondNavigatorObserver().history.lastOrNull?.settings.name;
    logger.d('topRoute $topRoute');

    // 依赖注入
    Get.replace<CustomProfile>(
        profileMap[uuid] ?? CustomProfile(name: '', uuid: generateUuidv4()));

    if (isLayoutLarge && topRoute == EHRoutes.customProfileSetting) {
      await Get.offNamed(
        EHRoutes.customProfileSetting,
        id: isLayoutLarge ? 2 : null,
        preventDuplicates: false,
      );
    } else {
      await Get.toNamed(
        EHRoutes.customProfileSetting,
        id: isLayoutLarge ? 2 : null,
        preventDuplicates: false,
      );
    }
  }

  // 交换位置
  Future<void> onReorder(int oldIndex, int newIndex) async {
    final _profileUuid = currProfileUuid;
    final _profile = profiles.removeAt(oldIndex);
    profiles.insert(newIndex, _profile);
    index = profiles.indexWhere((element) => element.uuid == _profileUuid);
    await 200.milliseconds.delay();
    pageController.jumpToPage(index);
    linkScrollBarController.scrollToItem(index);
  }

  // 删除分组配置
  Future<void> deleteProfile({required String uuid}) async {
    final _profileUuid = currProfileUuid;

    if (_profileUuid == uuid) {
      await 200.milliseconds.delay();
    }

    addDelProfile(profiles.firstWhere((element) => element.uuid == uuid));
    profiles.removeWhere((element) => element.uuid == uuid);
  }

  void addDelProfile(CustomProfile profile) {
    final nowTime = DateTime.now().millisecondsSinceEpoch;
    final _index = delProfiles.indexOf((e) => e.name == profile.name);
    if (_index > -1) {
      delProfiles[_index] = delProfiles[_index].copyWith(lastEditTime: nowTime);
    } else {
      delProfiles.add(profile);
    }
  }

  void pressSubmitText() {}

  // 删除对话框
  void showDeleteGroupModalBottomSheet(String uuid, BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () {
                      deleteProfile(uuid: uuid);
                      Get.back();
                    },
                    child: Text(
                      L10n.of(context).delete,
                      style: const TextStyle(
                          color: CupertinoColors.destructiveRed),
                    )),
              ],
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(L10n.of(context).cancel)));
        });
  }

  void addProfile(CustomProfile profile) {
    logger.v(' ${jsonEncode(profile)}');

    final oriIndexOfSameUuid =
        profiles.indexWhere((element) => element.uuid == profile.uuid);

    final oriIndexOfSameName =
        profiles.indexWhere((element) => element.name == profile.name);

    if (oriIndexOfSameUuid >= 0) {
      // 优先覆盖相同uuid
      profiles[oriIndexOfSameUuid] = profile;
    } else if (oriIndexOfSameName >= 0) {
      // 其次覆盖相同组名
      profiles[oriIndexOfSameName] = profile;
    } else {
      // 都不匹配则新增
      logger.d('new profile ${profile.name} ${profile.uuid}');
      profiles.add(profile);
    }

    Get.lazyPut(
      () => CustomSubListController(profileUuid: profile.uuid)
        ..heroTag = profile.uuid,
      tag: profile.uuid,
      fenix: true,
    );

    final CustomSubListController subController = Get.find(tag: profile.uuid);
    subController.listMode = profile.listMode;
    subController.onInit();
  }

  Future<void> syncProfiles() async {
    final listLocal = List<CustomProfile>.from(profiles);
    logger.v('listLocal ${listLocal.length} \n${listLocal.map((e) => e.uuid)}');
    logger.v('${jsonEncode(listLocal)} ');

    // 下载远程文件名列表 包含： 分组名 uuid 时间戳
    final listRemote = await webdavController.getRemotGroupList();
    // 远程列表为空 直接上传本地所有分组
    if (listRemote.isEmpty) {
      await _uploadProfiles(listLocal);
      return;
    }

    logger.v('listRemote size ${listRemote.length}');

    // 比较远程和本地的差异
    // 合并列表
    final allProfile = <CustomProfile?>{...listRemote, ...listLocal};
    final diff = allProfile
        .where((element) =>
            !listRemote.contains(element) || !listLocal.contains(element))
        .toList()
        .toSet();
    logger.v('diff ${diff.map((e) => e?.toJson())}');

    // 本地分组中 编辑时间更靠后的
    final localNewer = listLocal.where(
      (eLocal) {
        final _eRemote = listRemote.firstWhereOrNull((eRemote) =>
            eRemote.uuid == eLocal.uuid || eRemote.name == eLocal.name);
        if (_eRemote == null) {
          return true;
        }

        return (eLocal.lastEditTime ?? 0) > (_eRemote.lastEditTime ?? 0);
      },
    );
    logger.v('localNewer count ${localNewer.length}');

    // 远程 编辑时间更靠后的
    final remoteNewer = listRemote.where(
      (eRemote) {
        final _eLocal = listLocal.firstWhereOrNull((eLocal) =>
            eLocal.uuid == eRemote.uuid || eLocal.name == eRemote.name);

        // delProfiles 中 name 和远程文件一样的
        final _eDelFlg = delProfiles.where(
            (eDel) => eDel.uuid == eRemote.uuid || eDel.name == eRemote.name);

        if (_eDelFlg.isNotEmpty) {
          return _eDelFlg.every(
              (e) => (eRemote.lastEditTime ?? 0) > (e.lastEditTime ?? 0));
        }

        if (_eLocal == null) {
          return true;
        }

        return (eRemote.lastEditTime ?? 0) > (_eLocal.lastEditTime ?? 0);
      },
    );
    logger.v('remoteNewer ${remoteNewer.map((e) => e.name).toList()}');

    await _downloadProfiles(remoteNewer.toSet().toList());

    await _uploadProfiles(localNewer.toList(), listRemote: listRemote);
  }

  Future _downloadProfiles(List<CustomProfile> remoteList) async {
    for (final remote in remoteList) {
      executor.scheduleTask(() async {
        final _remote = await webdavController.downloadGroupProfile(remote);
        if (_remote != null) {
          final ori = profiles.firstWhereOrNull((element) =>
              element.uuid == _remote.uuid || element.name == _remote.name);

          if (ori != null &&
              (remote.lastEditTime ?? 0) <= (ori.lastEditTime ?? 0)) {
            return;
          }
          addProfile(_remote);
        }
      });
    }

    await executor.join(withWaiting: true);
  }

  Future _uploadProfiles(
    List<CustomProfile?> localHisList, {
    List<CustomProfile?>? listRemote,
  }) async {
    for (final profile in localHisList) {
      executor.scheduleTask(() async {
        final _oriRemote = listRemote?.firstWhereOrNull((element) =>
            element?.uuid == profile?.uuid || element?.name == profile?.name);

        if (profile != null) {
          final upload = webdavController.uploadGroupProfile(profile);
          final delete = webdavController.deleteRemotGroup(_oriRemote);
          await Future.wait([upload, delete]);
        }
      });
    }
    await executor.join(withWaiting: true);
  }
}
