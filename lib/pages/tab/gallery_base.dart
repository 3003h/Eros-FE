import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/advanceSearch.dart';
import 'package:FEhViewer/models/states/advance_search_model.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

///
/// 筛选画廊类型的按钮
class GalleryCatButton extends StatefulWidget {
  const GalleryCatButton({
    Key key,
    @required this.value,
    @required this.onChanged,
    @required this.onColor,
    Color offColor,
    this.onTextColor,
    Color offTextColor,
    @required this.text,
    this.onLongPress,
  })  : offColor = offColor ?? onColor,
        offTextColor = offTextColor ?? onTextColor,
        super(key: key);

  /// 设置的值
  final bool value;

  /// 开关回调
  final ValueChanged<bool> onChanged;

  /// 长按回调
  final VoidCallback onLongPress;

  /// 显示文本
  final String text;

  /// 开启时按钮色
  final Color onColor;

  /// 关闭时按钮色
  final Color offColor;

  /// 开启时文本颜色
  final Color onTextColor;

  /// 关闭时文本颜色
  final Color offTextColor;

  @override
  _GalleryCatButtonState createState() => _GalleryCatButtonState();
}

class _GalleryCatButtonState extends State<GalleryCatButton> {
  bool _value;
  Color _textColor;
  Color _color;

  @override
  Widget build(BuildContext context) {
    // Global.logger.v('GalleryCatButton build');
    return Container(
      child: GestureDetector(
        onLongPress: () => widget.onLongPress(),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: _pressBtn,
          pressedOpacity: 1.0,
          child: Text(
            widget.text,
            style: TextStyle(color: _textColor),
          ),
          color: _color,
        ),
      ),
    );
  }

  void _pressBtn() {
    // Global.logger.v('_pressBtn ${widget.text}');
    _value = !_value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
    setState(() {
      widget.onChanged(!_value);
    });
  }

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
  }
}

/// 画廊类型筛选器
/// 内含十个开关按钮 控制筛选的类型
/// 最终控制搜索的cat字段
class GalleryCatFilter extends StatefulWidget {
  const GalleryCatFilter(
      {Key key, this.value, this.onChanged, this.margin, this.padding})
      : super(key: key);

  final EdgeInsetsGeometry margin;

  final EdgeInsetsGeometry padding;

  /// cat值
  final int value;

  /// 值变化的回调
  final ValueChanged<int> onChanged;

  @override
  _GalleryCatFilterState createState() => _GalleryCatFilterState();
}

class _GalleryCatFilterState extends State<GalleryCatFilter> {
  int _catNum;
  Map<String, bool> _catMap;
  final List<Widget> _catButttonListWidget = <Widget>[];

  Widget _getCatButton(
      {@required String catName,
      Map<String, bool> catMap,
      ValueChanged<int> onChanged}) {
    return GalleryCatButton(
      text: catName,
      onChanged: (bool value) {
        Global.logger.v('$catName changed to ${!value}');
        setState(() {
          catMap[catName] = !value;
          onChanged(EHUtils.convCatMapToNum(catMap));
          Global.logger.v('$catMap');
        });
      },
      onColor: ThemeColors.catColor[catName],
      onTextColor: CupertinoColors.systemGrey6,
      offColor: CupertinoColors.systemGrey4,
      offTextColor: CupertinoColors.systemGrey,
      value: catMap[catName],
    );
  }

