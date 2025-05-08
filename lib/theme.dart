import 'package:flutter/material.dart';

const Color seedColor = Color(0xFF006A67);

// Color schemes
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);

// AppBar theme
final AppBarTheme appBarTheme = AppBarTheme(
  backgroundColor: seedColor,
  centerTitle: true,
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
);

// ElevatedButton theme
final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: seedColor,
    foregroundColor: Colors.white,
    disabledBackgroundColor: seedColor.withOpacity(0.4),
    disabledForegroundColor: Colors.white60,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

// Input decoration theme
final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  labelStyle: TextStyle(color: lightColorScheme.onSurface),
  hintStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
);

// Light theme
final ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: appBarTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  inputDecorationTheme: inputDecorationTheme,
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: lightColorScheme.onSurface),
    titleLarge: TextStyle(color: lightColorScheme.onSurface),
  ),
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: darkColorScheme.background,
  appBarTheme: appBarTheme.copyWith(backgroundColor: darkColorScheme.primary),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      disabledBackgroundColor: darkColorScheme.primary.withOpacity(0.4),
      disabledForegroundColor: darkColorScheme.onPrimary.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: TextStyle(color: darkColorScheme.onSurface),
    hintStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: darkColorScheme.onSurface),
    titleLarge: TextStyle(color: darkColorScheme.onSurface),
  ),
);
