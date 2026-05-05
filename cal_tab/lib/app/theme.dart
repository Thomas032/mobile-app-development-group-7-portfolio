import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color _primary = Color(0xFF006E28);
  static const Color _surface = Color(0xFFFAF9FE);
  static const Color _darkSurface = Color(0xFF1A1B1F);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
        surface: _surface,
      ),
      scaffoldBackgroundColor: _surface,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.dark,
        surface: _darkSurface,
      ),
      scaffoldBackgroundColor: _darkSurface,
    );
  }
}
