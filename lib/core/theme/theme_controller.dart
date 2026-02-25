import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global controller for handling application themes.
/// Implements Singleton pattern to allow easy access across the widget tree
/// without requiring complex dependency injection modifications in existing screens.
class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  
  /// Factory constructor returning the singleton instance.
  factory ThemeController() => _instance;
  
  ThemeController._internal();

  SharedPreferences? _prefs;
  static const String _themeKey = 'is_dark_mode';

  bool _isDarkMode = false;
  
  /// Returns true if dark mode is active.
  bool get isDarkMode => _isDarkMode;
  
  /// Returns the current ThemeMode based on user preference.
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initializes the controller with local storage.
  /// 
  /// [prefs] Instance of SharedPreferences.
  void initialize(SharedPreferences prefs) {
    _prefs = prefs;
    _isDarkMode = _prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  /// Toggles the current theme and persists the choice.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}