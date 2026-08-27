import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Masala Night palette
  static const Color background = Color(0xFF1A0F0F);
  static const Color surface = Color(0xFF231A1A);
  static const Color surfaceElevated = Color(0xFF2D1F1F);

  // Accents
  static const Color saffron = Color(0xFFFF6F2C);
  static const Color saffronSoft = Color(0xFFFF914D);
  static const Color magenta = Color(0xFFD63384);
  static const Color emerald = Color(0xFF2ECC71);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFFF6B6B);

  // Text
  static const Color textPrimary = Color(0xFFFFF5EB);
  static const Color textSecondary = Color(0xFFC4958A);

  // Keyboard
  static const Color keyboardKey = Color(0xFF3D2020);
  static const Color keyboardCorrect = Color(0xFF1B7A3D);
  static const Color keyboardWrong = Color(0xFF8B1A2B);

  // Decorative
  static const Color marquee = Color(0xFFFF6F2C);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.saffron,
        secondary: AppColors.emerald,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.black,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: AppColors.saffronSoft, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.saffron,
        inactiveTrackColor: AppColors.surfaceElevated,
        thumbColor: AppColors.saffronSoft,
        overlayColor: AppColors.saffron.withValues(alpha: 0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.saffron;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.saffron.withValues(alpha: 0.45);
          }
          return AppColors.surfaceElevated;
        }),
      ),
    );
  }
}
