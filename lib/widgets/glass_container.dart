import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'shaders/liquid_glass_widget.dart';

/// Base glass container with morphism effects
/// This is the foundation widget for all glass UI components
class GlassContainer extends StatelessWidget {
  /// Child widget to be displayed inside the glass container
  final Widget? child;

  /// Width of the container (null for dynamic width)
  final double? width;

  /// Height of the container (null for dynamic height)
  final double? height;

  /// Padding inside the container
  final EdgeInsetsGeometry padding;

  /// Margin outside the container
  final EdgeInsetsGeometry margin;

  /// Border radius for rounded corners
  final BorderRadius borderRadius;

  /// Blur intensity for glass effect (higher = more blur)
  final double blurIntensity;

  /// Opacity of the glass surface (0.0 - 1.0)
  final double opacity;

  /// Border color for the glass edge
  final Color borderColor;

  /// Border width
  final double borderWidth;

  /// Whether to show animated liquid effects
  final bool showLiquidEffects;

  /// Intensity of liquid animation (0.0 - 1.0)
  final double liquidIntensity;

  /// Background gradient colors
  final List<Color>? gradientColors;

  /// Alignment for gradient
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  /// Callback for tap events
  final VoidCallback? onTap;

  /// Callback for long press events
  final VoidCallback? onLongPress;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.glassBorderRadius),
    ),
    this.blurIntensity = AppSpacing.glassBlurAmount,
    this.opacity = AppSpacing.glassOpacity,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = AppSpacing.glassBorderWidth,
    this.showLiquidEffects = false,
    this.liquidIntensity = 0.5,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.onTap,
    this.onLongPress,
  });

  /// Named constructor for strong glass effect
  const GlassContainer.strong({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.glassBorderRadius),
    ),
    List<Color>? gradientColors,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : this(
         key: key,
         child: child,
         width: width,
         height: height,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         blurIntensity: AppSpacing.glassBlurAmount * 1.5,
         opacity: AppSpacing.glassOpacityStrong,
         borderColor: AppColors.glassBorderStrong,
         borderWidth: AppSpacing.glassBorderWidth * 2,
         gradientColors: gradientColors,
         onTap: onTap,
         onLongPress: onLongPress,
       );

  /// Named constructor for light glass effect
  const GlassContainer.light({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.glassBorderRadius),
    ),
    List<Color>? gradientColors,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : this(
         key: key,
         child: child,
         width: width,
         height: height,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         blurIntensity: AppSpacing.glassBlurAmount * 0.7,
         opacity: AppSpacing.glassOpacityLight,
         borderColor: const Color(0x1AFFFFFF),
         borderWidth: AppSpacing.glassBorderWidth * 0.5,
         gradientColors: gradientColors,
         onTap: onTap,
         onLongPress: onLongPress,
       );

  /// Named constructor with liquid effects
  const GlassContainer.liquid({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.glassBorderRadius),
    ),
    double liquidIntensity = 0.8,
    List<Color>? gradientColors,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : this(
         key: key,
         child: child,
         width: width,
         height: height,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         showLiquidEffects: true,
         liquidIntensity: liquidIntensity,
         gradientColors: gradientColors,
         onTap: onTap,
         onLongPress: onLongPress,
       );

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: _buildGradient(),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Container(padding: padding, child: child),
        ),
      ),
    );

    // Add liquid effects if enabled
    if (showLiquidEffects) {
      container = Stack(
        children: [
          // Liquid background effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: LiquidGlassWidget(
                intensity: liquidIntensity,
                distortion: 0.05,
                animationDuration: const Duration(seconds: 4),
              ),
            ),
          ),
          // Glass container on top
          container,
        ],
      );
    }

    // Add interaction handlers
    if (onTap != null || onLongPress != null) {
      container = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: container,
      );
    }

    return container;
  }

  LinearGradient _buildGradient() {
    if (gradientColors != null && gradientColors!.isNotEmpty) {
      return LinearGradient(
        colors: gradientColors!
            .map((color) => color.withOpacity(opacity))
            .toList(),
        begin: gradientBegin,
        end: gradientEnd,
      );
    }

    // Default glass gradient
    return LinearGradient(
      colors: [
        AppColors.primaryGlass.withOpacity(opacity),
        AppColors.secondaryGlass.withOpacity(opacity * 0.7),
      ],
      begin: gradientBegin,
      end: gradientEnd,
    );
  }
}

/// Glass container with interactive hover effects
class InteractiveGlassContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final bool showHoverEffects;

  const InteractiveGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.glassBorderRadius),
    ),
    this.onTap,
    this.showHoverEffects = true,
  });

  @override
  State<InteractiveGlassContainer> createState() =>
      _InteractiveGlassContainerState();
}

class _InteractiveGlassContainerState extends State<InteractiveGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _opacityAnimation =
        Tween<double>(
          begin: AppSpacing.glassOpacity,
          end: AppSpacing.glassOpacityStrong,
        ).animate(
          CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!widget.showHoverEffects) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    if (!widget.showHoverEffects) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              borderRadius: widget.borderRadius,
              opacity: _opacityAnimation.value,
              borderColor: _isHovered
                  ? AppColors.liquidBlue.withOpacity(0.5)
                  : AppColors.glassBorder,
              onTap: widget.onTap,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
