import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (value == 'light') {
      _themeMode = ThemeMode.light;
    } else if (value == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      // Premium dark is the default product look.
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
              ? 'light'
              : 'system',
    );
  }

  Future<void> toggleDarkMode() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
