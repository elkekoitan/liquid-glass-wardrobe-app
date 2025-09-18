import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget that applies liquid glass shader effect
class LiquidGlassWidget extends StatefulWidget {
  final Widget? child;
  final double intensity;
  final double distortion;
  final Size? size;
  final Duration? animationDuration;

  const LiquidGlassWidget({
    super.key,
    this.child,
    this.intensity = 1.0,
    this.distortion = 0.1,
    this.size,
    this.animationDuration,
  });

  @override
  State<LiquidGlassWidget> createState() => _LiquidGlassWidgetState();
}

class _LiquidGlassWidgetState extends State<LiquidGlassWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  ui.FragmentShader? _shader;
  bool _shaderLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shader?.dispose();
    super.dispose();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/liquid_glass.frag',
      );
      _shader = program.fragmentShader();
      if (mounted) {
        setState(() {
          _shaderLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading liquid glass shader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shaderLoaded || _shader == null) {
      return widget.child ?? const SizedBox();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size ?? Size.infinite,
          painter: LiquidGlassPainter(
            shader: _shader!,
            time: _animationController.value * 10.0, // Scale time for animation
            intensity: widget.intensity,
            distortion: widget.distortion,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Custom painter for liquid glass effect
class LiquidGlassPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double intensity;
  final double distortion;

  LiquidGlassPainter({
    required this.shader,
    required this.time,
    required this.intensity,
    required this.distortion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms
    shader.setFloat(0, time); // u_time
    shader.setFloat(1, size.width); // u_resolution.x
    shader.setFloat(2, size.height); // u_resolution.y
    shader.setFloat(3, 0.5 * size.width); // u_mouse.x (center)
    shader.setFloat(4, 0.5 * size.height); // u_mouse.y (center)
    shader.setFloat(5, intensity); // u_intensity
    shader.setFloat(6, distortion); // u_distortion

    // Create paint with shader
    final paint = Paint()..shader = shader;

    // Draw the effect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant LiquidGlassPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.intensity != intensity ||
        oldDelegate.distortion != distortion;
  }
}
