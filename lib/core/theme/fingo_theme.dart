import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores oficiales de la interfaz móvil de FINGO.
abstract final class FingoColors {
  // Fondos y superficies.
  static const background = Color(0xFF101713);
  static const surface = Color(0xFF1A241E);
  static const elevatedSurface = Color(0xFF25332A);
  static const lightBackground = Color(0xFFF5F8F6);
  static const lightSurface = Color(0xFFFFFFFF);

  // Identidad visual verde.
  static const primary = Color(0xFF16865B);
  static const accent = Color(0xFF50D890);

  // Textos y separadores.
  static const textPrimary = Color(0xFFF1F5F2);
  static const textSecondary = Color(0xFFA7B5AC);
  static const border = Color(0xFF303C34);

  // Estados y movimientos financieros.
  static const expense = Color(0xFFFF7777);
  static const income = Color(0xFF50D890);
}

/// Tema oscuro compartido por toda la aplicación.
abstract final class FingoTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FingoColors.primary,
      brightness: Brightness.dark,
      surface: FingoColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Aplicación global limpia de Google Fonts sin conflictos de tipos
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: colorScheme.copyWith(
        primary: FingoColors.primary,
        secondary: FingoColors.accent,
        surface: FingoColors.surface,
        error: FingoColors.expense,
      ),
      scaffoldBackgroundColor: FingoColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: FingoColors.background,
        foregroundColor: FingoColors.textPrimary,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FingoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: FingoColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FingoColors.surface,
        labelStyle: const TextStyle(color: FingoColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FingoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FingoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FingoColors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FingoColors.primary,
          foregroundColor: FingoColors.textPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: FingoColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: FingoColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: FingoColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: FingoColors.textSecondary,
        ),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FingoColors.primary,
      brightness: Brightness.light,
      surface: FingoColors.lightSurface,
    );

    return dark.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme.copyWith(
        primary: FingoColors.primary,
        secondary: FingoColors.primary,
        surface: FingoColors.lightSurface,
        error: FingoColors.expense,
      ),
      scaffoldBackgroundColor: FingoColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: FingoColors.lightBackground,
        foregroundColor: Color(0xFF17231C),
      ),
      cardTheme: const CardThemeData(
        color: FingoColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFDCE7DF)),
        ),
      ),
      inputDecorationTheme: dark.inputDecorationTheme.copyWith(
        fillColor: FingoColors.lightSurface,
        labelStyle: const TextStyle(color: Color(0xFF607066)),
      ),
      textTheme: dark.textTheme.apply(
        bodyColor: const Color(0xFF17231C),
        displayColor: const Color(0xFF17231C),
      ),
    );
  }
}
