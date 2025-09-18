import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../design_system/design_tokens.dart';

/// Advanced Liquid Glass Container with Shader Effects
/// Provides comprehensive glass morphism effects for luxury fashion brand
class LiquidGlassContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Gradient? gradient;
  final double opacity;
  final double blurRadius;
  final Color? shadowColor;
  final double shadowOpacity;
  final Offset shadowOffset;
  final VoidCallback? onTap;
  final bool isInteractive;
  final Duration animationDuration;
  final Curve animationCurve;

  // Glass effect properties
  final double glassIntensity;
  final bool enableRipple;
  final bool enableShimmer;
  final Color rippleColor;

  const LiquidGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.opacity = 0.05, // Reduced opacity for minimalism
    this.blurRadius = 5.0, // Reduced blur for subtlety
    this.shadowColor,
    this.shadowOpacity = 0.05, // Reduced shadow
    this.shadowOffset = const Offset(0, 2), // Reduced offset
    this.onTap,
    this.isInteractive = true,
    this.animationDuration = const Duration(milliseconds: 150), // Faster, less distracting
    this.animationCurve = Curves.easeInOut,
    this.glassIntensity = 0.5, // Reduced intensity
    this.enableRipple = false, // Disabled for minimalism
    this.enableShimmer = false, // Disabled
    this.rippleColor = Colors.white,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Minimal glass properties - following Rams' "less but better"
    final effectiveGradient =
        widget.gradient ??
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(widget.opacity),
            Colors.white.withOpacity(widget.opacity * 0.5),
          ],
        );

    final effectiveShadowColor =
        widget.shadowColor ?? (isDark ? Colors.black : AppColors.neutral900);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animValue = _animationController.value;
        final blur = widget.blurRadius + (animValue * 2); // Minimal blur change

        return Container(
          margin: widget.margin,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius:
                    (widget.borderRadius ??
                            BorderRadius.circular(DesignTokens.radiusL))
                        as BorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: effectiveShadowColor.withOpacity(
                      widget.shadowOpacity,
                    ),
                    offset: widget.shadowOffset,
                    blurRadius: blur,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    (widget.borderRadius ??
                            BorderRadius.circular(DesignTokens.radiusL))
                        as BorderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blur * widget.glassIntensity,
                    sigmaY: blur * widget.glassIntensity,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: effectiveGradient,
                      borderRadius:
                          (widget.borderRadius ??
                                  BorderRadius.circular(DesignTokens.radiusL))
                              as BorderRadius,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            (widget.borderRadius ??
                                    BorderRadius.circular(
                                      DesignTokens.radiusL,
                                    ))
                                as BorderRadius?,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: widget.onTap,
                        child: Container(
                          padding: widget.padding,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      (widget.borderRadius ??
                              BorderRadius.circular(DesignTokens.radiusL))
                          as BorderRadius,
                  gradient: LinearGradient(
                    begin: const Alignment(-1.0, -0.3),
                    end: const Alignment(1.0, 0.3),
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .slideX(
              duration: 1500.ms,
              begin: -1,
              end: 1,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

/// Pre-built Glass Card Component
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool enableShadow;
  final bool enableShimmer;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.width,
    this.height,
    this.enableShadow = true,
    this.enableShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceM),
      onTap: onTap,
      shadowOpacity: enableShadow ? 0.1 : 0.0,
      enableShimmer: enableShimmer,
      child: child,
    );
  }
}

/// Glass Button Component
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final bool isLoading;
  final Color? color;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryMain;

    return LiquidGlassContainer(
      width: width,
      height: height ?? 50,
      onTap: isLoading ? null : onPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceL,
        vertical: DesignTokens.spaceM,
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          effectiveColor.withOpacity(0.8),
          effectiveColor.withOpacity(0.6),
        ],
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.neutralWhite,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}

/// Glass Input Field Component
class GlassTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const GlassTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceM),
      opacity: 0.05,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spaceM,
          ),
        ),
      ),
    );
  }
}
