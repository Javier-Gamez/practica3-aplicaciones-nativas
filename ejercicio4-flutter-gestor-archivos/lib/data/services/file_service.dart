import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/file_item.dart';

enum SortBy { name, date, size }

/// Wraps every filesystem operation the file manager needs, scoped to the
/// app's own sandbox directory (mirrors the iOS sandbox restriction from
/// Ejercicio 2: the app never reads or writes outside its own Documents dir).
class FileService {
  Directory? _root;

  Future<Directory> get rootDirectory async {
    _root ??= await getApplicationDocumentsDirectory();
    return _root!;
  }

  Future<List<FileItem>> listDirectory(String path, {SortBy sortBy = SortBy.name}) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];
    final entities = await dir.list().toList();
    final items = await Future.wait(entities.map(FileItem.fromEntity));

    items.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      switch (sortBy) {
        case SortBy.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortBy.date:
          return b.modified.compareTo(a.modified);
        case SortBy.size:
          return b.sizeBytes.compareTo(a.sizeBytes);
      }
    });
    return items;
  }

  Future<Directory> createFolder(String parentPath, String name) async {
    final dir = Directory(p.join(parentPath, name));
    return dir.create(recursive: false);
  }

  Future<String> rename(FileItem item, String newName) async {
    final newPath = p.join(p.dirname(item.path), newName);
    if (item.isDirectory) {
      await Directory(item.path).rename(newPath);
    } else {
      await File(item.path).rename(newPath);
    }
    return newPath;
  }

  Future<void> delete(FileItem item) async {
    if (item.isDirectory) {
      await Directory(item.path).delete(recursive: true);
    } else {
      await File(item.path).delete();
    }
  }

  Future<void> copyInto(FileItem item, String destDir) async {
    if (item.isDirectory) {
      await _copyDirectory(Directory(item.path), Directory(p.join(destDir, item.name)));
    } else {
      await File(item.path).copy(p.join(destDir, item.name));
    }
  }

  Future<void> moveInto(FileItem item, String destDir) async {
    final newPath = p.join(destDir, item.name);
    if (item.isDirectory) {
      await _copyDirectory(Directory(item.path), Directory(newPath));
      await Directory(item.path).delete(recursive: true);
    } else {
      await File(item.path).rename(newPath);
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }

  Future<String> readText(String path) => File(path).readAsString();

  /// Imports one or more files from outside the sandbox (Files / Photos /
  /// external storage) using the system document picker, copying each one
  /// into [destDir]. Mirrors UIDocumentPickerViewController on iOS.
  Future<List<File>> importFiles(String destDir) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return [];
    final imported = <File>[];
    for (final picked in result.files) {
      final sourcePath = picked.path;
      if (sourcePath == null) continue;
      final dest = await File(sourcePath).copy(p.join(destDir, picked.name));
      imported.add(dest);
    }
    return imported;
  }

  String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }
}
