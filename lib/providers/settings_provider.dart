// Provider for managing app settings

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import '../models/enums.dart';

/// Provider for managing user settings and preferences
class SettingsProvider extends ChangeNotifier {
  SortBy _currentSort = SortBy.createTime;
  bool _alwaysOnTop = false;
  SharedPreferences? _prefs;

  /// Get current sort preference
  SortBy get currentSort => _currentSort;

  /// Get always on top preference
  bool get alwaysOnTop => _alwaysOnTop;

  /// Load preferences from storage
  Future<void> loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final sortIndex = _prefs?.getInt('sort_by') ?? SortBy.createTime.toInt();
    _currentSort = SortByExtension.fromInt(sortIndex);
    _alwaysOnTop = _prefs?.getBool('always_on_top') ?? false;
    notifyListeners();
  }

  /// Set sort preference and save
  Future<void> setSortBy(SortBy sortBy) async {
    _currentSort = sortBy;
    await _prefs?.setInt('sort_by', sortBy.toInt());
    notifyListeners();
  }

  /// Set always on top preference and save
  Future<void> setAlwaysOnTop(bool value) async {
    windowManager.setAlwaysOnTop(value);
    _alwaysOnTop = value;
    await _prefs?.setBool('always_on_top', value);
    notifyListeners();
  }
}
