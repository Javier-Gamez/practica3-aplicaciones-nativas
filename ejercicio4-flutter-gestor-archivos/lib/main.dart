import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/file_service.dart';
import 'data/services/local_store.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/file_browser_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = LocalStore();
  await store.init();

  final fileService = FileService();
  final fileBrowserProvider = FileBrowserProvider(fileService, store);
  await fileBrowserProvider.init();

  runApp(GestorArchivosApp(
    store: store,
    fileService: fileService,
    fileBrowserProvider: fileBrowserProvider,
  ));
}

class GestorArchivosApp extends StatelessWidget {
  const GestorArchivosApp({
    super.key,
    required this.store,
    required this.fileService,
    required this.fileBrowserProvider,
  });

  final LocalStore store;
  final FileService fileService;
  final FileBrowserProvider fileBrowserProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(store)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(store)),
        ChangeNotifierProvider.value(value: fileBrowserProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Gestor de Archivos - ESCOM/IPN',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: AppTheme.light(themeProvider.option),
            darkTheme: AppTheme.dark(themeProvider.option),
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
