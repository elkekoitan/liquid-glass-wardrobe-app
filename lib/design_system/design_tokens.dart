import 'package:flutter/material.dart';

/// Minimalist Design System Inspired by Dieter Rams - Less but Better
class DesignTokens {
  // Simplified Radius System - Following Rams' principle of thorough detail
  static const double radiusXS = 2.0; // Reduced for cleaner look
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusRound = 999.0;

  // Refined Spacing System - More consistent and minimal
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0; // Reduced from 16
  static const double spaceL = 16.0; // Reduced from 24
  static const double spaceXL = 24.0; // Reduced from 32
  static const double spaceXXL = 32.0; // Reduced from 48
  static const double spaceXXXL = 48.0; // Reduced from 64

  // Streamlined Typography Scale - Following Rams' unobtrusive principle
  static const double fontSizeXS =
      11.0; // Slightly increased for better readability
  static const double fontSizeS = 13.0;
  static const double fontSizeM = 15.0;
  static const double fontSizeL = 17.0;
  static const double fontSizeXL = 19.0;
  static const double fontSizeXXL = 21.0;
  static const double fontSizeDisplay = 25.0;
  static const double fontSizeHero = 31.0; // Slightly reduced for modesty

  // Minimal Elevation System - Less is more
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 3.0; // Reduced
  static const double elevationL = 4.0; // Reduced
  static const double elevationXL = 6.0; // Reduced
  static const double elevationXXL = 8.0; // Reduced

  // Refined Animation Durations - Smoother, less distracting
  static const Duration durationFast = Duration(
    milliseconds: 200,
  ); // Slightly slower
  static const Duration durationNormal = Duration(milliseconds: 350);
  static const Duration durationMedium = Duration(milliseconds: 450);
  static const Duration durationSlow = Duration(milliseconds: 550);
  static const Duration durationSlower = Duration(milliseconds: 800);

  // Simplified Animation Curves - More natural
  static const Curve curveSmooth = Curves.easeInOutQuart; // Smoother
  static const Curve curveBounce = Curves.easeOutBack; // Less aggressive
  static const Curve curveSharp = Curves.easeInOut;
}

/// Minimalist Color System Inspired by Dieter Rams - Honest and Long-lasting
class AppColors {
  // Primary Colors - Reduced palette, following "less but better"
  static const Color primaryMain = Color(0xFF000000); // Pure black - timeless
  static const Color primaryLight = Color(0xFF333333); // Dark gray
  static const Color primaryDark = Color(
    0xFF000000,
  ); // Same as main for consistency
  static const Color primarySurface = Color(0xFFFFFFFF); // Pure white

  // Secondary Colors - Single accent, unobtrusive
  static const Color secondaryMain = Color(0xFF9E9E9E); // Subtle gray accent
  static const Color secondaryLight = Color(0xFFBDBDBD); // Lighter gray
  static const Color secondaryDark = Color(0xFF757575); // Darker gray
  static const Color secondarySurface = Color(0xFFF5F5F5); // Very light gray

  // Neutral Colors - Simplified scale
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutralBlack = Color(0xFF000000);
  static const Color neutralWhite = Color(0xFFFFFFFF);

  // Semantic Colors - Minimal and functional
  static const Color success = Color(
    0xFF4CAF50,
  ); // Green - clear and understandable
  static const Color successLight = Color(0xFF81C784);
  static const Color successSurface = Color(0xFFF1F8E9);

  static const Color warning = Color(
    0xFFFF9800,
  ); // Orange - attention-grabbing but not aggressive
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningSurface = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFF44336); // Red - honest and direct
  static const Color errorMain = error;
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorSurface = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF2196F3); // Blue - informative
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoSurface = Color(0xFFE3F2FD);

  // Additional primary/secondary/tertiary colors for compatibility
  static const Color primary500 = primaryMain;
  static const Color secondary500 = secondaryMain;
  static const Color tertiary500 = warning;

  // Glass & Overlay Colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0xB3000000);

  // Professional Fashion Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [neutral800, neutralBlack],
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryMain, secondaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  // Luxury brand gradient (Gold accent)
  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8C5A0), // Light gold
      Color(0xFFD4A574), // Warm gold
      Color(0xFFB8956A), // Deep gold
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Sophisticated neutral gradient
  static const LinearGradient neutralGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF7F7F7), // Light gray
      Color(0xFFE8E8E8), // Medium gray
      Color(0xFFD1D1D1), // Darker gray
    ],
  );

  // Glass morphism gradient
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40FFFFFF), Color(0x20FFFFFF), Color(0x10FFFFFF)],
  );

  // Glassmorphism gradient alias
  static const LinearGradient glassmorphismGradient = glassGradient;

  // Professional fashion gradients (maintaining compatibility)
  static const LinearGradient instagramGradient = luxuryGradient;
  static const LinearGradient sunsetGradient = neutralGradient;

  // AI/Fashion themed gradient
  static const RadialGradient fashionAIGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [
      Color(0xFF8B5CF6), // Purple
      Color(0xFFFF6B9D), // Pink
      Color(0xFFFFA726), // Orange
    ],
  );
}

/// Minimal Typography System - Inspired by Rams' thorough detail principle
class AppTextStyles {
  static const String fontFamily = 'Inter'; // Single, clean font family
  static const String fontFamilyDisplay = 'Inter'; // Same for consistency
  static const String fontFamilyMono = 'JetBrains Mono';

  // Display Styles - Simplified hierarchy
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeHero,
    fontWeight: FontWeight.w500, // Medium weight for elegance
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.neutral900,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeDisplay,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    height: 1.25,
    color: AppColors.neutral900,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeXXL,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.neutral900,
  );

  // Heading Styles - Consistent weight
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeXL,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.neutral900,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeL,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.neutral800,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeM,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.neutral800,
  );

  // Body Styles - Optimized for readability
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeL,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: AppColors.neutral700,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeM,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: AppColors.neutral700,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeS,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.neutral600,
  );

  // Label Styles - Functional
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeM,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.neutral800,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeS,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.neutral700,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeXS,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.neutral600,
  );

  // Title Styles - Unified
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeL,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.neutral900,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeM,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.neutral900,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeS,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.neutral900,
  );

  // Button Styles - Consistent
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeL,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeM,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: DesignTokens.fontSizeS,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
  );

  // Monospace - Minimal
  static const TextStyle mono = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: DesignTokens.fontSizeS,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.neutral700,
  );

  // Material 3 TextTheme mapping
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

/// Minimal Shadow System - Following Rams' unobtrusive principle
class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x10000000), // Reduced opacity
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x15000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x20000000), offset: Offset(0, 4), blurRadius: 8),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x25000000), offset: Offset(0, 6), blurRadius: 12),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x30000000), offset: Offset(0, 8), blurRadius: 16),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(color: Color(0x35000000), offset: Offset(0, 12), blurRadius: 24),
  ];

  // Colored shadows for special effects
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x40818CF8), // Primary light with opacity
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glassEffect = [
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 4),
      blurRadius: 18,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
}
