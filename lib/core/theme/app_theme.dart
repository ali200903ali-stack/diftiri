import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF123E63);
  static const navyDark = Color(0xFF082E4D);
  static const emerald = Color(0xFF0DB28E);
  static const emeraldDark = Color(0xFF07836A);
  static const mint = Color(0xFFE8FBF6);
  static const ice = Color(0xFFEDF7FC);
  static const canvas = Color(0xFFF8FCFD);
  static const border = Color(0xFFDCE9EE);
  static const text = Color(0xFF102A43);
  static const muted = Color(0xFF6B7C8F);
}

abstract final class AppTheme {
  static ThemeData get light => build();

  static ThemeData build({double uiScale = 1}) {
    final safeScale = uiScale.clamp(.88, 1.16).toDouble();
    final radius = 18 * safeScale;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.light,
      primary: AppColors.emerald,
      secondary: AppColors.navy,
      surface: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamilyFallback: const [
        'Al-Jazeera Arabic',
        'Cairo',
        'Noto Kufi Arabic',
        'Tahoma',
        'Arial',
      ],
      visualDensity: VisualDensity(
        horizontal: (safeScale - 1) * 2,
        vertical: (safeScale - 1) * 2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          fontFamilyFallback: [
            'Al-Jazeera Arabic',
            'Cairo',
            'Noto Kufi Arabic',
            'Tahoma',
          ],
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70 * safeScale,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mint,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.emeraldDark
                : AppColors.muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18 * safeScale,
          vertical: 15 * safeScale,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: AppColors.emerald,
            width: 1.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * safeScale),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * safeScale),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22 * safeScale),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
        fontFamilyFallback: const [
          'Al-Jazeera Arabic',
          'Cairo',
          'Noto Kufi Arabic',
          'Tahoma',
          'Arial',
        ],
      ),
    );
  }
}
