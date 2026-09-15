import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/file_item.dart';

IconData iconForKind(FileKind kind) {
  switch (kind) {
    case FileKind.folder:
      return Icons.folder;
    case FileKind.image:
      return Icons.image;
    case FileKind.text:
      return Icons.description;
    case FileKind.audio:
      return Icons.audiotrack;
    case FileKind.video:
      return Icons.movie;
    case FileKind.pdf:
      return Icons.picture_as_pdf;
    case FileKind.archive:
      return Icons.folder_zip;
    case FileKind.other:
      return Icons.insert_drive_file;
  }
}

class FileListTile extends StatelessWidget {
  const FileListTile({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.sizeLabel,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteTap,
  });

  final FileItem item;
  final bool isFavorite;
  final String sizeLabel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy HH:mm').format(item.modified);
    return ListTile(
      leading: Icon(iconForKind(item.kind), size: 32),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.isDirectory ? dateLabel : '$sizeLabel · $dateLabel'),
      trailing: IconButton(
        icon: Icon(isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null),
        onPressed: onFavoriteTap,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
