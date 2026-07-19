import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF050816);
  static const Color surface = Color(0xFF0B1024);
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color deepBlue = Color(0xFF145CFF);

  static ThemeData get dark {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: deepBlue,
        surface: surface,
        onPrimary: Colors.black,
      ),
      textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: neonBlue.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: neonBlue.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: neonBlue, width: 1.6),
        ),
      ),
    );
  }
}
