import 'package:flutter/material.dart';

/// Typography system for Liquid Glass App
/// Optimized for readability on glass surfaces with proper contrast
class AppTypography {
  AppTypography._();

  // Font families
  static const String primaryFontFamily = 'SF Pro Display';
  static const String secondaryFontFamily = 'Inter';
  static const String monospaceFontFamily = 'SF Mono';

  // Font weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Font sizes
  static const double fontSizeXXS = 10.0;
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;
  static const double fontSize5XL = 48.0;
  static const double fontSize6XL = 60.0;
  static const double fontSize7XL = 72.0;
  static const double fontSize8XL = 96.0;

  // Line heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter spacing for glass effect readability
  static const double letterSpacingTight = -0.025;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.025;
  static const double letterSpacingWider = 0.05;
  static const double letterSpacingWidest = 0.1;

  // Text styles for headings
  static TextStyle get h1 => TextStyle(
    fontSize: fontSize6XL,
    fontWeight: black,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 4,
        color: Colors.black.withOpacity(0.25),
      ),
    ],
  );

  static TextStyle get h2 => TextStyle(
    fontSize: fontSize5XL,
    fontWeight: extraBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 1),
        blurRadius: 3,
        color: Colors.black.withOpacity(0.2),
      ),
    ],
  );

  static TextStyle get h3 => TextStyle(
    fontSize: fontSize4XL,
    fontWeight: bold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    shadows: [
      Shadow(
        offset: const Offset(0, 1),
        blurRadius: 2,
        color: Colors.black.withOpacity(0.15),
      ),
    ],
  );

  static TextStyle get h4 => TextStyle(
    fontSize: fontSize3XL,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static TextStyle get h5 => TextStyle(
    fontSize: fontSize2XL,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static TextStyle get h6 => TextStyle(
    fontSize: fontSizeXL,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  // Body text styles
  static TextStyle get bodyLarge => TextStyle(
    fontSize: fontSizeLG,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightRelaxed,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: fontSizeBase,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: fontSizeSM,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  // Label styles for buttons and UI elements
  static TextStyle get labelLarge => TextStyle(
    fontSize: fontSizeSM,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightTight,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: fontSizeXS,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightTight,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: fontSizeXXS,
    fontWeight: medium,
    letterSpacing: letterSpacingWidest,
    height: lineHeightTight,
  );

  // Display styles for hero content
  static TextStyle get displayLarge => TextStyle(
    fontSize: fontSize8XL,
    fontWeight: black,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 4),
        blurRadius: 8,
        color: Colors.black.withOpacity(0.3),
      ),
    ],
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: fontSize7XL,
    fontWeight: extraBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 3),
        blurRadius: 6,
        color: Colors.black.withOpacity(0.25),
      ),
    ],
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: fontSize6XL,
    fontWeight: bold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 4,
        color: Colors.black.withOpacity(0.2),
      ),
    ],
  );

  // Monospace for code/OTP
  static TextStyle get monospace => TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: fontSizeBase,
    fontWeight: regular,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static TextStyle get otpStyle => TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: fontSize2XL,
    fontWeight: bold,
    letterSpacing: letterSpacingWider,
    height: lineHeightTight,
  );

  // Special glass effect text styles
  static TextStyle get glassTitle => TextStyle(
    fontSize: fontSize3XL,
    fontWeight: semiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightTight,
    shadows: [
      Shadow(
        offset: const Offset(0, 1),
        blurRadius: 2,
        color: Colors.black.withOpacity(0.3),
      ),
      Shadow(
        offset: const Offset(0, 0),
        blurRadius: 4,
        color: Colors.white.withOpacity(0.1),
      ),
    ],
  );

  static TextStyle get glassSubtitle => TextStyle(
    fontSize: fontSizeLG,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    shadows: [
      Shadow(
        offset: const Offset(0, 1),
        blurRadius: 1,
        color: Colors.black.withOpacity(0.2),
      ),
    ],
  );

  // Caption styles
  static TextStyle get caption => TextStyle(
    fontSize: fontSizeXS,
    fontWeight: regular,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static TextStyle get overline => TextStyle(
    fontSize: fontSizeXS,
    fontWeight: medium,
    letterSpacing: letterSpacingWidest,
    height: lineHeightTight,
  );

  // Helper method to apply glass effect to any text style
  static TextStyle withGlassEffect(TextStyle style) {
    return style.copyWith(
      shadows: [
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.3),
        ),
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 4,
          color: Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  // Helper method to apply liquid glow effect
  static TextStyle withLiquidGlow(TextStyle style, Color glowColor) {
    return style.copyWith(
      shadows: [
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 10,
          color: glowColor.withOpacity(0.5),
        ),
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 20,
          color: glowColor.withOpacity(0.3),
        ),
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 3,
          color: Colors.black.withOpacity(0.3),
        ),
      ],
    );
  }

  // Additional getters for compatibility
  static TextStyle get headingMedium => TextStyle(
    fontSize: fontSize2XL,
    fontWeight: bold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static TextStyle get bodyExtraSmall => TextStyle(
    fontSize: fontSizeXS,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );
}
