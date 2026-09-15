import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/local_store.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._store) : _option = _store.themeOption;

  final LocalStore _store;
  AppThemeOption _option;

  AppThemeOption get option => _option;

  Future<void> setOption(AppThemeOption option) async {
    if (option == _option) return;
    _option = option;
    await _store.setThemeOption(option);
    notifyListeners();
  }
}
