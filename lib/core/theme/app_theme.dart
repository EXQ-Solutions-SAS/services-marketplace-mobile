import 'package:flutter/material.dart';

class AppTheme {
  static const primaryOrange = Color(0xFFFF6D00);
  static const accentPurple = Color(0xAA00FF);
  static const successBlue = Color(0xFF00B0FF); // Tu nuevo "Verde"
  static const backgroundDark = Color(0xFF0F172A);
  static const cardBg = Color(0xFF1E293B);

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: accentPurple,
      surface: cardBg,
      tertiary: successBlue,
    ),
    // Estilo de los Inputs (TextFields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      prefixIconColor: primaryOrange,
    ),
    // Botones redondeados y modernos
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        // LA SOLUCIÓN: Usar RoundedRectangleBorder en lugar de BorderRadius solo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}