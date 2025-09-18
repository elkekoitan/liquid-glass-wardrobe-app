import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';

enum ModernButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
  success,
  glass,
  gradient,
}

enum ModernButtonSize { small, medium, large, xl }

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final bool hasShadow;
  final bool hasHaptics;
  final Widget? customChild;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ModernButtonVariant.primary,
    this.size = ModernButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.hasShadow = true,
    this.hasHaptics = true,
    this.customChild,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Faster, more responsive
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.96, // Subtle press effect
        ).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
        );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    if (widget.hasHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  _ButtonColors _getColorScheme() {
    switch (widget.variant) {
      case ModernButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.primaryMain,
          backgroundHovered: AppColors.primaryDark,
          backgroundPressed: AppColors.primaryDark,
          foreground: AppColors.neutralWhite,
        );
      case ModernButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.neutral100,
          backgroundHovered: AppColors.neutral200,
          backgroundPressed: AppColors.neutral300,
          foreground: AppColors.neutral900,
          borderColor: AppColors.neutral200,
        );
      case ModernButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHovered: AppColors.neutral100,
          backgroundPressed: AppColors.neutral200,
          foreground: AppColors.neutral700,
        );
      case ModernButtonVariant.destructive:
        return _ButtonColors(
          background: AppColors.error,
          backgroundHovered: AppColors.errorLight,
          backgroundPressed: AppColors.errorLight,
          foreground: AppColors.neutralWhite,
        );
      case ModernButtonVariant.success:
        return _ButtonColors(
          background: AppColors.success,
          backgroundHovered: AppColors.successLight,
          backgroundPressed: AppColors.successLight,
          foreground: AppColors.neutralWhite,
        );
      case ModernButtonVariant.glass:
        return _ButtonColors(
          background: AppColors.glassLight,
          backgroundHovered: AppColors.glassLight.withValues(alpha: 0.3),
          backgroundPressed: AppColors.glassLight.withValues(alpha: 0.4),
          foreground: AppColors.neutral900,
          borderColor: AppColors.neutral200.withValues(alpha: 0.5),
        );
      case ModernButtonVariant.gradient:
        return _ButtonColors(
          background: AppColors.primaryMain,
          backgroundHovered: AppColors.primaryDark,
          backgroundPressed: AppColors.primaryDark,
          foreground: AppColors.neutralWhite,
        );
    }
  }

  _ButtonSizes _getSizeValues() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceS,
          ),
          minimumSize: const Size(0, 36),
          borderRadius: DesignTokens.radiusM,
          fontSize: DesignTokens.fontSizeS,
          iconSize: 16,
        );
      case ModernButtonSize.medium:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceL,
            vertical: DesignTokens.spaceM,
          ),
          minimumSize: const Size(0, 44),
          borderRadius: DesignTokens.radiusL,
          fontSize: DesignTokens.fontSizeM,
          iconSize: 18,
        );
      case ModernButtonSize.large:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceXL,
            vertical: DesignTokens.spaceL,
          ),
          minimumSize: const Size(0, 52),
          borderRadius: DesignTokens.radiusL,
          fontSize: DesignTokens.fontSizeL,
          iconSize: 20,
        );
      case ModernButtonSize.xl:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceXXL,
            vertical: DesignTokens.spaceXL,
          ),
          minimumSize: const Size(0, 60),
          borderRadius: DesignTokens.radiusXL,
          fontSize: DesignTokens.fontSizeXL,
          iconSize: 24,
        );
    }
  }

  TextStyle _getTextStyle() {
    final sizes = _getSizeValues();
    final colors = _getColorScheme();

    return TextStyle(
      fontSize: sizes.fontSize,
      fontWeight: FontWeight.w600,
      color: colors.foreground,
      height: 1.2,
      letterSpacing: 0.1,
    );
  }

  Widget _buildButtonContent() {
    final sizes = _getSizeValues();

    if (widget.customChild != null) {
      return widget.customChild!;
    }

    final children = <Widget>[];

    if (widget.leadingIcon != null && !widget.isLoading) {
      children.add(Icon(widget.leadingIcon, size: sizes.iconSize));
      children.add(const SizedBox(width: DesignTokens.spaceS));
    }

    if (widget.isLoading) {
      children.add(
        SizedBox(
          width: sizes.iconSize,
          height: sizes.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorScheme().foreground,
            ),
          ),
        ),
      );
      children.add(const SizedBox(width: DesignTokens.spaceS));
    }

    children.add(
      Text(widget.text, style: _getTextStyle(), textAlign: TextAlign.center),
    );

    if (widget.trailingIcon != null && !widget.isLoading) {
      children.add(const SizedBox(width: DesignTokens.spaceS));
      children.add(Icon(widget.trailingIcon, size: sizes.iconSize));
    }

    return Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildShimmerEffect(Widget child) {
    if (widget.variant != ModernButtonVariant.primary) return child;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _getSizeValues().borderRadius,
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
                        Colors.transparent,
                        Colors.white24,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(
                        _shimmerAnimation.value * 3.14,
                      ),
                    ).createShader(bounds);
                  },
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        width: widget.isExpanded ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_getSizeValues().borderRadius),
          boxShadow: widget.hasShadow && !_isPressed
              ? (widget.variant == ModernButtonVariant.primary
                    ? AppShadows.primaryGlow
                    : AppShadows.md)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_getSizeValues().borderRadius),
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(_getSizeValues().borderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: _getColorScheme().background,
                borderRadius: BorderRadius.circular(
                  _getSizeValues().borderRadius,
                ),
                border: _getColorScheme().borderColor != null
                    ? Border.all(
                        color: _getColorScheme().borderColor!,
                        width: 1.5,
                      )
                    : null,
              ),
              padding: _getSizeValues().padding,
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );

    return _buildShimmerEffect(button);
  }
}

class _ButtonColors {
  final Color background;
  final Color backgroundHovered;
  final Color backgroundPressed;
  final Color foreground;
  final Color? borderColor;

  _ButtonColors({
    required this.background,
    required this.backgroundHovered,
    required this.backgroundPressed,
    required this.foreground,
    this.borderColor,
  });
}

class _ButtonSizes {
  final EdgeInsets padding;
  final Size minimumSize;
  final double borderRadius;
  final double fontSize;
  final double iconSize;

  _ButtonSizes({
    required this.padding,
    required this.minimumSize,
    required this.borderRadius,
    required this.fontSize,
    required this.iconSize,
  });
}
