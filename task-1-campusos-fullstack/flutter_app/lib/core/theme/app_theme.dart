import 'package:flutter/material.dart';

/// Semantic colors and Material 3 theme configuration according to UX Specification
/// Enhanced with Blue, Cream White, Green palette and SOS Emergency styling.
class AppTheme {
  AppTheme._();

  // Primary brand palette (Blue Theme)
  static const Color primaryBlue = Color(0xFF1E3A8A); // Collegiate Deep Blue
  static const Color secondaryNavy = Color(0xFF0F1E36); // Rich Executive Navy
  static const Color accentBlue = Color(0xFF2563EB); // Vibrant Royal / Electric Blue
  static const Color softBlue = Color(0xFFEFF6FF); // Crisp Ice Blue tint
  static const Color accentOrange = Color(0xFFEA580C); // Warm Amber Accent

  // Cream White Theme
  static const Color backgroundCream = Color(0xFFFAF8F5); // Warm Alabaster Canvas
  static const Color surfaceCream = Color(0xFFFFFDF9); // Soft Cream Card Surface
  static const Color creamBorder = Color(0xFFEBE5D8); // Warm Subtle Border
  static const Color creamHighlight = Color(0xFFF5EFE6); // Cream Pill & Chip Fill
  static const Color backgroundLight = backgroundCream; // Backward compatibility
  static const Color surfaceCard = Colors.white; // Backward compatibility

  // Campus Green Theme
  static const Color campusGreen = Color(0xFF16A34A); // Emerald Campus Green
  static const Color campusGreenDark = Color(0xFF15803D); // Deep Forest Green
  static const Color campusGreenLight = Color(0xFFDCFCE7); // Mint / Soft Sage tint
  static const Color campusGreenBorder = Color(0xFF86EFAC); // Mint outline

  // SOS Emergency & Semantic Status Colors
  static const Color emergencyRed = Color(0xFFDC2626); // Vivid Panic Red
  static const Color emergencyRedLight = Color(0xFFFEF2F2); // Soft SOS tint
  static const Color emergencyRedBorder = Color(0xFFFCA5A5); // Emergency stroke

  static const Color statusCritical = emergencyRed; // Red
  static const Color statusHigh = Color(0xFFEA580C); // Orange
  static const Color statusMedium = Color(0xFFCA8A04); // Yellow / Amber
  static const Color statusAssigned = Color(0xFF2563EB); // Blue
  static const Color statusResolved = campusGreen; // Green
  static const Color statusPending = Color(0xFF64748B); // Slate

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundCream,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: campusGreenDark,
        tertiary: accentBlue,
        surface: surfaceCream,
        error: emergencyRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: creamBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 1,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: creamBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: creamBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: creamBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
      ),
    );
  }
}
