import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeService {
  static const Color _primaryLight = Color(0xFFF5F1E3);

  static const Color _primaryDark = Color(0xFF8C7355);

  static const Color _secondary = Color(0xFF4A7C59);

  static const Color _secondaryLight = Color(0xFF5C8A5B);

  static const Color _tertiary = Color(0xFFD4A855);

  static const Color _tertiaryLight = Color(0xFFE8C77B);

  TextTheme get _textTheme => GoogleFonts.cabinTextTheme();

  ThemeData get lightTheme => ThemeData(
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
      onTertiaryContainer: const Color(0xFF5C4A1F),
      surface: _primaryLight,
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
      backgroundColor: _primaryDark,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE9E4)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _primaryLight.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryLight.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: const BorderSide(color: _primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _secondaryLight.withValues(alpha: 0.15),
      labelStyle: const TextStyle(color: _secondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFE8E4DF),
      displayColor: const Color(0xFFE8E4DF),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _tertiaryLight,
      onPrimary: Color(0xFF13100D),
      primaryContainer: _primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: _secondaryLight,
      onSecondary: _primaryDark,
      secondaryContainer: Color(0x4D4A7C59),
      onSecondaryContainer: _secondaryLight,
      tertiary: _tertiary,
      onTertiary: _primaryDark,
      tertiaryContainer: Color(0x4DD4A855),
      onTertiaryContainer: _tertiaryLight,
      surface: Color(0xFF1A1612),
      onSurface: Color(0xFFE8E4DF),
      surfaceContainerHighest: _primaryDark,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0x808C7355),
    ),
    scaffoldBackgroundColor: const Color(0xFF13100D),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1612),
      foregroundColor: Color(0xFFE8E4DF),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _tertiaryLight,
      foregroundColor: Color(0xFF13100D),
    ),
    cardTheme: CardThemeData(
      color: _primaryDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _primaryLight.withValues(alpha: 0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryLight.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _tertiaryLight, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tertiaryLight,
        foregroundColor: const Color(0xFF13100D),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tertiaryLight,
        side: const BorderSide(color: _tertiaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _secondary.withValues(alpha: 0.25),
      labelStyle: const TextStyle(color: _secondaryLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
