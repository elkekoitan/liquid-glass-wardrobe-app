import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../design_system/design_tokens.dart';
import '../providers/personalization_provider.dart';

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  void _handleTap({required bool enableHaptics, required bool enableSound}) {
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }
    if (enableSound) {
      SystemSound.play(SystemSoundType.click);
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final personalization = context.watch<PersonalizationProvider>();
    final bool highContrast = personalization.highContrast;
    final bool reducedMotion = personalization.reducedMotion;
    final bool soundEffectsEnabled = personalization.soundEffects;
    final bool hapticsEnabled = personalization.haptics;
    final bool isEnabled = widget.onPressed != null;

    if (!isEnabled && _isPressed) {
      _isPressed = false;
    }

    final Color baseColor =
        widget.color ??
        (highContrast ? AppColors.neutralBlack : AppColors.primaryMain);

    final Color gradientStart = highContrast
        ? baseColor
        : baseColor.withValues(alpha: _isPressed ? 0.85 : 1.0);
    final Color gradientEnd = highContrast
        ? Color.lerp(baseColor, Colors.white, _isPressed ? 0.18 : 0.12)!
        : baseColor.withValues(alpha: _isPressed ? 0.65 : 0.8);

    final Color borderColor = highContrast
        ? Colors.white.withValues(alpha: 0.24)
        : AppColors.neutralWhite.withValues(alpha: 0.2);

    final Color shadowColor = highContrast
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.2);

    final Duration animationDuration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 150);

    final double blurRadius = highContrast
        ? (_isPressed ? 4 : 8)
        : (_isPressed ? 5 : 10);
    final double yOffset = _isPressed ? 2 : (highContrast ? 3 : 5);

    final Color disabledGradientStart = gradientStart.withValues(
      alpha: highContrast ? 0.45 : 0.5,
    );
    final Color disabledGradientEnd = gradientEnd.withValues(
      alpha: highContrast ? 0.35 : 0.4,
    );
    final List<Color> gradientColors = isEnabled
        ? [gradientStart, gradientEnd]
        : [disabledGradientStart, disabledGradientEnd];
    final Color effectiveBorderColor = isEnabled
        ? borderColor
        : borderColor.withValues(alpha: 0.35);
    final Color effectiveShadowColor = isEnabled
        ? shadowColor
        : shadowColor.withValues(alpha: 0.12);
    final double effectiveBlurRadius = isEnabled ? blurRadius : blurRadius / 2;
    final double effectiveYOffset = isEnabled ? yOffset : yOffset / 2;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled
          ? () {
              _handleTap(
                enableHaptics: hapticsEnabled,
                enableSound: soundEffectsEnabled,
              );
            }
          : null,
      child: AnimatedContainer(
        duration: animationDuration,
        width: widget.width,
        height: widget.height ?? 56,
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceL,
              vertical: DesignTokens.spaceM,
            ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: effectiveBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: effectiveShadowColor,
              blurRadius: effectiveBlurRadius,
              offset: Offset(0, effectiveYOffset),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      highContrast ? Colors.white : AppColors.neutralWhite,
                    ),
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}
