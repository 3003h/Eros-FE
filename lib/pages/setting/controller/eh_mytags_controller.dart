import 'package:fehviewer/common/controller/tag_controller.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/setting/mytags/eh_usertag_edit_dialog.dart';
import 'package:fehviewer/store/db/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const kEhMyTags = EhMytags(tagsets: []);

class EhMyTagsController extends GetxController
    with StateMixin<List<EhMytagSet>> {
  static String idUsertagList = 'idUsertagList';

  final trController = Get.find<TagTransController>();
  final tagController = Get.find<TagController>();

  final _isLoading = false.obs;

  bool get isStackLoading => _isLoading.value;
  set isStackLoading(bool val) => _isLoading.value = val;

  final _ehMyTags = kEhMyTags.obs;
  EhMytags get ehMyTags => _ehMyTags.value;
  set ehMyTags(EhMytags val) => _ehMyTags.value = val;

  final _canDelete = false.obs;
  bool get canDelete => _canDelete.value;
  set canDelete(bool val) => _canDelete.value = val;

  RxList<EhUsertag> searchTags = <EhUsertag>[].obs;

  List<EhUsertag> get usertags {
    if (!isSearchUserTags) {
      return ehMyTags.usertags ?? <EhUsertag>[];
    } else {
      // 搜索状态
      return inputSearchText.isEmpty
          ? ehMyTags.usertags ?? <EhUsertag>[]
          : searchTags;
    }
  }

  RxList<EhUsertag> searchNewTags = <EhUsertag>[].obs;

  final EhSettingService ehSettingService = Get.find();
  final LocaleService localeService = Get.find();

  String get apikey => ehMyTags.apikey ?? '';
  String get apiuid => ehMyTags.apiuid ?? '';

  String currSelected = '';

  final _isSearchUser = false.obs;
  bool get isSearchUserTags => _isSearchUser.value;
  set isSearchUserTags(bool val) => _isSearchUser.value = val;

  bool get isTagTranslat =>
      ehSettingService.isTagTranslate && localeService.isLanguageCodeZh;

  final _inputSearchText = ''.obs;
  String get inputSearchText => _inputSearchText.value;
  set inputSearchText(String val) => _inputSearchText.value = val;

  @override
  void onInit() {
    super.onInit();
    firstLoad();

    debounce(_inputSearchText, reSearch);
  }

  Future<void> reSearch(String text) async {
    logger.t('debounce _inputSearchText $text');
    if (text.trim().isEmpty) {
      searchNewTags.clear();
    }

    // 筛选tag
    final rult = (ehMyTags.usertags ?? <EhUsertag>[]).where((element) =>
        element.title.contains(text) ||
        (element.translate?.contains(text) ?? false));
    searchTags.clear();
    if (rult.isNotEmpty) {
      searchTags.addAll(rult);
    }

    // 新tag
    // 通过eh的api搜索
    List<TagTranslat> tagTranslateList =
        await Api.tagSuggest(text: text.trim());

    // 中文从翻译库匹配
    if (localeService.isLanguageCodeZh && ehSettingService.isTagTranslate) {
      List<TagTranslat> qryTagsList = await Get.find<TagTransController>()
          .getTagTranslatesLike(text: text.trim(), limit: 200);

      for (final tr in qryTagsList) {
        if (tagTranslateList
            .any((element) => element.fullTagText == tr.fullTagText)) {
          continue;
        }
        tagTranslateList.add(tr);
      }
    }

    // searchNewTags.clear();

    final _newTags = <EhUsertag>[];
    for (final tr in tagTranslateList) {
      final title = '${tr.namespace}:${tr.key}';
      if (ehMyTags.usertags?.any((element) => element.title == title) ??
          false) {
        continue;
      }
      final translate = await trController.getTranTagWithNameSpase(title);
      _newTags.add(
        EhUsertag(
          title: '${tr.namespace}:${tr.key}',
          defaultColor: true,
          watch: false,
          hide: false,
          tagWeight: '10',
          translate: translate,
        ),
      );
    }

    searchNewTags(_newTags);
  }

  Future<String?> getTextTranslate(String text) async {
    String namespace = '';
    if (text.contains(':')) {
      namespace = text.split(':')[0];
    }
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpase(
      text,
      namespace: namespace,
    );
    if (tranText?.trim() != text) {
      return tranText;
    }
    return null;
  }

  Future<void> firstLoad() async {
    // logger.d('firstLoad');
    change(null, status: RxStatus.loading());
    final sets = await loadData();
    if (sets == null || sets.tagsets.isEmpty) {
      change([], status: RxStatus.empty());
      return;
    }
    change(sets.tagsets, status: RxStatus.success());
  }

  Future<EhMytags?> loadData({bool refresh = false}) async {
    // change(null, status: RxStatus.loading());
    canDelete = false;
    try {
      final mytags = await getMyTags(
        refresh: refresh || Global.forceRefreshUconfig,
        selectTagset: currSelected,
      );
      isStackLoading = false;

      if (mytags != null) {
        ehMyTags = mytags;
        canDelete = mytags.canDelete ?? false;

        tagController.addAllTags(ehMyTags.usertags);
        return mytags;
      }
    } catch (e) {
      rethrow;
    } finally {
      // isLoading = false;
    }
    return null;
  }

  Future<void> reloadData() async {
    final sets = await loadData(refresh: true);
    change(sets?.tagsets, status: RxStatus.success());
    if (isSearchUserTags) {
      reSearch(inputSearchText);
    }
  }

  Map<String, EhMytagSet> get tagsetMap {
    final Map<String, EhMytagSet> _map = <String, EhMytagSet>{};
    for (final _tagset in ehMyTags.tagsets) {
      _map['${_tagset.value}'] = _tagset;
    }
    return _map;
  }

  EhMytagSet? get curTagSet => tagsetMap[currSelected];

  Future<bool> deleteTagset() async {
    if (currSelected.isNotEmpty) {
      isStackLoading = true;
      await actionDeleteTagSet(tagset: currSelected);
      await reloadData();
      isStackLoading = false;
      return true;
    }
    return false;
  }

  Future<void> crtNewTagset({required String name}) async {
    isStackLoading = true;
    await actionCreatTagSet(tagsetname: name);
    await reloadData();
    isStackLoading = false;
  }

  Future<void> renameTagSet({required String newName}) async {
    final rult = await actionRenameTagSet(
      tagsetname: newName,
      tagset: currSelected,
    );
    if (rult) {
      isStackLoading = true;
      await reloadData();
      isStackLoading = false;
    }
  }

  void deleteUserTag(String title) {
    logger.d('delete Usertag $title');
    final temp = ehMyTags.clone();
    final tag = temp.usertags
        ?.firstWhere((element) => element.title.trim() == title.trim());
    if (tag == null) {
      return;
    }

    final _id = tag.tagid;
    final index = temp.usertags?.indexOf(tag);
    if (index == null || index < 0) {
      return;
    }
    temp.usertags?.removeAt(index);
    ehMyTags = temp;
    if (_id != null) {
      actionDeleteUserTag(usertags: [_id]);
    }

    if (isSearchUserTags) {
      reSearch(inputSearchText);
    }
  }

  // 添加新的用户tag
  Future<void> showAddNewTagDialog(
    BuildContext context, {
    required EhUsertag userTag,
  }) async {
    // 选择需要保存到的tagset
    final saveToSet = await showCupertinoDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Tagset'),
            content: Container(
              child: obx(
                (state) {
                  if (state == null) {
                    Get.back();
                    return const SizedBox.shrink();
                  }

                  if (state.length == 1) {
                    // 如果只有一个tagset 自动选择并返回
                    Get.back(result: state.first.value);
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: state
                        .map((e) => TagSetListItem(
                              text: e.name,
                              onTap: () {
                                Get.back(result: e.value);
                              },
                            ))
                        .toList(),
                  );
                },
                onLoading: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const CupertinoActivityIndicator(),
                ),
              ),
            ),
          );
        });

    logger.d('saveToSet $saveToSet');

    // 不选择的话默认 set 1
    currSelected = saveToSet ?? '1';
    firstLoad();

    await showNewOrChangeUserTagDialog(context, userTag: userTag);
  }

  Future<void> showNewOrChangeUserTagDialog(
    BuildContext context, {
    required EhUsertag userTag,
  }) async {
    // 新tag标志
    bool _newUsertag = true;
    final _userTag = await showCupertinoDialog<EhUsertag>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return obx(
            (state) {
              if (usertags.map((e) => e.title).contains(userTag.title)) {
                // 如果该tagset中已经存在了，查询并显示编辑对话框
                _newUsertag = false;
                final _oriUserTag = usertags
                    .firstWhere((element) => element.title == userTag.title);
                logger.d('edit tag ${userTag.title}');
                return EhUserTagEditDialog(usertag: _oriUserTag);
              } else {
                // 正常新增
                logger.d('new tag ${userTag.title}');
                return EhUserTagEditDialog(usertag: userTag);
              }
            },
            onLoading: CupertinoAlertDialog(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const CupertinoActivityIndicator(),
              ),
            ),
          );
        });

    if (_userTag == null) {
      return;
    }

    if (_newUsertag) {
      await actionNewUserTag(
        tagName: userTag.title,
        tagColor: _userTag.colorCode,
        tagWeight: _userTag.tagWeight,
        tagWatch: _userTag.watch,
        tagHide: _userTag.hide,
        tagset: currSelected,
      );
      showToast('Add to mytags successful');
    } else {
      await Api.setUserTag(
        apikey: apikey,
        apiuid: apiuid,
        tagid: _userTag.tagid!,
        tagColor: _userTag.colorCode ?? '',
        tagWeight: _userTag.tagWeight ?? '',
        tagHide: _userTag.hide ?? false,
        tagWatch: _userTag.watch ?? false,
      );
      showToast('Change successful');
    }
  }
}

class TagSetListItem extends StatefulWidget {
  const TagSetListItem({
    Key? key,
    required VoidCallback onTap,
    required this.text,
    this.tagset,
    this.totNum,
  })  : _onTap = onTap,
        super(key: key);

  final VoidCallback _onTap;
  final String text;
  final String? tagset;
  final int? totNum;

  @override
  _TagSetListItemState createState() => _TagSetListItemState();
}

class _TagSetListItemState extends State<TagSetListItem> {
  Color? _color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _color,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.tags,
                size: 18,
              ).paddingOnly(left: 8, right: 12, bottom: 2),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              // Text(
              //   '${widget.totNum ?? 0}',
              //   style: const TextStyle(
              //     fontSize: 14,
              //   ),
              // ).paddingOnly(right: 4),
            ],
          ),
        ),
        onTap: widget._onTap,
        onTapDown: (_) {
          setState(() {
            _color = CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, context);
          });
        },
        onTapCancel: () {
          setState(() {
            _color = null;
          });
        },
      ),
    );
  }
}
