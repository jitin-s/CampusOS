import 'package:flutter/material.dart';

/// Semantic colors and Material 3 theme configuration according to UX Specification (docs/04_UX_DESIGN.md).
class AppTheme {
  AppTheme._();

  // Primary brand palette
  static const Color primaryBlue = Color(0xFF1E3E62);
  static const Color secondaryNavy = Color(0xFF0B192C);
  static const Color accentOrange = Color(0xFFFF6500);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceCard = Colors.white;

  // Semantic Status Colors from docs/04_UX_DESIGN.md Section 14
  static const Color statusCritical = Color(0xFFDC2626); // Red
  static const Color statusHigh = Color(0xFFEA580C); // Orange
  static const Color statusMedium = Color(0xFFCA8A04); // Yellow / Amber
  static const Color statusAssigned = Color(0xFF2563EB); // Blue
  static const Color statusResolved = Color(0xFF16A34A); // Green
  static const Color statusPending = Color(0xFF64748B); // Neutral slate

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryNavy,
        surface: surfaceCard,
        error: statusCritical,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1E293B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
