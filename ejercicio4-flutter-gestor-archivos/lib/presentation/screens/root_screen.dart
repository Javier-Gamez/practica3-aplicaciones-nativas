import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'file_browser_screen.dart';
import 'recents_screen.dart';

/// Hosts the three main sections of the app behind a bottom navigation bar,
/// the pattern recommended by Material Design 3 for top-level destinations.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [
    FileBrowserScreen(),
    FavoritesScreen(),
    RecentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Archivos'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Recientes'),
        ],
      ),
    );
  }
}
