import 'package:flutter/material.dart';

/// Tema institucional de la aplicación con soporte para claro, oscuro y alto contraste.
class AppTheme {
  const AppTheme._();

  static const Color semilla = Color(0xFF194D84);

  static ThemeData get claro => _tema(Brightness.light);
  static ThemeData get oscuro => _tema(Brightness.dark);
  static ThemeData get altoContrasteClaro =>
      _tema(Brightness.light, contraste: 1.0);
  static ThemeData get altoContrasteOscuro =>
      _tema(Brightness.dark, contraste: 1.0);

  static ThemeData _tema(Brightness brillo, {double contraste = 0.0}) {
    final esquema = ColorScheme.fromSeed(
      seedColor: semilla,
      brightness: brillo,
      contrastLevel: contraste,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      textTheme: _tipografia(esquema),
      appBarTheme: AppBarTheme(
        backgroundColor: brillo == Brightness.light
            ? esquema.primary
            : esquema.surfaceContainerHighest,
        foregroundColor: brillo == Brightness.light
            ? esquema.onPrimary
            : esquema.onSurface,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: brillo == Brightness.light
              ? esquema.onPrimary
              : esquema.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: esquema.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
      ),
    );
  }

  static TextTheme _tipografia(ColorScheme esquema) {
    final base = esquema.brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;

    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: esquema.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: esquema.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: esquema.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.45,
        color: esquema.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 18,
        height: 1.45,
        color: esquema.onSurface,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
