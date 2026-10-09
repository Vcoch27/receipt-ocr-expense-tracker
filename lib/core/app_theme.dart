import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const ink = Color(0xFF003E52);
  static const teal = Color(0xFF0D5C75);
  static const mint = Color(0xFF2BB696);

  static ThemeData light = _make(Brightness.light);
  static ThemeData dark = _make(Brightness.dark);

  static ThemeData _make(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: brightness,
    );
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF101815)
          : const Color(0xFFF6FAF9),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF192723) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .35)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: dark
            ? const Color(0xFF18231F)
            : const Color(0xFFF6FAF9),
        indicatorColor: dark
            ? const Color(0xFF244C4E)
            : const Color(0xFFD6F1EB),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        headlineSmall: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
      visualDensity: VisualDensity.standard,
    );
  }
}
