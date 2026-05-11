import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF002B1D); // Dark Green from image
  static const Color accentColor = Color(0xFFBDCECA); // Light Teal from active nav
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF002B1D);
  static const Color textSecondary = Color(0xFF8E99AF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.outfit(color: textPrimary),
        bodyMedium: GoogleFonts.outfit(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
