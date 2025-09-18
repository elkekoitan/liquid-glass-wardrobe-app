import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_tokens.dart';

enum CardVariant { elevated, outlined, filled, glass, gradient }

class ModernCard extends StatefulWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool hasShadow;
  final bool hasHoverEffect;
  final bool hasHapticFeedback;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.hasShadow = true,
    this.hasHoverEffect = true,
    this.hasHapticFeedback = true,
    this.elevation,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: DesignTokens.durationNormal,
    );
    _pressController = AnimationController(
      vsync: this,
      duration: DesignTokens.durationFast,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: DesignTokens.curveSmooth,
      ),
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: DesignTokens.curveSharp),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHoverEnter() {
    if (!widget.hasHoverEffect) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit() {
    if (!widget.hasHoverEffect) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  BoxDecoration _getDecoration() {
    Color backgroundColor =
        widget.backgroundColor ?? _getDefaultBackgroundColor();

    switch (widget.variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? DesignTokens.radiusL,
          ),
          boxShadow: widget.hasShadow
              ? (_isHovered ? AppShadows.lg : AppShadows.md)
              : AppShadows.none,
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? DesignTokens.radiusL,
          ),
          border: Border.all(color: AppColors.neutral200, width: 1.5),
          boxShadow: widget.hasShadow && _isHovered
              ? AppShadows.sm
              : AppShadows.none,
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? DesignTokens.radiusL,
          ),
        );

      case CardVariant.glass:
        return BoxDecoration(
          color: AppColors.glassLight,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? DesignTokens.radiusL,
          ),
          border: Border.all(
            color: AppColors.neutral200.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: widget.hasShadow
              ? AppShadows.glassEffect
              : AppShadows.none,
        );

      case CardVariant.gradient:
        return BoxDecoration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? DesignTokens.radiusL,
          ),
          boxShadow: widget.hasShadow
              ? AppShadows.primaryGlow
              : AppShadows.none,
        );
    }
  }

  Color _getDefaultBackgroundColor() {
    switch (widget.variant) {
      case CardVariant.elevated:
      case CardVariant.outlined:
      case CardVariant.filled:
        return AppColors.neutralWhite;
      case CardVariant.glass:
        return Colors.transparent;
      case CardVariant.gradient:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _pressAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: Container(
            padding:
                widget.padding ?? const EdgeInsets.all(DesignTokens.spaceL),
            decoration: _getDecoration(),
            child: widget.child,
          ),
        );
      },
    );

    if (widget.onTap != null) {
      card = MouseRegion(
        onEnter: (_) => _handleHoverEnter(),
        onExit: (_) => _handleHoverExit(),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => _handleTapDown(),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: card,
        ),
      );
    }

    return card;
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool hasBlur;
  final double blurAmount;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.hasBlur = true,
    this.blurAmount = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.glassLight,
        borderRadius: BorderRadius.circular(
          borderRadius ?? DesignTokens.radiusL,
        ),
        border: Border.all(
          color: AppColors.neutral200.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppShadows.glassEffect,
      ),
      child: child,
    );

    if (hasBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? DesignTokens.radiusL,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? DesignTokens.radiusL,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isSelected;
  final bool hasBadge;
  final String? badgeText;

  const FeatureCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.customIcon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.isSelected = false,
    this.hasBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      variant: isSelected ? CardVariant.gradient : CardVariant.elevated,
      gradient: isSelected ? AppColors.primaryGradient : null,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null || customIcon != null) ...[
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceM),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryMain).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                  child:
                      customIcon ??
                      Icon(
                        icon,
                        color: iconColor ?? AppColors.primaryMain,
                        size: 24,
                      ),
                ),
                const SizedBox(height: DesignTokens.spaceM),
              ],
              Text(
                title,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isSelected ? AppColors.neutralWhite : null,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: DesignTokens.spaceS),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.neutralWhite.withOpacity(0.8)
                        : AppColors.neutral600,
                  ),
                ),
              ],
            ],
          ),
          if (hasBadge && badgeText != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceS,
                  vertical: DesignTokens.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryMain,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Text(
                  badgeText!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutralWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
