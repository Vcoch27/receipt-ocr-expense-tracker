import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light = _make(Brightness.light);
  static ThemeData dark = _make(Brightness.dark);

  static ThemeData _make(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF164A7B),
      brightness: brightness,
    );
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF101815)
          : const Color(0xFFF6F8F7),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1A2420) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
      visualDensity: VisualDensity.standard,
    );
  }
}
