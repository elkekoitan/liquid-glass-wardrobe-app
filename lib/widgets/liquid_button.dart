import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'glass_container.dart';

/// 3D liquid animated button with glass morphism effects
class LiquidButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button width
  final double? width;

  /// Button height
  final double height;

  /// Text style override
  final TextStyle? textStyle;

  /// Button color scheme
  final List<Color> gradientColors;

  /// Loading state
  final bool isLoading;

  /// Disabled state
  final bool isDisabled;

  /// Button size variant
  final LiquidButtonSize size;

  /// Animation intensity
  final double animationIntensity;

  /// Icon to show before text
  final IconData? leadingIcon;

  /// Icon to show after text
  final IconData? trailingIcon;

  const LiquidButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = AppSpacing.buttonMinHeight,
    this.textStyle,
    this.gradientColors = const [AppColors.liquidBlue, AppColors.liquidViolet],
    this.isLoading = false,
    this.isDisabled = false,
    this.size = LiquidButtonSize.medium,
    this.animationIntensity = 1.0,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// Named constructor for primary button
  const LiquidButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
    LiquidButtonSize size = LiquidButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         width: width,
         gradientColors: const [AppColors.liquidBlue, AppColors.liquidCyan],
         isLoading: isLoading,
         isDisabled: isDisabled,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
       );

  /// Named constructor for secondary button
  const LiquidButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
    LiquidButtonSize size = LiquidButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         width: width,
         gradientColors: const [AppColors.liquidPurple, AppColors.liquidViolet],
         isLoading: isLoading,
         isDisabled: isDisabled,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
       );

  /// Named constructor for success button
  const LiquidButton.success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
    LiquidButtonSize size = LiquidButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         width: width,
         gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
         isLoading: isLoading,
         isDisabled: isDisabled,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
       );

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _liquidController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _liquidAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Liquid animation controller (continuous)
    _liquidController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Scale animation for press effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    // Liquid movement animation
    _liquidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liquidController, curve: Curves.easeInOut),
    );

    // Glow intensity animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _liquidController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapCancel();
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _onTap() {
    if (!widget.isDisabled && !widget.isLoading && widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize();
    final textStyle = _getTextStyle();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pressController,
        _liquidController,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: buttonSize.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppSpacing.glassButtonRadius,
                  ),
                  boxShadow: _buildShadows(),
                ),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  onTap: _onTap,
                  child: Stack(
                    children: [
                      // Liquid background layer
                      _buildLiquidBackground(),

                      // Glass morphism layer
                      _buildGlassLayer(),

                      // Content layer
                      _buildContent(textStyle),

                      // Glow effect overlay
                      if (!widget.isDisabled) _buildGlowOverlay(),
                    ],
                  ),
                ),
              ),
            )
            .animate(delay: 100.ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.3, end: 0, duration: 400.ms);
      },
    );
  }

  Widget _buildLiquidBackground() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.glassButtonRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDisabled
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_liquidAnimation.value * 2 * 3.14159),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassLayer() {
    return Positioned.fill(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(AppSpacing.glassButtonRadius),
        opacity: 0.1,
        blurIntensity: 5.0,
        borderWidth: 1.0,
        borderColor: widget.isDisabled
            ? Colors.grey.withOpacity(0.3)
            : AppColors.glassBorderStrong,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Leading icon
            if (widget.leadingIcon != null && !widget.isLoading)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(
                  widget.leadingIcon,
                  color: textStyle.color,
                  size: AppSpacing.iconMD,
                ),
              ),

            // Loading indicator or text
            if (widget.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textStyle.color ?? Colors.white,
                  ),
                ),
              )
            else
              Flexible(
                child: Text(
                  widget.text,
                  style: textStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Trailing icon
            if (widget.trailingIcon != null && !widget.isLoading)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  widget.trailingIcon,
                  color: textStyle.color,
                  size: AppSpacing.iconMD,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.glassButtonRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2 * _glowAnimation.value),
                Colors.transparent,
                Colors.white.withOpacity(0.1 * _glowAnimation.value),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadows() {
    if (widget.isDisabled) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    final glowIntensity = _glowAnimation.value * widget.animationIntensity;
    final shadowColor = widget.gradientColors.first;

    return [
      // Main shadow
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      // Glow effect
      BoxShadow(
        color: shadowColor.withOpacity(0.3 * glowIntensity),
        blurRadius: 15 * glowIntensity,
        offset: Offset.zero,
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.1 * glowIntensity),
        blurRadius: 25 * glowIntensity,
        offset: Offset.zero,
      ),
    ];
  }

  ButtonSize _getButtonSize() {
    switch (widget.size) {
      case LiquidButtonSize.small:
        return const ButtonSize(height: 40);
      case LiquidButtonSize.medium:
        return const ButtonSize(height: AppSpacing.buttonMinHeight);
      case LiquidButtonSize.large:
        return const ButtonSize(height: 56);
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle;

    switch (widget.size) {
      case LiquidButtonSize.small:
        baseStyle = AppTypography.labelMedium;
        break;
      case LiquidButtonSize.medium:
        baseStyle = AppTypography.labelLarge;
        break;
      case LiquidButtonSize.large:
        baseStyle = AppTypography.h6;
        break;
    }

    final color = widget.isDisabled
        ? Colors.grey.shade700
        : AppColors.textOnGlass;

    return (widget.textStyle ?? baseStyle).copyWith(
      color: color,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );
  }
}

/// Button size variants
enum LiquidButtonSize { small, medium, large }

/// Helper class for button dimensions
class ButtonSize {
  final double height;

  const ButtonSize({required this.height});
}
