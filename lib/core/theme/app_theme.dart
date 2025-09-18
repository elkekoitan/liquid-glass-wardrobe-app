import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../design_system/design_tokens.dart';

/// Professional Fashion Brand Theme System
/// Supports light/dark modes with luxury brand aesthetics
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3 Design System
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Professional Fashion Brand Colors
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMain,
        brightness: Brightness.light,
        primary: AppColors.primaryMain,
        onPrimary: AppColors.neutralWhite,
        secondary: AppColors.secondaryMain,
        onSecondary: AppColors.neutralWhite,
        tertiary: AppColors.warning,
        surface: AppColors.neutralWhite,
        onSurface: AppColors.neutral900,
        background: AppColors.neutral50,
        onBackground: AppColors.neutral900,
        error: AppColors.error,
        onError: AppColors.neutralWhite,
      ),

      // Typography - Google Fonts Integration
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Display Styles - Luxury fashion brand
        displayLarge: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displayLarge,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displayMedium,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displaySmall,
        ),
        
        // Headlines
        headlineLarge: GoogleFonts.inter(
          textStyle: AppTextStyles.headlineLarge,
        ),
        headlineMedium: GoogleFonts.inter(
          textStyle: AppTextStyles.headlineMedium,
        ),
        headlineSmall: GoogleFonts.inter(
          textStyle: AppTextStyles.headlineSmall,
        ),
        
        // Body Text
        bodyLarge: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyLarge,
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyMedium,
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: AppTextStyles.bodySmall,
        ),
        
        // Labels
        labelLarge: GoogleFonts.inter(
          textStyle: AppTextStyles.labelLarge,
        ),
        labelMedium: GoogleFonts.inter(
          textStyle: AppTextStyles.labelMedium,
        ),
        labelSmall: GoogleFonts.inter(
          textStyle: AppTextStyles.labelSmall,
        ),
      ),

      // AppBar Theme - Professional Fashion Brand Style
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.neutralWhite,
        foregroundColor: AppColors.neutral900,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral800,
          size: 24,
        ),
      ),

      // Elevated Button Theme - Luxury Brand Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMain,
          foregroundColor: AppColors.neutralWhite,
          elevation: DesignTokens.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceL,
            vertical: DesignTokens.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceL,
            vertical: DesignTokens.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          side: const BorderSide(
            color: AppColors.primaryMain,
            width: 1.5,
          ),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // Card Theme - Glass Morphism Effect
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevationXS,
        shadowColor: AppColors.neutral900.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        color: AppColors.neutralWhite,
        surfaceTintColor: Colors.transparent,
      ),

      // Input Decoration Theme - Fashion Brand Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.primaryMain,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceM,
          vertical: DesignTokens.spaceM,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.neutralWhite,
        elevation: DesignTokens.elevationM,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // Visual Density - Compact for mobile
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Platform Brightness
      platform: TargetPlatform.iOS, // For consistent styling
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      // Material 3 Design System
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Dark Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMain,
        brightness: Brightness.dark,
        primary: AppColors.secondaryMain, // Gold accent for dark mode
        onPrimary: AppColors.neutralBlack,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.neutralWhite,
        tertiary: AppColors.warning,
        surface: AppColors.neutral800,
        onSurface: AppColors.neutralWhite,
        background: AppColors.neutralBlack,
        onBackground: AppColors.neutralWhite,
        error: AppColors.errorLight,
        onError: AppColors.neutralBlack,
      ),

      // Dark Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displayLarge.copyWith(
            color: AppColors.neutralWhite,
          ),
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displayMedium.copyWith(
            color: AppColors.neutralWhite,
          ),
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.displaySmall.copyWith(
            color: AppColors.neutralWhite,
          ),
        ),
        
        // Body text for dark mode
        bodyLarge: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.neutral200,
          ),
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutral200,
          ),
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.neutral300,
          ),
        ),
      ),

      // Dark AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.neutral900,
        foregroundColor: AppColors.neutralWhite,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          textStyle: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral200,
          size: 24,
        ),
      ),

      // Dark Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryMain, // Gold for dark mode
          foregroundColor: AppColors.neutralBlack,
          elevation: DesignTokens.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceL,
            vertical: DesignTokens.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
        ),
      ),

      // Dark Card Theme
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevationXS,
        shadowColor: AppColors.neutralBlack.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        color: AppColors.neutral800,
        surfaceTintColor: Colors.transparent,
      ),

      // Dark Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.neutral600,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.neutral600,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          borderSide: BorderSide(
            color: AppColors.secondaryMain,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral300,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Platform
      platform: TargetPlatform.iOS,
    );
  }

  /// Theme Mode Utility
  static ThemeMode getThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Theme Extensions for Custom Properties
extension AppThemeExtension on ThemeData {
  /// Glass morphism gradient
  LinearGradient get glassGradient => AppColors.glassGradient;
  
  /// Primary brand gradient
  LinearGradient get primaryGradient => AppColors.primaryGradient;
  
  /// Secondary brand gradient
  LinearGradient get secondaryGradient => AppColors.secondaryGradient;
  
  /// Luxury gradient
  LinearGradient get luxuryGradient => AppColors.luxuryGradient;
  
  /// Fashion AI gradient
  RadialGradient get fashionAIGradient => AppColors.fashionAIGradient;
}