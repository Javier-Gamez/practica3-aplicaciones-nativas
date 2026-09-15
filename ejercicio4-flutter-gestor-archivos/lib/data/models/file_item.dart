import 'dart:io';

enum FileKind { folder, image, text, audio, video, pdf, archive, other }

class FileItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final DateTime modified;

  const FileItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.sizeBytes,
    required this.modified,
  });

  static Future<FileItem> fromEntity(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final isDir = entity is Directory;
    return FileItem(
      path: entity.path,
      name: entity.uri.pathSegments.where((s) => s.isNotEmpty).isEmpty
          ? entity.path
          : entity.uri.pathSegments.where((s) => s.isNotEmpty).last,
      isDirectory: isDir,
      sizeBytes: isDir ? 0 : stat.size,
      modified: stat.modified,
    );
  }

  String get extension {
    if (isDirectory) return '';
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  FileKind get kind {
    if (isDirectory) return FileKind.folder;
    switch (extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'bmp':
        return FileKind.image;
      case 'txt':
      case 'md':
      case 'json':
      case 'dart':
      case 'swift':
      case 'kt':
      case 'yaml':
      case 'yml':
      case 'log':
        return FileKind.text;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
        return FileKind.audio;
      case 'mp4':
      case 'mov':
      case 'avi':
        return FileKind.video;
      case 'pdf':
        return FileKind.pdf;
      case 'zip':
      case 'rar':
      case '7z':
        return FileKind.archive;
      default:
        return FileKind.other;
    }
  }
}
