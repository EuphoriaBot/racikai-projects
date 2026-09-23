import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadFromStorage() async {
    final savedMode = LocalStorageService.themeMode;

    switch (savedMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await LocalStorageService.saveThemeMode(mode.name);

    notifyListeners();
  }

  String get modeLabel {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Terang';

      case ThemeMode.dark:
        return 'Gelap';

      case ThemeMode.system:
        return 'Sistem';
    }
  }
}
