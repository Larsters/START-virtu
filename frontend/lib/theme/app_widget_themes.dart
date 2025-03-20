import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'constants.dart';

class AppWidgetThemes {
  // Button Themes
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: Elevations.s,
      padding: EdgeInsets.symmetric(
        horizontal: Spacings.l,
        vertical: Spacings.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryColor,
      side: BorderSide(color: AppTheme.primaryColor, width: BorderWidth.m),
      padding: EdgeInsets.symmetric(
        horizontal: Spacings.l,
        vertical: Spacings.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
    ),
  );

  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppTheme.primaryColor,
      padding: EdgeInsets.symmetric(
        horizontal: Spacings.l,
        vertical: Spacings.s,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
    ),
  );

  // Card Theme
  static CardTheme cardTheme = CardTheme(
    elevation: Elevations.s,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radiuses.m),
    ),
    color: Colors.white,
    margin: EdgeInsets.all(Spacings.s),
  );

  // Input Decoration Theme
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radiuses.s),
      borderSide: BorderSide(color: Colors.grey, width: BorderWidth.m),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radiuses.s),
      borderSide: BorderSide(color: Colors.grey[300]!, width: BorderWidth.m),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radiuses.s),
      borderSide: BorderSide(
        color: AppTheme.primaryColor,
        width: BorderWidth.m,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radiuses.s),
      borderSide: BorderSide(color: AppTheme.errorColor, width: BorderWidth.m),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Spacings.l,
      vertical: Spacings.m,
    ),
  );

  // Container Decorations
  static BoxDecoration defaultContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(Radiuses.m),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(50),
        blurRadius: Elevations.s,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration primaryContainerDecoration = BoxDecoration(
    color: AppTheme.primaryColor.withAlpha(10),
    borderRadius: BorderRadius.circular(Radiuses.m),
    border: Border.all(
      color: AppTheme.primaryColor.withAlpha(20),
      width: BorderWidth.m,
    ),
  );

  // List Tile Theme
  static ListTileThemeData listTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radiuses.s),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Spacings.l,
      vertical: Spacings.s,
    ),
    tileColor: Colors.transparent,
    selectedTileColor: AppTheme.primaryColor.withAlpha(20),
  );

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        elevation: Elevations.m,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      );

  // App Bar Theme
  static AppBarTheme appBarTheme = AppBarTheme(
    elevation: Elevations.s,
    backgroundColor: Colors.white,
    foregroundColor: AppTheme.darkColor,
    centerTitle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(Radiuses.m)),
    ),
  );

  // Floating Action Button Theme
  static FloatingActionButtonThemeData floatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: Elevations.l,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radiuses.xl),
        ),
      );

  // Chip Theme
  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: Colors.grey[100],
    selectedColor: AppTheme.primaryColor.withAlpha(50),
    padding: EdgeInsets.symmetric(
      horizontal: Spacings.m,
      vertical: Spacings.xxs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radiuses.xs),
    ),
    labelStyle: TextStyle(color: AppTheme.darkColor),
  );
}
