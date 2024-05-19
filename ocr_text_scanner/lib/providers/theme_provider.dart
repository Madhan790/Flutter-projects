import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;

  ThemeProvider(String? themeMode) {
    _currentTheme = themeMode == 'dark' ? ThemeData.dark() : ThemeData.light();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> toggleTheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentTheme = _currentTheme.brightness == Brightness.light
        ? ThemeData.dark()
        : ThemeData.light();
    await prefs.setString(
      'themeMode',
      _currentTheme.brightness == Brightness.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  void toggleThemeFromProvider(BuildContext context) {
    toggleTheme(context);
  }
}
