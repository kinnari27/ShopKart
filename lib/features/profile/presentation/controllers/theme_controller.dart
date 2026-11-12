import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_kart/injection/injection.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final SharedPreferences _preferences;

  ThemeController({SharedPreferences? preferences})
      : _preferences = preferences ?? sl<SharedPreferences>();

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final value = _preferences.getString('theme_mode') ?? 'system';
    themeMode.value = ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _preferences.setString('theme_mode', mode.name);
    Get.changeThemeMode(mode);
  }
}
