import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/file_item.dart';
import '../providers/file_browser_provider.dart';

/// Built-in preview for text and image files -- the Flutter equivalent of
/// QLPreviewController (Quick Look) used on the iOS version (Ejercicio 2).
class FileViewerScreen extends StatefulWidget {
  const FileViewerScreen({super.key, required this.item});

  final FileItem item;

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  double _rotationTurns = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FileBrowserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          if (widget.item.kind == FileKind.image)
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => setState(() => _rotationTurns = (_rotationTurns + 0.25) % 1),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles([XFile(widget.item.path)]),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(FileBrowserProvider provider) {
    switch (widget.item.kind) {
      case FileKind.image:
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 6,
            child: AnimatedRotation(
              turns: _rotationTurns,
              duration: const Duration(milliseconds: 200),
              child: Image.file(File(widget.item.path), fit: BoxFit.contain),
            ),
          ),
        );
      case FileKind.text:
        return FutureBuilder<String>(
          future: provider.readText(widget.item.path),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                snapshot.data!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            );
          },
        );
      default:
        return _UnsupportedPreview(item: widget.item);
    }
  }
}

class _UnsupportedPreview extends StatelessWidget {
  const _UnsupportedPreview({required this.item});

  final FileItem item;

  @override
  Widget build(BuildContext context) {
    final sizeKb = (item.sizeBytes / 1024).toStringAsFixed(1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: min(80, MediaQuery.of(context).size.width / 4)),
            const SizedBox(height: 12),
            Text('No hay vista previa integrada para .${item.extension}'),
            const SizedBox(height: 4),
            Text('$sizeKb KB', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
