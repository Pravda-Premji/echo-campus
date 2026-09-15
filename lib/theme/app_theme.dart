import 'package:flutter/material.dart';

class EchoColors {
  static const Color indigo = Color(0xFF4F46E5);
  static const Color purple = Color(0xFF7C3AED);
  static const Color ink = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);
  static const Color canvas = Color(0xFFF7F5FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF047857);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFBE123C);
}

class AppTheme {
  static ThemeData light({bool largeText = false}) {
    const seed = EchoColors.indigo;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: EchoColors.indigo,
      secondary: EchoColors.purple,
      surface: EchoColors.card,
    );

    final textTheme = _textTheme(largeText);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: EchoColors.canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: EchoColors.canvas,
        foregroundColor: EchoColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      cardTheme: CardTheme(
        color: EchoColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EchoColors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EchoColors.indigo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: EchoColors.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: EchoColors.muted.withOpacity(0.9)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: EchoColors.indigo, width: 1.6),
        ),
      ),
    );
  }

  static TextTheme _textTheme(bool largeText) {
    final scale = largeText ? 1.12 : 1.0;
    TextStyle sized(double size, FontWeight weight, {double? spacing, Color? color}) {
      return TextStyle(
        fontSize: size * scale,
        fontWeight: weight,
        height: 1.25,
        letterSpacing: spacing,
        color: color ?? EchoColors.ink,
      );
    }

    return TextTheme(
      displaySmall: sized(34, FontWeight.w800, spacing: -0.6),
      headlineMedium: sized(26, FontWeight.w800, spacing: -0.4),
      headlineSmall: sized(22, FontWeight.w800),
      titleLarge: sized(20, FontWeight.w800),
      titleMedium: sized(16, FontWeight.w700),
      titleSmall: sized(14, FontWeight.w700),
      bodyLarge: sized(16, FontWeight.w500, color: EchoColors.ink),
      bodyMedium: sized(15, FontWeight.w500, color: EchoColors.muted),
      bodySmall: sized(13, FontWeight.w600, color: EchoColors.muted),
      labelLarge: sized(13, FontWeight.w800, spacing: 0.6),
    );
  }
}
