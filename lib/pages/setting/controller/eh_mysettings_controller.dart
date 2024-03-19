import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const kEhSettings = EhSettings(profilelist: [], xn: [], xl: [], favorites: []);

class EhMySettingsController extends GetxController {
  // Rx<EhSettings> ehSettings = const EhSettings().obs;

  final _ehSetting = kEhSettings.obs;
  EhSettings get ehSetting => _ehSetting.value;
  set ehSetting(EhSettings val) => _ehSetting.value = val;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool val) => _isLoading.value = val;

  final EhSettingService ehSettingService = Get.find();

  void printParam() {
    logger.d('${_ehSetting.value.postParam}');
  }

  Future<EhSettings?> loadData({bool refresh = false}) async {
    final selectedProfile = await getCookieValue('sp');
    try {
      final uconfig = await getEhSettings(
        refresh: refresh || Global.forceRefreshUconfig,
        selectProfile: selectedProfile,
      );
      isLoading = false;

      if (uconfig != null) {
        Global.forceRefreshUconfig = false;
        ehSetting = uconfig;
        return uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      // isLoading = false;
    }
    return null;
  }

  Future<void> reloadData() async {
    await loadData(refresh: true);
  }

  Future<void> changeProfile(String profileSet) async {
    isLoading = true;
    ehSetting = kEhSettings;
    try {
      await setCookie('sp', profileSet);
      ehSettingService.selectProfile = profileSet;
      // await loadData(refresh: true);
      // await showCookie();
      final uconfig = await changeEhProfile(profileSet, refresh: true);
      if (uconfig != null) {
        ehSetting = uconfig;
      } else {
        Global.forceRefreshUconfig = true;
      }

      isLoading = false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  bool get selectedIsDefault =>
      (ehSetting.profileSelected?.isNotEmpty ?? false) &&
      (ehSetting.profileSelected == ehSetting.defaultProfile);

  Future<void> renameProfile() async {
    if (ehSetting.profileSelected == null) {
      return;
    }
    final _selected = ehSetting.profileSelected!;
    final _currName = ehSetting.profilelist
        .firstWhereOrNull((element) => element.selected)
        ?.name;
    final name = await _dialogGetProfileName(text: _currName);
    if (name == null || _currName == name || name.isEmpty) {
      return;
    }

    isLoading = true;
    ehSetting = kEhSettings;
    try {
      final uconfig = await renameEhProfile(_selected, name);
      loadData(refresh: true);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> setDefaultProfile() async {
    if (ehSetting.profileSelected == null) {
      return;
    }
    final _selected = ehSetting.profileSelected!;
    isLoading = true;
    ehSetting = kEhSettings;
    try {
      logger.d('setDefaultProfile $_selected');
      final uconfig = await setDefauleEhProfile(_selected);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> deleteProfile() async {
    if (ehSetting.profileSelected == null || !await _dialogDeleteProfile()) {
      return;
    }

    final _selected = ehSetting.profileSelected!;
    isLoading = true;
    ehSetting = kEhSettings;
    try {
      await setCookie('sp', _selected);
      ehSettingService.selectProfile = _selected;
      final uconfig = await deleteEhProfile(_selected);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> crtNewProfile() async {
    final name = await _dialogGetProfileName();
    if (name == null) {
      return;
    }

    isLoading = true;
    ehSetting = kEhSettings;
    try {
      final uconfig = await createEhProfile(name);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      // showCookie();
    }
  }

  Future<void> applyProfile() async {
    isLoading = true;
    try {
      final uconfig = await applyEhProfile(ehSetting.postParam);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<String?> _dialogGetProfileName({String? text}) async {
    final _textEditingController = TextEditingController(text: text);
    final name = await showCupertinoDialog<String>(
        context: Get.context!,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Profile Name'),
            content: CupertinoTextField(
              controller: _textEditingController,
              decoration: BoxDecoration(
                color: ehTheme.favnoteTextFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(L10n.of(context).cancel),
                onPressed: Get.back,
              ),
              CupertinoDialogAction(
                child: Text(L10n.of(context).ok),
                onPressed: () => Get.back(result: _textEditingController.text),
              ),
            ],
          );
        });

    return name;
  }

  Future<bool> _dialogDeleteProfile() async {
    final rult = await showCupertinoDialog<bool>(
            context: Get.context!,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Delete Profile'),
                actions: [
                  CupertinoDialogAction(
                    child: Text(L10n.of(context).cancel),
                    onPressed: Get.back,
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      L10n.of(context).ok,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => Get.back(result: true),
                  ),
                ],
              );
            }) ??
        false;
    return rult;
  }
}
