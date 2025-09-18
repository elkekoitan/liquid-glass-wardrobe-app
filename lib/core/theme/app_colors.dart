import 'package:flutter/material.dart';

/// Liquid Glass App Color Palette
/// Inspired by glass morphism and liquid animations
class AppColors {
  AppColors._();

  // Primary Glass Colors
  static const Color primaryGlass = Color(0x33FFFFFF);     // Semi-transparent white
  static const Color secondaryGlass = Color(0x1AFFFFFF);   // More transparent white
  static const Color tertiaryGlass = Color(0x0DFFFFFF);    // Very light glass effect
  
  // Liquid Colors with vibrant gradients
  static const Color liquidBlue = Color(0xFF00D2FF);
  static const Color liquidPurple = Color(0xFF3A1C71);
  static const Color liquidPink = Color(0xFFD946EF);
  static const Color liquidCyan = Color(0xFF06B6D4);
  static const Color liquidViolet = Color(0xFF8B5CF6);
  
  // Glass Border Colors
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderStrong = Color(0x4DFFFFFF);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundGradientStart = Color(0xFF1E293B);
  static const Color backgroundGradientEnd = Color(0xFF0F172A);
  
  // Text Colors for glass surfaces
  static const Color textOnGlass = Color(0xFFFFFFFF);
  static const Color textOnGlassSecondary = Color(0xCCFFFFFF);
  static const Color textOnGlassTertiary = Color(0x99FFFFFF);
  
  // Success, Warning, Error with glass effect
  static const Color successGlass = Color(0x3310B981);
  static const Color warningGlass = Color(0x33F59E0B);
  static const Color errorGlass = Color(0x33EF4444);
  
  // Shimmer colors for loading effects
  static const Color shimmerBase = Color(0x33FFFFFF);
  static const Color shimmerHighlight = Color(0x4DFFFFFF);
  
  // Gradient definitions for liquid effects
  static const LinearGradient liquidGradient1 = LinearGradient(
    colors: [liquidBlue, liquidPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient liquidGradient2 = LinearGradient(
    colors: [liquidPink, liquidViolet],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient liquidGradient3 = LinearGradient(
    colors: [liquidCyan, liquidBlue, liquidViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [primaryGlass, secondaryGlass],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const RadialGradient liquidRadialGradient = RadialGradient(
    colors: [liquidPink, liquidViolet, liquidBlue],
    radius: 2.0,
  );
  
  // Dark theme variants
  static const Color primaryGlassDark = Color(0x1A000000);
  static const Color secondaryGlassDark = Color(0x0D000000);
  static const Color glassBorderDark = Color(0x1A000000);
  
  // Method to get glass color with custom opacity
  static Color glassWithOpacity(double opacity) {
    return Colors.white.withOpacity(opacity);
  }
  
  // Method to get liquid color variations
  static Color liquidColorVariation(Color baseColor, double variation) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness + variation).clamp(0.0, 1.0)).toColor();
  }
  
  // Standard Material Design getters for compatibility
  static Color get primary => liquidBlue;
  static Color get secondary => liquidViolet;
  static Color get surface => backgroundLight;
  static Color get surfaceVariant => Color(0xFFE2E8F0);
  static Color get error => Color(0xFFEF4444);
  static Color get success => Color(0xFF10B981);
  static Color get warning => Color(0xFFF59E0B);
  
  // Text color getters
  static Color get textPrimary => Color(0xFF1E293B);
  static Color get textSecondary => Color(0xFF64748B);
  static Color get textTertiary => Color(0xFF94A3B8);
}
