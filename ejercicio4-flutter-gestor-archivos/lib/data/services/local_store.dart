import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../services/file_service.dart';

/// Local persistence for the file manager: session preferences (theme, sort
/// order, last visited folder), a persistent favorites set and a recent
/// files history. Backed by Hive, the multiplatform equivalent requested by
/// the practice (UserDefaults/Core Data on iOS -> Hive/sqflite on Flutter).
class LocalStore {
  static const _prefsBoxName = 'prefs';
  static const _favoritesBoxName = 'favorites';
  static const _recentsBoxName = 'recents';

  late Box _prefsBox;
  late Box _favoritesBox;
  late Box _recentsBox;

  static const _maxRecents = 30;

  Future<void> init() async {
    await Hive.initFlutter();
    _prefsBox = await Hive.openBox(_prefsBoxName);
    _favoritesBox = await Hive.openBox(_favoritesBoxName);
    _recentsBox = await Hive.openBox(_recentsBoxName);
  }

  // --- Preferences -----------------------------------------------------

  AppThemeOption get themeOption {
    final raw = _prefsBox.get('themeOption', defaultValue: 'guinda') as String;
    return AppThemeOption.values.firstWhere((e) => e.name == raw, orElse: () => AppThemeOption.guinda);
  }

  Future<void> setThemeOption(AppThemeOption option) => _prefsBox.put('themeOption', option.name);

  SortBy get sortBy {
    final raw = _prefsBox.get('sortBy', defaultValue: 'name') as String;
    return SortBy.values.firstWhere((e) => e.name == raw, orElse: () => SortBy.name);
  }

  Future<void> setSortBy(SortBy sortBy) => _prefsBox.put('sortBy', sortBy.name);

  String? get lastFolder => _prefsBox.get('lastFolder') as String?;

  Future<void> setLastFolder(String path) => _prefsBox.put('lastFolder', path);

  // --- Favorites ---------------------------------------------------------

  List<String> get favorites => _favoritesBox.values.cast<String>().toList();

  bool isFavorite(String path) => _favoritesBox.containsKey(path);

  Future<void> toggleFavorite(String path) async {
    if (_favoritesBox.containsKey(path)) {
      await _favoritesBox.delete(path);
    } else {
      await _favoritesBox.put(path, path);
    }
  }

  // --- Recents -------------------------------------------------------------

  List<String> get recents => _recentsBox.values.cast<String>().toList();

  Future<void> pushRecent(String path) async {
    final current = recents..remove(path);
    current.insert(0, path);
    final trimmed = current.take(_maxRecents).toList();
    await _recentsBox.clear();
    for (var i = 0; i < trimmed.length; i++) {
      await _recentsBox.put(i, trimmed[i]);
    }
  }

  Future<void> clearRecents() => _recentsBox.clear();
}
