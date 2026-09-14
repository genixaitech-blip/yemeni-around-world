import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF17211B);
  static const forest = Color(0xFF126A4A);
  static const mint = Color(0xFFE6F3ED);
  static const coral = Color(0xFFE9684A);
  static const gold = Color(0xFFD5A62E);
  static const canvas = Color(0xFFF8F9F6);
  static const line = Color(0xFFE3E7E2);
  static const muted = Color(0xFF66736B);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
      primary: AppColors.forest,
      secondary: AppColors.coral,
      surface: Colors.white,
      error: const Color(0xFFB42318),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.16),
        headlineMedium: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.ink),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: AppColors.ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        side: const BorderSide(color: AppColors.line),
        selectedColor: AppColors.mint,
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mint,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      dividerColor: AppColors.line,
    );
  }
}
