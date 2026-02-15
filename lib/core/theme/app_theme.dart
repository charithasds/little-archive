import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryDark = Color(0xFF1e2d3d);
  static const Color _primaryLight = Color(0xFF2a3f52);
  static const Color _secondary = Color(0xFF4a7c59);
  static const Color _secondaryLight = Color(0xFF5c8a5b);
  static const Color _tertiary = Color(0xFFd4a855);
  static const Color _tertiaryLight = Color(0xFFe8c77b);

  static TextTheme get _textTheme => GoogleFonts.loraTextTheme();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _textTheme.apply(bodyColor: _primaryDark, displayColor: _primaryDark),
    colorScheme: ColorScheme.light(
      primary: _primaryDark,
      primaryContainer: _primaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: _primaryDark,
      secondary: _secondary,
      onSecondary: Colors.white,
      secondaryContainer: _secondaryLight.withValues(alpha: 0.2),
      onSecondaryContainer: _secondary,
      tertiary: _tertiary,
      onTertiary: _primaryDark,
      tertiaryContainer: _tertiaryLight.withValues(alpha: 0.3),
      onTertiaryContainer: const Color(0xFF5c4a1f),
      surface: const Color(0xFFF8F6F3),
      onSurface: _primaryDark,
      surfaceContainerHighest: const Color(0xFFEDE9E4),
      error: const Color(0xFFBA1A1A),
      outline: _primaryLight.withValues(alpha: 0.4),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _tertiary,
      foregroundColor: _primaryDark,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _primaryLight.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryLight.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: const BorderSide(color: _primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _secondaryLight.withValues(alpha: 0.15),
      labelStyle: const TextStyle(color: _secondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFE8E4DF),
      displayColor: const Color(0xFFE8E4DF),
    ),
    colorScheme: ColorScheme.dark(
      primary: _tertiaryLight,
      onPrimary: _primaryDark,
      primaryContainer: _primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: _secondaryLight,
      onSecondary: _primaryDark,
      secondaryContainer: _secondary.withValues(alpha: 0.3),
      onSecondaryContainer: _secondaryLight,
      tertiary: _tertiary,
      onTertiary: _primaryDark,
      tertiaryContainer: _tertiary.withValues(alpha: 0.3),
      onTertiaryContainer: _tertiaryLight,
      surface: const Color(0xFF121a22),
      onSurface: const Color(0xFFE8E4DF),
      surfaceContainerHighest: _primaryDark,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      outline: _primaryLight.withValues(alpha: 0.5),
    ),
    scaffoldBackgroundColor: const Color(0xFF0d1318),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121a22),
      foregroundColor: Color(0xFFE8E4DF),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _tertiary,
      foregroundColor: _primaryDark,
    ),
    cardTheme: CardThemeData(
      color: _primaryDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _primaryLight.withValues(alpha: 0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryLight.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _tertiaryLight, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tertiary,
        foregroundColor: _primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tertiaryLight,
        side: const BorderSide(color: _tertiaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _secondary.withValues(alpha: 0.25),
      labelStyle: const TextStyle(color: _secondaryLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
