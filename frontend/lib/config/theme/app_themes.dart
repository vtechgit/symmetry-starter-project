import 'package:flutter/material.dart';

// X (Twitter) dark mode palette
class XColors {
  static const black = Color(0xFF000000);
  static const surface = Color(0xFF16181C);
  static const border = Color(0xFF2F3336);
  static const blue = Color(0xFF1D9BF0);
  static const textPrimary = Color(0xFFE7E9EA);
  static const textSecondary = Color(0xFF71767B);
  static const red = Color(0xFFF4212E);
}

// X (Twitter) light mode palette
class XLightColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F9F9);
  static const border = Color(0xFFEFF3F4);
  static const blue = Color(0xFF1D9BF0);
  static const textPrimary = Color(0xFF0F1419);
  static const textSecondary = Color(0xFF536471);
  static const red = Color(0xFFF4212E);
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: XColors.black,
    fontFamily: 'Muli',
    colorScheme: const ColorScheme.dark(
      surface: XColors.surface,
      primary: XColors.blue,
      error: XColors.red,
      onSurface: XColors.textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: XColors.black,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: XColors.textPrimary),
      titleTextStyle: TextStyle(
        color: XColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Muli',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: XColors.black,
      selectedItemColor: XColors.blue,
      unselectedItemColor: XColors.textSecondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: XColors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    dividerColor: XColors.border,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: XColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: TextStyle(color: XColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleLarge: TextStyle(color: XColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
      titleMedium: TextStyle(color: XColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 15),
      bodyLarge: TextStyle(color: XColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: XColors.textSecondary, fontSize: 13),
      labelSmall: TextStyle(color: XColors.textSecondary, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: XColors.surface,
      hintStyle: const TextStyle(color: XColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XColors.blue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: XColors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Muli'),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: XColors.surface,
      contentTextStyle: TextStyle(color: XColors.textPrimary),
    ),
  );
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: XLightColors.background,
    fontFamily: 'Muli',
    colorScheme: const ColorScheme.light(
      surface: XLightColors.surface,
      primary: XLightColors.blue,
      error: XLightColors.red,
      onSurface: XLightColors.textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: XLightColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: XLightColors.textPrimary),
      titleTextStyle: TextStyle(
        color: XLightColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Muli',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: XLightColors.background,
      selectedItemColor: XLightColors.blue,
      unselectedItemColor: XLightColors.textSecondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: XLightColors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    dividerColor: XLightColors.border,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: XLightColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: TextStyle(color: XLightColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleLarge: TextStyle(color: XLightColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
      titleMedium: TextStyle(color: XLightColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 15),
      bodyLarge: TextStyle(color: XLightColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: XLightColors.textSecondary, fontSize: 13),
      labelSmall: TextStyle(color: XLightColors.textSecondary, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: XLightColors.surface,
      hintStyle: const TextStyle(color: XLightColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XLightColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XLightColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: XLightColors.blue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: XLightColors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Muli'),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: XLightColors.surface,
      contentTextStyle: TextStyle(color: XLightColors.textPrimary),
    ),
  );
}
