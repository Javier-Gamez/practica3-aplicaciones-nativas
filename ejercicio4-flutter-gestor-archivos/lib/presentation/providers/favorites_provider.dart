import 'package:flutter/material.dart';

import '../../data/services/local_store.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._store);

  final LocalStore _store;

  List<String> get favorites => _store.favorites;
  List<String> get recents => _store.recents;

  bool isFavorite(String path) => _store.isFavorite(path);

  Future<void> toggle(String path) async {
    await _store.toggleFavorite(path);
    notifyListeners();
  }

  Future<void> registerOpened(String path) async {
    await _store.pushRecent(path);
    notifyListeners();
  }

  Future<void> clearRecents() async {
    await _store.clearRecents();
    notifyListeners();
  }
}
