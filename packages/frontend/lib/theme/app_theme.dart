import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.accent, required this.accentLight});

  final Color accent;
  final Color accentLight;

  @override
  ThemeExtension<AppColors> copyWith({Color? accent, Color? accentLight}) {
    return AppColors(accent: accent ?? this.accent, accentLight: accentLight ?? this.accentLight);
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(accent: Color.lerp(accent, other.accent, t)!, accentLight: Color.lerp(accentLight, other.accentLight, t)!);
  }
}

class AppTheme {
  static const _blueAccent = Color(0xFF2196F3);
  static const _orangeAccent = Color(0xFFFF6E40);
  static const _orangeAccentLight = Color(0xFFFF9E80);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(seedColor: _blueAccent, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surfaceContainer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: colorScheme.surface, surfaceTintColor: Colors.transparent),
      extensions: const [AppColors(accent: _orangeAccent, accentLight: _orangeAccentLight)],
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(seedColor: _blueAccent, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0A0E27),
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color(0xFF1A1F3A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1A1F3A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: _orangeAccent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: Color(0xFF0A0E27), surfaceTintColor: Colors.transparent),
      extensions: const [AppColors(accent: _orangeAccent, accentLight: _orangeAccentLight)],
    );
  }
}
