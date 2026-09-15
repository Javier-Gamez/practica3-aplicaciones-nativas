import 'package:flutter/material.dart';

/// The two brand themes required by the practice: Guinda (IPN) and Azul (ESCOM).
enum AppThemeOption { guinda, azul }

extension AppThemeOptionX on AppThemeOption {
  String get label => switch (this) {
        AppThemeOption.guinda => 'Guinda (IPN)',
        AppThemeOption.azul => 'Azul (ESCOM)',
      };

  Color get seed => switch (this) {
        AppThemeOption.guinda => const Color(0xFF8C1D40),
        AppThemeOption.azul => const Color(0xFF0057B7),
      };
}

class AppTheme {
  AppTheme._();

  static ThemeData light(AppThemeOption option) => _build(option, Brightness.light);

  static ThemeData dark(AppThemeOption option) => _build(option, Brightness.dark);

  static ThemeData _build(AppThemeOption option, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: option.seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
