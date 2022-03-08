import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../fehviewer.dart';
import '../eh_usertag_edit_dialog.dart';

const kEhMyTags = EhMytags(tagsets: []);

class EhMyTagsController extends GetxController
    with StateMixin<List<EhMytagSet>> {
  static String idUsertagList = 'idUsertagList';

  final _isLoading = false.obs;
  bool get isStackLoading => _isLoading.value;
  set isStackLoading(bool val) => _isLoading.value = val;

  final _ehMyTags = kEhMyTags.obs;
  EhMytags get ehMyTags => _ehMyTags.value;
  set ehMyTags(EhMytags val) => _ehMyTags.value = val;

  final _canDelete = false.obs;
  bool get canDelete => _canDelete.value;
  set canDelete(bool val) => _canDelete.value = val;

  List<EhUsertag> get usertags => ehMyTags.usertags ?? <EhUsertag>[];

  final EhConfigService ehConfigService = Get.find();
  final LocaleService localeService = Get.find();

  String get apikey => ehMyTags.apikey ?? '';
  String get apiuid => ehMyTags.apiuid ?? '';

  String currSelected = '';

  final _isSearchUser = false.obs;
  bool get isSearchUser => _isSearchUser.value;
  set isSearchUser(bool val) => _isSearchUser.value = val;

  bool get isTagTranslat =>
      ehConfigService.isTagTranslat && localeService.isLanguageCodeZh;

  @override
  void onInit() {
    super.onInit();
    firstLoad();
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
    logger.d('firstLoad');
    change(null, status: RxStatus.loading());
    final sets = await loadData();
    if (sets == null || sets.tagsets.isEmpty) {
      change([], status: RxStatus.empty());
      return;
    }
    change(sets.tagsets, status: RxStatus.success());
  }

  Future<EhMytags?> loadData({bool refresh = false}) async {
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

  Future<void> renameTagset({required String newName}) async {
    final rult = await actionRenameTagSet(tagsetname: newName);
    if (rult) {
      isStackLoading = true;
      await reloadData();
      isStackLoading = false;
    }
  }

  void deleteUsertag(int index) {
    logger.d('deleteUsertag $index');
    final temp = ehMyTags.clone();
    final _id = ehMyTags.usertags?[index].tagid;
    temp.usertags?.removeAt(index);
    ehMyTags = temp;
    if (_id != null) {
      actionDeleteUserTag(usertags: [_id]);
    }
  }

  Future<void> showAddNewTagDialog(
    BuildContext context, {
    required EhUsertag userTag,
  }) async {
    final saveToset = await showCupertinoDialog<String>(
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

    logger.d('saveToset $saveToset');

    // if (saveToset != currSelected) {
    //   logger.d('currSelected $currSelected, change to $saveToset');
    //   currSelected = saveToset ?? '1';
    //   firstLoad();
    // }
    currSelected = saveToset ?? '1';
    firstLoad();

    await showNewOrChangeUserTagDialog(context, userTag: userTag);
  }

  Future<void> showNewOrChangeUserTagDialog(
    BuildContext context, {
    required EhUsertag userTag,
  }) async {
    bool _newUsertag = true;
    final _userTag = await showCupertinoDialog<EhUsertag>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return obx(
            (state) {
              if (usertags.map((e) => e.title).contains(userTag.title)) {
                _newUsertag = false;
                final _oriUserTag = usertags
                    .firstWhere((element) => element.title == userTag.title);
                logger.d('edit tag ${userTag.title}');
                return EhUserTagEditDialog(usertag: _oriUserTag);
              } else {
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
