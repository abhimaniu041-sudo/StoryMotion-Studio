import 'package:flutter/material.dart';

class DarkTheme {
  static const primary = Color(0xFF90CAF9);
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
  static const card = Color(0xFF2C2C2C);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          background: background,
          surface: surface,
          onPrimary: Color(0xFF121212),
          onBackground: textPrimary,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: background,
        cardColor: card,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: const Color(0xFF121212),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        cardTheme: CardTheme(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              color: textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(
              color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          labelLarge: TextStyle(
              color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
}
