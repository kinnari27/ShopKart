import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_kart/injection/injection.dart';

final themeViewModelProvider = NotifierProvider<ThemeViewModel, ThemeMode>(
  ThemeViewModel.new,
);

class ThemeViewModel extends Notifier<ThemeMode> {
  SharedPreferences get _preferences => sl();

  @override
  ThemeMode build() {
    final value = _preferences.getString('theme_mode') ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    await _preferences.setString('theme_mode', mode.name);
    state = mode;
  }
}
