import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/file_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/file_browser_provider.dart';
import '../widgets/file_list_tile.dart';
import 'file_viewer_screen.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final browser = context.read<FileBrowserProvider>();
    final paths = favorites.recents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpiar historial',
            onPressed: paths.isEmpty ? null : favorites.clearRecents,
          ),
        ],
      ),
      body: paths.isEmpty
          ? const Center(child: Text('No has abierto archivos todavía'))
          : ListView.builder(
              itemCount: paths.length,
              itemBuilder: (context, index) {
                final path = paths[index];
                if (!File(path).existsSync()) return const SizedBox.shrink();
                return FutureBuilder<FileItem>(
                  future: FileItem.fromEntity(File(path)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final item = snapshot.data!;
                    return FileListTile(
                      item: item,
                      isFavorite: favorites.isFavorite(path),
                      sizeLabel: browser.formatSize(item.sizeBytes),
                      onFavoriteTap: () => favorites.toggle(path),
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => FileViewerScreen(item: item))),
                      onLongPress: () {},
                    );
                  },
                );
              },
            ),
    );
  }
}
