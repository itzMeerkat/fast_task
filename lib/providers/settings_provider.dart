// Provider for managing app settings

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';

/// Provider for managing user settings and preferences
class SettingsProvider extends ChangeNotifier {
  SortBy _currentSort = SortBy.createTime;
  SharedPreferences? _prefs;

  /// Get current sort preference
  SortBy get currentSort => _currentSort;

  /// Load preferences from storage
  Future<void> loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final sortIndex = _prefs?.getInt('sort_by') ?? SortBy.createTime.toInt();
    _currentSort = SortByExtension.fromInt(sortIndex);
    notifyListeners();
  }

  /// Set sort preference and save
  Future<void> setSortBy(SortBy sortBy) async {
    _currentSort = sortBy;
    await _prefs?.setInt('sort_by', sortBy.toInt());
    notifyListeners();
  }
}

