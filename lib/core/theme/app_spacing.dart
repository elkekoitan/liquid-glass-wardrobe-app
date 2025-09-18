/// Spacing and sizing constants for consistent UI
/// Based on 8px grid system with liquid glass specific measurements
class AppSpacing {
  AppSpacing._();

  // Base unit (8px) - all spacing should be multiples of this
  static const double baseUnit = 8.0;

  // Spacing scale
  static const double xxxs = baseUnit * 0.25; // 2px
  static const double xxs = baseUnit * 0.5; // 4px
  static const double xs = baseUnit * 0.75; // 6px
  static const double sm = baseUnit * 1.0; // 8px
  static const double md = baseUnit * 1.5; // 12px
  static const double lg = baseUnit * 2.0; // 16px
  static const double xl = baseUnit * 2.5; // 20px
  static const double xxl = baseUnit * 3.0; // 24px
  static const double xxxl = baseUnit * 4.0; // 32px
  static const double huge = baseUnit * 5.0; // 40px
  static const double massive = baseUnit * 6.0; // 48px
  static const double giant = baseUnit * 8.0; // 64px

  // Screen margins and padding
  static const double screenMarginHorizontal = lg; // 16px
  static const double screenMarginVertical = xl; // 20px
  static const double screenPadding = lg; // 16px

  // Component specific spacing
  static const double cardPadding = lg; // 16px
  static const double cardMargin = md; // 12px
  static const double buttonPadding = md; // 12px
  static const double buttonMinHeight = 48.0; // Minimum touch target
  static const double inputPadding = lg; // 16px
  static const double inputHeight = 56.0; // Standard input height

  // Glass specific spacing
  static const double glassBorderWidth = 1.0;
  static const double glassBlurRadius = 20.0;
  static const double glassBorderRadius = 16.0;
  static const double glassCardRadius = 20.0;
  static const double glassButtonRadius = 12.0;

  // Elevation and depth
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationExtreme = 16.0;

  // Animation durations (in milliseconds)
  static const int animationFast = 200;
  static const int animationMedium = 300;
  static const int animationSlow = 500;
  static const int animationVeryClose = 1000;
  static const int liquidAnimationDuration = 800;
  static const int glassTransitionDuration = 250;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Safe area and status bar
  static const double statusBarHeight = 24.0;
  static const double navigationBarHeight = 80.0;
  static const double bottomBarHeight = 60.0;

  // Icon sizes
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;
  static const double iconHuge = 64.0;

  // Border radius variations
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusRound = 50.0;

  // Glass morphism specific values
  static const double glassOpacity = 0.2;
  static const double glassOpacityLight = 0.1;
  static const double glassOpacityStrong = 0.3;
  static const double glassBlurAmount = 15.0;
  static const double liquidGlowRadius = 20.0;
  static const double liquidGlowSpread = 5.0;

  // Layout constraints
  static const double maxContentWidth = 400.0;
  static const double maxCardWidth = 360.0;
  static const double minButtonWidth = 120.0;
  static const double maxButtonWidth = 280.0;

  // List and grid spacing
  static const double listItemSpacing = md; // 12px
  static const double gridItemSpacing = lg; // 16px
  static const double sectionSpacing = xxl; // 24px
  static const double groupSpacing = xxxl; // 32px

  // Form spacing
  static const double formFieldSpacing = lg; // 16px
  static const double formGroupSpacing = xxl; // 24px
  static const double formButtonSpacing = xxxl; // 32px
}
