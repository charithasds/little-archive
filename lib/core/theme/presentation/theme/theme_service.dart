import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeService {
  static const Color _p0 = Color(0xFF000000);
  static const Color _p10 = Color(0xFF1F130A);
  static const Color _p20 = Color(0xFF36210F);
  static const Color _p30 = Color(0xFF4F3118);
  static const Color _p40 = Color(0xFF6A4323);
  static const Color _p80 = Color(0xFFE09C70);
  static const Color _p90 = Color(0xFFF5C9A4);
  static const Color _p100 = Color(0xFFFFFFFF);

  static const Color _s10 = Color(0xFF0C1F11);
  static const Color _s20 = Color(0xFF1A3520);
  static const Color _s30 = Color(0xFF284D30);
  static const Color _s40 = Color(0xFF386641);
  static const Color _s80 = Color(0xFF9DD4A5);
  static const Color _s90 = Color(0xFFBEEEC6);

  static const Color _t10 = Color(0xFF1E1600);
  static const Color _t20 = Color(0xFF342800);
  static const Color _t30 = Color(0xFF4E3C00);
  static const Color _t40 = Color(0xFF6A5200);
  static const Color _t80 = Color(0xFFE8B93E);
  static const Color _t90 = Color(0xFFFFDE93);

  static const Color _n6 = Color(0xFF110F0D);
  static const Color _n10 = Color(0xFF1C1B18);
  static const Color _n12 = Color(0xFF201F1C);
  static const Color _n17 = Color(0xFF2A2925);
  static const Color _n20 = Color(0xFF312F2B);
  static const Color _n22 = Color(0xFF37342F);
  static const Color _n24 = Color(0xFF3C3A35);
  static const Color _n87 = Color(0xFFDDD9D3);
  static const Color _n90 = Color(0xFFE6E2DC);
  static const Color _n92 = Color(0xFFEBE7E1);
  static const Color _n94 = Color(0xFFF0EDE7);
  static const Color _n96 = Color(0xFFF5F2EC);
  static const Color _n99 = Color(0xFFFCF9F3);

  static const Color _nv30 = Color(0xFF4A4540);
  static const Color _nv50 = Color(0xFF7A746E);
  static const Color _nv60 = Color(0xFF958E87);
  static const Color _nv80 = Color(0xFFCCC4BC);
  static const Color _nv90 = Color(0xFFEAE2DA);

  static const Color _e10 = Color(0xFF410002);
  static const Color _e40 = Color(0xFFBA1A1A);
  static const Color _e80 = Color(0xFFFFB4AB);
  static const Color _e90 = Color(0xFFFFDAD6);

  TextTheme get _textTheme => GoogleFonts.cabinTextTheme();

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _textTheme.apply(bodyColor: _p10, displayColor: _p10),
    colorScheme: const ColorScheme.light(
      primary: _p40,
      primaryContainer: _p90,
      onPrimaryContainer: _p10,
      secondary: _s40,
      onSecondary: _p100,
      secondaryContainer: _s90,
      onSecondaryContainer: _s10,
      tertiary: _t40,
      onTertiary: _p100,
      tertiaryContainer: _t90,
      onTertiaryContainer: _t10,
      error: _e40,
      errorContainer: _e90,
      onErrorContainer: _e10,
      surface: _n99,
      onSurface: _n10,
      surfaceVariant: _nv90,
      onSurfaceVariant: _nv30,
      surfaceDim: _n87,
      surfaceBright: _n99,
      surfaceContainerLowest: _p100,
      surfaceContainerLow: _n96,
      surfaceContainer: _n94,
      surfaceContainerHigh: _n92,
      surfaceContainerHighest: _n90,
      outline: _nv50,
      outlineVariant: _nv80,
      inverseSurface: _n20,
      onInverseSurface: _n94,
      inversePrimary: _p80,
      scrim: _p0,
      shadow: _p0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _n99,
      foregroundColor: _n10,
      surfaceTintColor: _p40,
      scrolledUnderElevation: 2,
      titleTextStyle: GoogleFonts.cabin(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _n10,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _p90,
      foregroundColor: _p10,
      elevation: 3,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _n94,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _n96,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _nv80),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _nv80),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _p40, width: 2),
      ),
      labelStyle: const TextStyle(color: _nv30),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _p90,
        foregroundColor: _p10,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _p40,
        foregroundColor: _p100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _p40,
        side: const BorderSide(color: _p40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _s90,
      labelStyle: const TextStyle(color: _s10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: _nv90),
    iconTheme: const IconThemeData(color: _nv30),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _textTheme.apply(
      bodyColor: _n90,
      displayColor: _n90,
    ),
    colorScheme: const ColorScheme.dark(
      primary: _p80,
      onPrimary: _p20,
      primaryContainer: _p30,
      onPrimaryContainer: _p90,
      secondary: _s80,
      onSecondary: _s20,
      secondaryContainer: _s30,
      onSecondaryContainer: _s90,
      tertiary: _t80,
      onTertiary: _t20,
      tertiaryContainer: _t30,
      onTertiaryContainer: _t90,
      error: _e80,
      onError: _e10,
      errorContainer: _e10,
      onErrorContainer: _e90,
      surface: _n6,
      onSurface: _n90,
      surfaceVariant: _nv30,
      onSurfaceVariant: _nv80,
      surfaceDim: _n6,
      surfaceBright: _n24,
      surfaceContainerLowest: _n10,
      surfaceContainerLow: _n12,
      surfaceContainer: _n17,
      surfaceContainerHigh: _n22,
      surfaceContainerHighest: _n24,
      outline: _nv60,
      outlineVariant: _nv30,
      inverseSurface: _n90,
      onInverseSurface: _n20,
      inversePrimary: _p40,
      scrim: _p0,
      shadow: _p0,
    ),
    scaffoldBackgroundColor: _n6,
    appBarTheme: AppBarTheme(
      backgroundColor: _n6,
      foregroundColor: _n90,
      surfaceTintColor: _p80,
      scrolledUnderElevation: 2,
      titleTextStyle: GoogleFonts.cabin(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _n90,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _p30,
      foregroundColor: _p90,
      elevation: 3,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _n17,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _n12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _nv30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _nv30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _p80, width: 2),
      ),
      labelStyle: const TextStyle(color: _nv80),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _p30,
        foregroundColor: _p90,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _p80,
        foregroundColor: _p20,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _p80,
        side: const BorderSide(color: _p80),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _s30,
      labelStyle: const TextStyle(color: _s90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: _nv30),
    iconTheme: const IconThemeData(color: _nv80),
  );
}
