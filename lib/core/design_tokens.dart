import 'package:flutter/material.dart';
import 'theme/app_spacing.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

/// Unified design system tokens for the Liquid Glass OTP App
/// Provides consistent access to spacing, colors, typography, and other design elements
class DesignTokens {
  DesignTokens._();

  /// Spacing values based on 8px grid system
  static const spacing = _Spacing();
  
  /// Color palette for the app
  static const colors = _Colors();
  
  /// Typography system
  static const typography = _Typography();
  
  /// Border radius values
  static const borderRadius = _BorderRadius();
  
  /// Animation durations
  static const animation = _Animation();
  
  /// Glass morphism specific values
  static const glass = _Glass();
}

class _Spacing {
  const _Spacing();
  
  double get xxxs => AppSpacing.xxxs; // 2px
  double get xxs => AppSpacing.xxs;   // 4px
  double get xs => AppSpacing.xs;     // 6px
  double get sm => AppSpacing.sm;     // 8px
  double get md => AppSpacing.md;     // 12px
  double get lg => AppSpacing.lg;     // 16px
  double get xl => AppSpacing.xl;     // 20px
  double get xxl => AppSpacing.xxl;   // 24px
  double get xxxl => AppSpacing.xxxl; // 32px
  double get huge => AppSpacing.huge; // 40px
  double get massive => AppSpacing.massive; // 48px
  double get giant => AppSpacing.giant; // 64px
}

class _Colors {
  const _Colors();
  
  // Primary colors
  Color get primary => AppColors.liquidBlue;
  Color get secondary => AppColors.liquidViolet;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  
  // Glass colors
  Color get primaryGlass => AppColors.primaryGlass;
  Color get secondaryGlass => AppColors.secondaryGlass;
  Color get glassBorder => AppColors.glassBorder;
  
  // Text colors
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textOnGlass => AppColors.textOnGlass;
  
  // Background colors
  Color get backgroundLight => AppColors.backgroundLight;
  Color get backgroundDark => AppColors.backgroundDark;
  
  // Liquid colors
  Color get liquidBlue => AppColors.liquidBlue;
  Color get liquidPurple => AppColors.liquidPurple;
  Color get liquidPink => AppColors.liquidPink;
  Color get liquidCyan => AppColors.liquidCyan;
  Color get liquidViolet => AppColors.liquidViolet;
  
  // Gradients
  LinearGradient get liquidGradient1 => AppColors.liquidGradient1;
  LinearGradient get liquidGradient2 => AppColors.liquidGradient2;
  LinearGradient get liquidGradient3 => AppColors.liquidGradient3;
  LinearGradient get glassGradient => AppColors.glassGradient;
}

class _Typography {
  const _Typography();
  
  // Headings
  TextStyle get displayLarge => AppTypography.displayLarge;
  TextStyle get displayMedium => AppTypography.displayMedium;
  TextStyle get displaySmall => AppTypography.displaySmall;
  TextStyle get headlineLarge => AppTypography.h1;
  TextStyle get headlineMedium => AppTypography.h2;
  TextStyle get headlineSmall => AppTypography.h3;
  TextStyle get titleLarge => AppTypography.h4;
  TextStyle get titleMedium => AppTypography.h5;
  TextStyle get titleSmall => AppTypography.h6;
  
  // Body text
  TextStyle get bodyLarge => AppTypography.bodyLarge;
  TextStyle get bodyMedium => AppTypography.bodyMedium;
  TextStyle get bodySmall => AppTypography.bodySmall;
  
  // Labels
  TextStyle get labelLarge => AppTypography.labelLarge;
  TextStyle get labelMedium => AppTypography.labelMedium;
  TextStyle get labelSmall => AppTypography.labelSmall;
  
  // Glass specific
  TextStyle get glassTitle => AppTypography.glassTitle;
  TextStyle get glassSubtitle => AppTypography.glassSubtitle;
  
  // Special
  TextStyle get monospace => AppTypography.monospace;
  TextStyle get otpStyle => AppTypography.otpStyle;
  TextStyle get caption => AppTypography.caption;
  TextStyle get overline => AppTypography.overline;
}

class _BorderRadius {
  const _BorderRadius();
  
  double get xs => AppSpacing.radiusXS;     // 4px
  double get sm => AppSpacing.radiusSM;     // 6px
  double get md => AppSpacing.radiusMD;     // 8px
  double get lg => AppSpacing.radiusLG;     // 12px
  double get xl => AppSpacing.radiusXL;     // 16px
  double get xxl => AppSpacing.radiusXXL;   // 20px
  double get round => AppSpacing.radiusRound; // 50px
  
  // Glass specific
  double get glass => AppSpacing.glassBorderRadius; // 16px
  double get glassCard => AppSpacing.glassCardRadius; // 20px
  double get glassButton => AppSpacing.glassButtonRadius; // 12px
}

class _Animation {
  const _Animation();
  
  Duration get fast => Duration(milliseconds: AppSpacing.animationFast);       // 200ms
  Duration get medium => Duration(milliseconds: AppSpacing.animationMedium);   // 300ms
  Duration get slow => Duration(milliseconds: AppSpacing.animationSlow);       // 500ms
  Duration get veryClose => Duration(milliseconds: AppSpacing.animationVeryClose); // 1000ms
  
  // Glass specific
  Duration get liquidAnimation => Duration(milliseconds: AppSpacing.liquidAnimationDuration); // 800ms
  Duration get glassTransition => Duration(milliseconds: AppSpacing.glassTransitionDuration); // 250ms
}

class _Glass {
  const _Glass();
  
  double get opacity => AppSpacing.glassOpacity;
  double get opacityLight => AppSpacing.glassOpacityLight;
  double get opacityStrong => AppSpacing.glassOpacityStrong;
  double get blurAmount => AppSpacing.glassBlurAmount;
  double get borderWidth => AppSpacing.glassBorderWidth;
  double get blurRadius => AppSpacing.glassBlurRadius;
  
  // Liquid specific
  double get liquidGlowRadius => AppSpacing.liquidGlowRadius;
  double get liquidGlowSpread => AppSpacing.liquidGlowSpread;
}