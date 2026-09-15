import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../data/models/file_item.dart';
import '../../data/services/file_service.dart';
import '../../data/services/local_store.dart';

enum _ClipboardMode { copy, cut }

class FileBrowserProvider extends ChangeNotifier {
  FileBrowserProvider(this._service, this._store);

  final FileService _service;
  final LocalStore _store;

  String _rootPath = '';
  String _currentPath = '';
  List<FileItem> _items = [];
  String _searchQuery = '';
  bool _loading = true;

  FileItem? _clipboardItem;
  _ClipboardMode? _clipboardMode;

  String get currentPath => _currentPath;
  bool get isAtRoot => _currentPath == _rootPath;
  bool get loading => _loading;
  bool get canPaste => _clipboardItem != null;
  SortBy get sortBy => _store.sortBy;

  List<FileItem> get items {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  /// Path segments between the sandbox root and the current folder, used to
  /// render the breadcrumb bar required by the practice.
  List<String> get breadcrumbs {
    final relative = p.relative(_currentPath, from: _rootPath);
    if (relative == '.') return [];
    return p.split(relative);
  }

  Future<void> init() async {
    final root = await _service.rootDirectory;
    _rootPath = root.path;
    final last = _store.lastFolder;
    _currentPath = (last != null && Directory(last).existsSync()) ? last : _rootPath;
    await _load();
  }

  Future<void> _load() async {
    _loading = true;
    notifyListeners();
    _items = await _service.listDirectory(_currentPath, sortBy: _store.sortBy);
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setSortBy(SortBy sortBy) async {
    await _store.setSortBy(sortBy);
    await _load();
  }

  Future<void> navigateInto(FileItem item) async {
    if (!item.isDirectory) return;
    _currentPath = item.path;
    await _store.setLastFolder(_currentPath);
    _searchQuery = '';
    await _load();
  }

  Future<bool> navigateUp() async {
    if (_currentPath == _rootPath) return false;
    _currentPath = p.dirname(_currentPath);
    await _store.setLastFolder(_currentPath);
    _searchQuery = '';
    await _load();
    return true;
  }

  Future<void> navigateToBreadcrumb(int index) async {
    final segments = breadcrumbs.take(index + 1).toList();
    _currentPath = p.joinAll([_rootPath, ...segments]);
    await _store.setLastFolder(_currentPath);
    await _load();
  }

  Future<void> createFolder(String name) async {
    await _service.createFolder(_currentPath, name);
    await _load();
  }

  Future<void> rename(FileItem item, String newName) async {
    await _service.rename(item, newName);
    await _load();
  }

  Future<void> delete(FileItem item) async {
    await _service.delete(item);
    await _load();
  }

  void copyToClipboard(FileItem item) {
    _clipboardItem = item;
    _clipboardMode = _ClipboardMode.copy;
    notifyListeners();
  }

  void cutToClipboard(FileItem item) {
    _clipboardItem = item;
    _clipboardMode = _ClipboardMode.cut;
    notifyListeners();
  }

  Future<void> pasteHere() async {
    final item = _clipboardItem;
    final mode = _clipboardMode;
    if (item == null || mode == null) return;
    if (mode == _ClipboardMode.copy) {
      await _service.copyInto(item, _currentPath);
    } else {
      await _service.moveInto(item, _currentPath);
    }
    _clipboardItem = null;
    _clipboardMode = null;
    await _load();
  }

  Future<int> importFiles() async {
    final imported = await _service.importFiles(_currentPath);
    await _load();
    return imported.length;
  }

  Future<String> readText(String path) => _service.readText(path);

  String formatSize(int bytes) => _service.formatSize(bytes);
}