  @override
  void initState() {
    super.initState();
    _catNum = widget.value;
    _catMap = EHUtils.convNumToCatMap(_catNum);

    for (final String cat in EHConst.cats.keys) {
      _catButttonListWidget.add(
        _getCatButton(
          catName: cat,
          catMap: _catMap,
          onChanged: widget.onChanged,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EhConfigModel, int>(
        selector: (context, EhConfigModel ehconfig) => ehconfig.catFilter,
        builder: (context, int catFilter, _) {
          return Container(
            margin: widget.margin,
            padding: widget.padding,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.6,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              // physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              children: <Widget>[..._catButttonListWidget],
            ),
          );
        });
  }
}

class GalleryFilter extends StatefulWidget {
  const GalleryFilter({
    Key key,
    @required this.catNum,
    @required this.catNumChanged,
    @required this.advanceSearchSwitch,
    @required this.advanceSearchValue,
  }) : super(key: key);
  final int catNum;
  final ValueChanged<int> catNumChanged;
  final bool advanceSearchValue;
  final ValueChanged<bool> advanceSearchSwitch;

  @override
  _GalleryFilterState createState() => _GalleryFilterState();
}

const double kHeight = 220.0;
const double kAdvanceHeight = 500.0;

class _GalleryFilterState extends State<GalleryFilter> {
  double _height;
  int _catNum;
  bool _advance;

  AdvanceSearch _advanceSearch = Global.profile.advanceSearch;

  final TextEditingController _statrPageCtrl = TextEditingController();
  final TextEditingController _endPageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catNum = widget.catNum;
    _advance = widget.advanceSearchValue;
    _height = _advance ? kAdvanceHeight : kHeight;

    _statrPageCtrl.text = _advanceSearch.startPage;
    _endPageCtrl.text = _advanceSearch.endPage;

    _statrPageCtrl.addListener(() {
      _advanceSearch.startPage = _statrPageCtrl.text.trim();
    });
    _endPageCtrl.addListener(() {
      _advanceSearch.endPage = _endPageCtrl.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: _height,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GalleryCatFilter(
                // padding: const EdgeInsets.symmetric(vertical: 4.0),
                value: _catNum,
                onChanged: widget.catNumChanged,
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    const Text('高级搜索'),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                          value: _advance,
                          onChanged: (bool value) {
                            _height = value ? kAdvanceHeight : kHeight;
                            setState(() {
                              _advance = value;
                              widget.advanceSearchSwitch(value);
                            });
                          }),
                    ),
                    const Spacer(),
                    Offstage(
                      offstage: !_advance,
                      child: CupertinoButton(
                          padding: const EdgeInsets.only(right: 8),
                          minSize: 20,
                          child: const Text(
                            '重置',
                            style: TextStyle(height: 1, fontSize: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _statrPageCtrl.clear();
                              _endPageCtrl.clear();
                              _advanceSearch = AdvanceSearch()
                                ..searchGalleryName = true
                                ..searchGalleryTags = true;
                              Global.profile.advanceSearch = _advanceSearch;
                            });
                          }),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              ),
              Offstage(
                offstage: !_advance,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      AdvanceSearchSwitchItem(
                        title: '搜索画廊名字',
                        value: _advanceSearch.searchGalleryName ?? true,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchGalleryName = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '搜索画廊标签',
                        value: _advanceSearch.searchGalleryTags ?? true,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchGalleryTags = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '搜索画廊描述',
                        value: _advanceSearch.searchGalleryDesc ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchGalleryDesc = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '搜索低愿力标签',
                        value: _advanceSearch.searchLowPowerTags ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchLowPowerTags = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '搜索差评标签',
                        value: _advanceSearch.searchDownvotedTags ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchDownvotedTags = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '搜索被删除的画廊',
                        value: _advanceSearch.searchExpunged ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchExpunged = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '最低评分',
                        value: _advanceSearch.searchWithminRating ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.searchWithminRating = value;
                          });
                        },
                      ),
                      CupertinoSlidingSegmentedControl<int>(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: <int, Widget>{
                            2: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('2星'),
                            ),
                            3: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('3星'),
                            ),
                            4: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('4星'),
                            ),
                            5: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('5星'),
                            ),
                          },
                          groupValue: _advanceSearch.minRating ?? 2,
                          onValueChanged: (int value) {
                            setState(() {
                              _advanceSearch.minRating = value;
                            });
                          }),
                      Row(
                        children: <Widget>[
                          AdvanceSearchSwitchItem(
                            title: '页数',
                            expand: false,
                            value: _advanceSearch.searchBetweenpage ?? false,
                            onChanged: (bool value) {
                              setState(() {
                                _advanceSearch.searchBetweenpage = value;
                              });
                            },
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 50,
                            height: 28,
                            child: CupertinoTextField(
                              controller: _statrPageCtrl,
                              keyboardType: TextInputType.number,
                              cursorHeight: 14,
                              enabled:
                                  _advanceSearch.searchBetweenpage ?? false,
                              style: const TextStyle(
                                height: 1,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                          ),
                          const Text('到'),
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 50,
                            height: 28,
                            child: CupertinoTextField(
                              controller: _endPageCtrl,
                              keyboardType: TextInputType.number,
                              cursorHeight: 14,
                              enabled:
                                  _advanceSearch.searchBetweenpage ?? false,
                              style: const TextStyle(
                                height: 1,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: const Text('禁用默认排除项')),
                      AdvanceSearchSwitchItem(
                        title: '语言',
                        value: _advanceSearch.disableDFLanguage ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.disableDFLanguage = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '上传者',
                        value: _advanceSearch.disableDFUploader ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.disableDFUploader = value;
                          });
                        },
                      ),
                      AdvanceSearchSwitchItem(
                        title: '标签',
                        value: _advanceSearch.disableDFTags ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _advanceSearch.disableDFTags = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdvanceSearchSwitchItem extends StatelessWidget {
  const AdvanceSearchSwitchItem(
      {Key key, this.value, this.onChanged, this.title, this.expand = true})
      : super(key: key);

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(title),
          if (expand) const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class GalleryBase {
  /// 设置类型筛选
  /// 弹出toast 通过Provider 全局 维护cat的值
  Future<void> showFilterSetting(BuildContext context,
      {bool showAdevance = false}) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // Global.logger.v('_setCats showCupertinoDialog builder');
        int _catNum =
            Provider.of<EhConfigModel>(context, listen: false).catFilter;
        // AdvanceSearchModel
        final AdvanceSearchModel advanceSearchModel =
            Provider.of<AdvanceSearchModel>(context, listen: false);
        bool _enableAdvance = advanceSearchModel.enable;

        return CupertinoAlertDialog(
          title: const Text('搜索'),
          content: showAdevance
              ? GalleryFilter(
                  catNum: _catNum,
                  catNumChanged: (int toNum) {
                    _catNum = toNum;
                  },
                  advanceSearchValue: _enableAdvance,
                  advanceSearchSwitch: (bool value) {
                    _enableAdvance = value;
                  })
              : Container(
                  height: 180,
                  child: SingleChildScrollView(
                    child: GalleryCatFilter(
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      value: _catNum,
                      onChanged: (int toNum) {
                        _catNum = toNum;
                      },
                    ),
                  ),
                ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Provider.of<EhConfigModel>(context, listen: false).catFilter =
                    _catNum;
                advanceSearchModel.enable = _enableAdvance;
                // Global.logger.v(advanceSearchModel.urlPara);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/// 列表加载异常时的默认页面
/// 包含一个点击回调 可用于触发重载
class GalleryErrorPage extends StatelessWidget {
  const GalleryErrorPage({Key key, this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoButton(
        onPressed: onTap,
        child: Icon(
          FontAwesomeIcons.syncAlt,
          size: 50,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey, context),
        ),
      ),
    );
  }
}
