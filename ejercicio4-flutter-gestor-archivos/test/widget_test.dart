import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_archivos_flutter/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme builds light and dark themes for both brands', (tester) async {
    for (final option in AppThemeOption.values) {
      expect(AppTheme.light(option), isA<ThemeData>());
      expect(AppTheme.dark(option), isA<ThemeData>());
    }
  });
}
