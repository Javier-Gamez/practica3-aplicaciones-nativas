import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/file_item.dart';
import '../../data/services/file_service.dart';
import '../providers/favorites_provider.dart';
import '../providers/file_browser_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/file_list_tile.dart';
import 'file_viewer_screen.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<FileBrowserProvider>();
    final favorites = context.watch<FavoritesProvider>();

    return PopScope(
      canPop: browser.isAtRoot,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await browser.navigateUp();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar en esta carpeta...',
                    border: InputBorder.none,
                  ),
                  onChanged: browser.setSearchQuery,
                )
              : const Text('Gestor de Archivos'),
          actions: [
            IconButton(
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: () => setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchController.clear();
                  browser.setSearchQuery('');
                }
              }),
            ),
            PopupMenuButton<SortBy>(
              icon: const Icon(Icons.sort),
              onSelected: browser.setSortBy,
              itemBuilder: (context) => const [
                PopupMenuItem(value: SortBy.name, child: Text('Ordenar por nombre')),
                PopupMenuItem(value: SortBy.date, child: Text('Ordenar por fecha')),
                PopupMenuItem(value: SortBy.size, child: Text('Ordenar por tamaño')),
              ],
            ),
            if (browser.canPaste)
              IconButton(
                icon: const Icon(Icons.paste),
                tooltip: 'Pegar aquí',
                onPressed: browser.pasteHere,
              ),
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Cambiar tema',
              onPressed: () => _showThemePicker(context),
            ),
          ],
        ),
        body: Column(
          children: [
            BreadcrumbBar(
              segments: browser.breadcrumbs,
              onTapRoot: () async {
                while (await browser.navigateUp()) {}
              },
              onTapSegment: browser.navigateToBreadcrumb,
            ),
            const Divider(height: 1),
            Expanded(
              child: browser.loading
                  ? const Center(child: CircularProgressIndicator())
                  : browser.items.isEmpty
                      ? const Center(child: Text('Esta carpeta está vacía'))
                      : RefreshIndicator(
                          onRefresh: browser.refresh,
                          child: ListView.builder(
                            itemCount: browser.items.length,
                            itemBuilder: (context, index) {
                              final item = browser.items[index];
                              return Dismissible(
                                key: ValueKey(item.path),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Theme.of(context).colorScheme.error,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (_) => _confirmDelete(context, item),
                                onDismissed: (_) => browser.delete(item),
                                child: FileListTile(
                                  item: item,
                                  isFavorite: favorites.isFavorite(item.path),
                                  sizeLabel: browser.formatSize(item.sizeBytes),
                                  onFavoriteTap: () => favorites.toggle(item.path),
                                  onTap: () => _openItem(context, item, browser, favorites),
                                  onLongPress: () => _showContextMenu(context, item, browser, favorites),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'folder') {
              await _promptNewFolder(context, browser);
            } else if (value == 'import') {
              final count = await browser.importFiles();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$count archivo(s) importado(s)')));
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'folder', child: ListTile(leading: Icon(Icons.create_new_folder), title: Text('Nueva carpeta'))),
            PopupMenuItem(value: 'import', child: ListTile(leading: Icon(Icons.file_upload), title: Text('Importar archivo'))),
          ],
          child: const FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, FileItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "${item.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openItem(
    BuildContext context,
    FileItem item,
    FileBrowserProvider browser,
    FavoritesProvider favorites,
  ) async {
    if (item.isDirectory) {
      browser.navigateInto(item);
      return;
    }
    await favorites.registerOpened(item.path);
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => FileViewerScreen(item: item)));
  }

  Future<void> _promptNewFolder(BuildContext context, FileBrowserProvider browser) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await browser.createFolder(name);
    }
  }

  Future<void> _promptRename(BuildContext context, FileBrowserProvider browser, FileItem item) async {
    final controller = TextEditingController(text: item.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && name != item.name) {
      await browser.rename(item, name);
    }
  }

  void _showThemePicker(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final option in AppThemeOption.values)
              Consumer<ThemeProvider>(
                builder: (context, provider, _) => RadioListTile<AppThemeOption>(
                  title: Text(option.label),
                  value: option,
                  groupValue: provider.option,
                  onChanged: (value) {
                    if (value != null) themeProvider.setOption(value);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    FileItem item,
    FileBrowserProvider browser,
    FavoritesProvider favorites,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renombrar'),
              onTap: () {
                Navigator.pop(context);
                _promptRename(context, browser, item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar'),
              onTap: () {
                browser.copyToClipboard(item);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cut),
              title: const Text('Cortar'),
              onTap: () {
                browser.cutToClipboard(item);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(favorites.isFavorite(item.path) ? Icons.star : Icons.star_border),
              title: Text(favorites.isFavorite(item.path) ? 'Quitar de favoritos' : 'Agregar a favoritos'),
              onTap: () {
                favorites.toggle(item.path);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                if (await _confirmDelete(context, item)) {
                  await browser.delete(item);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
