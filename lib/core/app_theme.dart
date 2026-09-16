import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الألوان — مبني على شعار "يمني حول العالم" الرسمي (كحلي + ذهبي).
abstract final class AppColors {
  static const ink = Color(0xFF14232D);
  static const navy = Color(0xFF0B4F73);
  static const navyDark = Color(0xFF073349);
  static const navyLight = Color(0xFF1E6E93);
  static const skyTint = Color(0xFFE4EEF2); // تينت فاتح من الكحلي
  static const gold = Color(0xFFC9A063);
  static const goldDark = Color(0xFFA97F45);
  static const goldLight = Color(0xFFE3C088);
  // خلفية دافئة كريمية تتماشى مع دفء الذهبي وصورة الغلاف
  static const canvas = Color(0xFFFAF6EF);
  static const line = Color(0xFFE7E1D3);
  static const muted = Color(0xFF64707A);
}

/// تدرجات جاهزة على الأزرار والعناصر المميزة.
abstract final class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.navyLight, AppColors.navyDark],
  );

  static const golden = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.gold, AppColors.goldDark],
  );
}

/// ظلال ملوّنة بلون العلامة بدل الظل الرمادي العام.
abstract final class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.14),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

abstract final class AppRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const pill = 999.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: Colors.white,
      error: const Color(0xFFB42318),
    );

    final headlineFont = GoogleFonts.cairoTextTheme();
    final bodyFont = GoogleFonts.ibmPlexSansArabicTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: TextTheme(
        displaySmall: headlineFont.displaySmall?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          height: 1.16,
        ),
        headlineMedium: headlineFont.headlineMedium?.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleLarge: headlineFont.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: headlineFont.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: bodyFont.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.55,
          color: AppColors.ink,
        ),
        bodyMedium: bodyFont.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.45,
          color: AppColors.muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headlineFont.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        side: const BorderSide(color: AppColors.line),
        selectedColor: AppColors.skyTint,
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.skyTint,
        elevation: 0,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.line,
    );
  }
}
