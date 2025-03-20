import 'package:flutter/material.dart';
import 'package:frontend/theme/app_widget_themes.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main Colors
  static const Color primaryColor = Color(0xFF36398E); // Main blue
  static const Color secondaryColor = Color(0xFF009F3C); // Main green
  static const Color errorColor = Color(0xFF98272A); // Error red
  static const Color darkColor = Color(0xFF0E223D); // Dark/text color

  // Additional Colors
  static const Color sunOrange = Color(
    0xFFFCE500,
  ); // Sun orange (rgb: 252, 229, 0)
  static const Color energyPink = Color(
    0xFFFF99FF,
  ); // Energy pink (rgb: 255, 153, 255)
  static const Color brightGreen = Color(
    0xFF7CF63C,
  ); // Green (rgb: 124, 246, 60)
  static const Color brightBlue = Color(0xFF00FAC0); // Blue (rgb: 0, 250, 192)

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: darkColor,
    ),

    // Widget Themes
    elevatedButtonTheme: AppWidgetThemes.elevatedButtonTheme,
    outlinedButtonTheme: AppWidgetThemes.outlinedButtonTheme,
    textButtonTheme: AppWidgetThemes.textButtonTheme,
    cardTheme: AppWidgetThemes.cardTheme,
    inputDecorationTheme: AppWidgetThemes.inputDecorationTheme,
    listTileTheme: AppWidgetThemes.listTileTheme,
    bottomNavigationBarTheme: AppWidgetThemes.bottomNavigationBarTheme,
    appBarTheme: AppWidgetThemes.appBarTheme,
    floatingActionButtonTheme: AppWidgetThemes.floatingActionButtonTheme,
    chipTheme: AppWidgetThemes.chipTheme,

    // Text Theme
    textTheme: TextTheme(
      // Display styles (largest, bold)
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 57,
        color: darkColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 45,
        color: darkColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 36,
        color: darkColor,
      ),

      // Headline styles (bold)
      headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 32,
        color: darkColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 28,
        color: darkColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 24,
        color: darkColor,
      ),

      // Title styles (bold)
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 22,
        color: darkColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 16,
        color: darkColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // semibold
        fontSize: 14,
        color: darkColor,
      ),

      // Body styles (regular)
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 16,
        color: darkColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 14,
        color: darkColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 12,
        color: darkColor,
      ),

      // Label styles (smallest, regular)
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 14,
        color: darkColor,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 12,
        color: darkColor,
      ),
      labelSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400, // regular
        fontSize: 11,
        color: darkColor,
      ),
    ),

    // For marketing content
    fontFamily: GoogleFonts.notoSansDisplay().fontFamily,
  );

  // Dark Theme (optional - you can adapt if needed)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: darkColor,
      onSurface: Colors.white,
    ),
    // The rest of the theme would be similar with adjusted colors
  );
}
