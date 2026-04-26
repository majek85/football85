import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors (Premium Glassmorphism Style)
  static const Color darkBg = Color(0xFF0F172A); // Slate Blue dark
  static const Color darkCard = Color(0xFF1E293B); // Slightly lighter slate
  static const Color darkAccent = Color(0xFF6CABDD); // Man City Blue
  static const Color darkText = Colors.white;
  static const Color darkTextDim = Color(0xFF94A3B8);

  // Light Theme Colors (Clean Style)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightAccent = Color(0xFF6CABDD); // Man City Blue
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextDim = Color(0xFF64748B);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: darkAccent,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: darkAccent,
      surface: darkCard,
      onSurface: darkText,
      onSurfaceVariant: darkTextDim,
      secondary: darkCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: darkAccent,
      unselectedItemColor: darkTextDim,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: lightAccent,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.light(
      primary: lightAccent,
      surface: lightCard,
      onSurface: lightText,
      onSurfaceVariant: lightTextDim,
      secondary: lightBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCard,
      selectedItemColor: lightAccent,
      unselectedItemColor: lightTextDim,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
