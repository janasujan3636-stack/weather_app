import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand palette
  static const Color primaryBlue = Color(0xFF1E3C72);
  static const Color secondaryBlue = Color(0xFF2A5298);
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentGold = Color(0xFFFFB300);

  // Background Gradients by Weather Condition
  static const LinearGradient clearSkyDayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2193B0),
      Color(0xFF6DD5ED),
      Color(0xFFBBE5ED),
    ],
  );

  static const LinearGradient clearSkyNightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F2027),
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3E5151),
      Color(0xFF5A7272),
      Color(0xFFDECBA4),
    ],
  );

  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F1C2C),
      Color(0xFF2E3D52),
      Color(0xFF496B88),
    ],
  );

  static const LinearGradient stormyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141E30),
      Color(0xFF243B55),
      Color(0xFF3F2B96),
    ],
  );

  static const LinearGradient snowyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF83A4D4),
      Color(0xFFB6FBFF),
    ],
  );

  // Glassmorphism card decoration
  static BoxDecoration glassBoxDecoration({
    double opacity = 0.18,
    double borderRadius = 20.0,
    Color borderColor = Colors.white,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor.withOpacity(0.25),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 18,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Dark App Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: const Color(0xFF0B131E),
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentGold,
      surface: Color(0xFF152238),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        color: Colors.white,
        letterSpacing: -2,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white60,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentCyan, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white),
    ),
  );
}
