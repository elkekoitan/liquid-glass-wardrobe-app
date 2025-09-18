import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

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

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
            colors: [
              (widget.color ?? AppColors.primaryMain).withOpacity(
                _isPressed ? 0.8 : 1.0,
              ),
              (widget.color ?? AppColors.primaryMain).withOpacity(
                _isPressed ? 0.6 : 0.8,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neutralWhite.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: _isPressed ? 5 : 10,
              offset: Offset(0, _isPressed ? 2 : 5),
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
                      AppColors.neutralWhite,
                    ),
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}
