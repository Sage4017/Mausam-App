import 'package:flutter/material.dart';

class MausamColors {
  // Core Atmospheric Palette
  static const Color background = Color(0xFFC7D8DB);
  static const Color surface = Color(0xFFEDFCFF);
  static const Color surfaceContainer = Color(0xFFE0F1F4);
  static const Color surfaceContainerLow = Color(0xFFE6F7FA);
  static const Color surfaceContainerHigh = Color(0xFFDAEBEE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFD5E6E9);

  // Brand / Typography
  static const Color primary = Color(0xFF14333B);
  static const Color primaryContainer = Color(0xFF2C4A52);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF99B9C2);
  static const Color secondary = Color(0xFF496368);
  static const Color onSurfaceStrong = Color(0xFF1A2528);
  static const Color onSurfaceMuted = Color(0xFF516266);
  static const Color outline = Color(0xFF72787A);
  static const Color outlineVariant = Color(0xFFC1C7CA);

  // Persona Accents
  static const Color fitnessBlue = Color(0xFF6D8EA0);
  static const Color healthTeal = Color(0xFF7DA097);
  static const Color beachAqua = Color(0xFF8FB5B0);
  static const Color warningAmber = Color(0xFFB0926A);
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color tertiary = Color(0xFF376847);
  static const Color tertiaryContainer = Color(0xFF8ABF97);
}

class MausamTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: MausamColors.background,
      colorScheme: const ColorScheme.light(
        primary: MausamColors.primary,
        onPrimary: MausamColors.onPrimary,
        primaryContainer: MausamColors.primaryContainer,
        surface: MausamColors.surface,
        error: MausamColors.errorRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
          color: MausamColors.primary,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: MausamColors.onSurfaceStrong,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MausamColors.onSurfaceStrong,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: MausamColors.onSurfaceMuted,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: MausamColors.onSurfaceMuted,
        ),
        labelLarge: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: MausamColors.primary,
        ),
        labelSmall: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: MausamColors.secondary,
        ),
      ),
    );
  }
}