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

    final Color baseColor =
        widget.color ??
        (highContrast ? AppColors.neutralBlack : AppColors.primaryMain);

    final Color gradientStart = highContrast
        ? baseColor
        : baseColor.withOpacity(_isPressed ? 0.85 : 1.0);
    final Color gradientEnd = highContrast
        ? Color.lerp(baseColor, Colors.white, _isPressed ? 0.18 : 0.12)!
        : baseColor.withOpacity(_isPressed ? 0.65 : 0.8);

    final Color borderColor = highContrast
        ? Colors.white.withOpacity(0.24)
        : AppColors.neutralWhite.withOpacity(0.2);

    final Color shadowColor = highContrast
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.2);

    final Duration animationDuration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 150);

    final double blurRadius = highContrast
        ? (_isPressed ? 4 : 8)
        : (_isPressed ? 5 : 10);
    final double yOffset = _isPressed ? 2 : (highContrast ? 3 : 5);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        _handleTap(
          enableHaptics: hapticsEnabled,
          enableSound: soundEffectsEnabled,
        );
      },
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
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: blurRadius,
              offset: Offset(0, yOffset),
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
