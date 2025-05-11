import 'package:flutter/material.dart';

class ParkOSColors {
  // Common colors
  static const Color terminalGreen = Color(0xFF33FF33);
  static const Color mediumGreen = Color(0xFF00CC00);
  static const Color lightGreen = Color(0xFF88FF88);
  static const Color darkGreen = Color(0xFF005500);

  static const Color errorRed = Color(0xFFFF3333);
  static const Color warningYellow = Color(0xFFFFCC00);
  static const Color successGreen = terminalGreen;

  // Light theme colors
  static const Color lightBackground = Color(0xFFEEEEEE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF121212);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightDivider = Color(0xFFCCCCCC);

  // Dark theme colors (terminal-like)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = terminalGreen;
  static const Color darkTextSecondary = lightGreen;
  static const Color darkDivider = Color(0xFF333333);
}
