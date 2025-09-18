import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Glass Theme Configuration for Liquid Glass OTP App
/// Provides comprehensive theming for glass morphism design system
class GlassTheme {
  GlassTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.liquidBlue,
        secondary: AppColors.liquidPurple,
        tertiary: AppColors.liquidPink,
        surface: AppColors.backgroundLight,
        error: AppColors.errorGlass,
        onPrimary: AppColors.textOnGlass,
        onSecondary: AppColors.textOnGlass,
        onTertiary: AppColors.textOnGlass,
        onSurface: Colors.black87,
        onError: AppColors.textOnGlass,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h5.copyWith(color: Colors.black87),
        iconTheme: const IconThemeData(
          color: Colors.black87,
          size: AppSpacing.iconLG,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.primaryGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassCardRadius),
          side: const BorderSide(
            color: AppColors.glassBorder,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        margin: const EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGlass,
          foregroundColor: AppColors.textOnGlass,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.glassButtonRadius),
            side: const BorderSide(
              color: AppColors.glassBorderStrong,
              width: AppSpacing.glassBorderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppSpacing.minButtonWidth,
            AppSpacing.buttonMinHeight,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.liquidBlue,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.glassBorder,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.glassBorder,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.liquidBlue,
            width: AppSpacing.glassBorderWidth * 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.errorGlass,
            width: AppSpacing.glassBorderWidth * 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.inputPadding),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnGlassTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnGlassSecondary,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.h5,
        titleSmall: AppTypography.h6,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Scaffold background
      scaffoldBackgroundColor: Colors.transparent,

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: AppSpacing.glassBorderWidth,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.black87,
        size: AppSpacing.iconLG,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryGlass,
        selectedItemColor: AppColors.liquidBlue,
        unselectedItemColor: AppColors.textOnGlassTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.liquidCyan,
        secondary: AppColors.liquidViolet,
        tertiary: AppColors.liquidPink,
        surface: AppColors.backgroundDark,
        error: AppColors.errorGlass,
        onPrimary: AppColors.textOnGlass,
        onSecondary: AppColors.textOnGlass,
        onTertiary: AppColors.textOnGlass,
        onSurface: AppColors.textOnGlass,
        onError: AppColors.textOnGlass,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.h5.copyWith(color: AppColors.textOnGlass),
        iconTheme: const IconThemeData(
          color: AppColors.textOnGlass,
          size: AppSpacing.iconLG,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.primaryGlassDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassCardRadius),
          side: const BorderSide(
            color: AppColors.glassBorderDark,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        margin: const EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGlassDark,
          foregroundColor: AppColors.textOnGlass,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.glassButtonRadius),
            side: const BorderSide(
              color: AppColors.glassBorderDark,
              width: AppSpacing.glassBorderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppSpacing.minButtonWidth,
            AppSpacing.buttonMinHeight,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.liquidCyan,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryGlassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.glassBorderDark,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.glassBorderDark,
            width: AppSpacing.glassBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.liquidCyan,
            width: AppSpacing.glassBorderWidth * 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.errorGlass,
            width: AppSpacing.glassBorderWidth * 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.inputPadding),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnGlassTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnGlassSecondary,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.textOnGlass,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.textOnGlass,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.textOnGlass,
        ),
        headlineLarge: AppTypography.h1.copyWith(color: AppColors.textOnGlass),
        headlineMedium: AppTypography.h2.copyWith(color: AppColors.textOnGlass),
        headlineSmall: AppTypography.h3.copyWith(color: AppColors.textOnGlass),
        titleLarge: AppTypography.h4.copyWith(color: AppColors.textOnGlass),
        titleMedium: AppTypography.h5.copyWith(color: AppColors.textOnGlass),
        titleSmall: AppTypography.h6.copyWith(color: AppColors.textOnGlass),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textOnGlass,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnGlass,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textOnGlass,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textOnGlass,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textOnGlass,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textOnGlass,
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: Colors.transparent,

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorderDark,
        thickness: AppSpacing.glassBorderWidth,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.textOnGlass,
        size: AppSpacing.iconLG,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryGlassDark,
        selectedItemColor: AppColors.liquidCyan,
        unselectedItemColor: AppColors.textOnGlassTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
    );
  }

  /// Helper method to get system UI overlay style based on theme
  static SystemUiOverlayStyle getSystemUiOverlayStyle(Brightness brightness) {
    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }
}
