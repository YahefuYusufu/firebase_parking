import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: ParkOSColors.mediumGreen,
      onPrimary: Colors.white,
      secondary: ParkOSColors.darkGreen,
      onSecondary: Colors.white,
      error: ParkOSColors.errorRed,
      onError: Colors.white,
      surface: ParkOSColors.lightSurface,
      onSurface: ParkOSColors.lightTextPrimary,
      surfaceTint: ParkOSColors.lightSurface,
      surfaceContainer: ParkOSColors.lightBackground,
      outline: ParkOSColors.lightDivider,
      shadow: Colors.black26,
      inverseSurface: ParkOSColors.darkSurface,
      onInverseSurface: ParkOSColors.terminalGreen,
      inversePrimary: ParkOSColors.lightGreen,
      scrim: Colors.black54,
    ),
    textTheme: GoogleFonts.sourceCodeProTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ParkOSColors.mediumGreen,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white, size: 24.0),
      actionsIconTheme: const IconThemeData(color: Colors.white, size: 24.0),
    ),
    iconTheme: const IconThemeData(color: ParkOSColors.mediumGreen, size: 24.0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ParkOSColors.mediumGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Perfect square corners
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Less rounded
      color: ParkOSColors.lightSurface,
    ),
    dividerTheme: const DividerThemeData(color: ParkOSColors.lightDivider, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4), // Square corners
        borderSide: const BorderSide(color: ParkOSColors.mediumGreen),
      ),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: ParkOSColors.mediumGreen)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: ParkOSColors.terminalGreen, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: ParkOSColors.errorRed)),
      fillColor: ParkOSColors.lightBackground,
      filled: true,
    ),
  );

  // Dark theme - Terminal-like theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: ParkOSColors.terminalGreen,
      onPrimary: ParkOSColors.darkBackground,
      secondary: ParkOSColors.lightGreen,
      onSecondary: ParkOSColors.darkBackground,
      error: ParkOSColors.errorRed,
      onError: Colors.white,
      surface: ParkOSColors.darkSurface,
      onSurface: ParkOSColors.terminalGreen,
      surfaceTint: ParkOSColors.darkSurface,
      surfaceContainer: ParkOSColors.darkBackground,
      outline: ParkOSColors.darkDivider,
      shadow: Colors.black45,
      inverseSurface: ParkOSColors.lightSurface,
      onInverseSurface: ParkOSColors.lightTextPrimary,
      inversePrimary: ParkOSColors.darkGreen,
      scrim: Colors.black87,
    ),
    textTheme: GoogleFonts.sourceCodeProTextTheme(ThemeData.dark().textTheme.apply(bodyColor: ParkOSColors.terminalGreen, displayColor: ParkOSColors.terminalGreen)),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ParkOSColors.darkSurface,
      foregroundColor: ParkOSColors.terminalGreen,
      iconTheme: IconThemeData(color: ParkOSColors.terminalGreen, size: 24.0),
      actionsIconTheme: IconThemeData(color: ParkOSColors.terminalGreen, size: 24.0),
    ),
    iconTheme: const IconThemeData(color: ParkOSColors.terminalGreen, size: 24.0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ParkOSColors.darkSurface,
        foregroundColor: ParkOSColors.terminalGreen,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Perfect square corners
          side: BorderSide(color: ParkOSColors.terminalGreen),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Square corners
        side: const BorderSide(color: ParkOSColors.terminalGreen),
      ),
      color: ParkOSColors.darkSurface,
    ),
    dividerTheme: const DividerThemeData(color: ParkOSColors.darkDivider, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0), // Perfect square corners
        borderSide: const BorderSide(color: ParkOSColors.terminalGreen),
      ),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: const BorderSide(color: ParkOSColors.terminalGreen)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: const BorderSide(color: ParkOSColors.lightGreen, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: const BorderSide(color: ParkOSColors.errorRed)),
      fillColor: ParkOSColors.darkBackground,
      filled: true,
      labelStyle: const TextStyle(color: ParkOSColors.terminalGreen),
      hintStyle: const TextStyle(color: ParkOSColors.darkDivider),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: ParkOSColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: ParkOSColors.terminalGreen)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ParkOSColors.darkSurface,
      contentTextStyle: TextStyle(color: ParkOSColors.terminalGreen),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: ParkOSColors.terminalGreen)),
    ),
  );
}
