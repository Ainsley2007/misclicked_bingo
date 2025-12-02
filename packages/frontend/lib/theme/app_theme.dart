import 'package:flutter/material.dart';
import 'package:frontend/theme/app_dimens.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.accent, required this.success, required this.warning, required this.proofIndicator, required this.completedOverlay});

  final Color accent;
  final Color success;
  final Color warning;
  final Color proofIndicator;
  final Color completedOverlay;

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? _defaultColors;
  }

  static const _defaultColors = AppColors(
    accent: Color(0xFFE11D48),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFA000),
    proofIndicator: Color(0xFFFFA000),
    completedOverlay: Color(0xFF4CAF50),
  );

  @override
  ThemeExtension<AppColors> copyWith({Color? accent, Color? success, Color? warning, Color? proofIndicator, Color? completedOverlay}) {
    return AppColors(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      proofIndicator: proofIndicator ?? this.proofIndicator,
      completedOverlay: completedOverlay ?? this.completedOverlay,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      proofIndicator: Color.lerp(proofIndicator, other.proofIndicator, t) ?? proofIndicator,
      completedOverlay: Color.lerp(completedOverlay, other.completedOverlay, t) ?? completedOverlay,
    );
  }
}

class AppTheme {
  static const _violetRed = Color(0xFFE11D48);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(seedColor: _violetRed, brightness: Brightness.light);
    const borderColor = Color(0xFFE0E0E0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: AppDimens.focusBorderWidth),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimens.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusL),
          side: const BorderSide(color: borderColor),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          side: const BorderSide(color: borderColor),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
        scrolledUnderElevation: 1,
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: AppDimens.dividerThickness, space: AppDimens.dividerThickness),
      extensions: const [
        AppColors(accent: _violetRed, success: Color(0xFF4CAF50), warning: Color(0xFFFFA000), proofIndicator: Color(0xFFFFA000), completedOverlay: Color(0xFF4CAF50)),
      ],
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 25, 7, 106), brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: AppDimens.focusBorderWidth),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimens.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusL),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1), width: AppDimens.borderWidth),
        ),
        color: colorScheme.surfaceContainer,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadiusM)),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
        scrolledUnderElevation: 1,
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline.withValues(alpha: 0.1), thickness: AppDimens.dividerThickness, space: AppDimens.dividerThickness),
      extensions: [
        AppColors(
          accent: colorScheme.primary,
          success: const Color(0xFF4CAF50),
          warning: const Color(0xFFFFA000),
          proofIndicator: const Color(0xFFFFA000),
          completedOverlay: const Color(0xFF4CAF50),
        ),
      ],
    );
  }
}
