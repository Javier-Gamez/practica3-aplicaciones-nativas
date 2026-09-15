import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/file_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/file_browser_provider.dart';
import '../widgets/file_list_tile.dart';
import 'file_viewer_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final browser = context.read<FileBrowserProvider>();
    final paths = favorites.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: paths.isEmpty
          ? const Center(child: Text('Aún no tienes archivos favoritos'))
          : ListView.builder(
              itemCount: paths.length,
              itemBuilder: (context, index) {
                final path = paths[index];
                final entity = FileSystemEntity.typeSync(path);
                if (entity == FileSystemEntityType.notFound) {
                  return const SizedBox.shrink();
                }
                return FutureBuilder<FileItem>(
                  future: FileItem.fromEntity(
                    entity == FileSystemEntityType.directory ? Directory(path) : File(path),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final item = snapshot.data!;
                    return FileListTile(
                      item: item,
                      isFavorite: true,
                      sizeLabel: browser.formatSize(item.sizeBytes),
                      onFavoriteTap: () => favorites.toggle(path),
                      onTap: () {
                        if (item.isDirectory) {
                          browser.navigateInto(item);
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FileViewerScreen(item: item)));
                        }
                      },
                      onLongPress: () {},
                    );
                  },
                );
              },
            ),
    );
  }
}
