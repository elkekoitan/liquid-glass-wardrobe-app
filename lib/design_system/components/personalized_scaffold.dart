import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/personalization_provider.dart';
import '../design_tokens.dart' as ds;

/// Shared scaffold with liquid-glass background that adapts to personalization.
class PersonalizedScaffold extends StatelessWidget {
  const PersonalizedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.padding,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
    this.enableGlassHalo = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;
  final bool enableGlassHalo;

  static const _containerKey = ValueKey('personalized-surface');

  @override
  Widget build(BuildContext context) {
    return Selector<PersonalizationProvider, _SurfacePreferences>(
      selector: (_, prefs) => _SurfacePreferences(
        reducedMotion: prefs.reducedMotion,
        highContrast: prefs.highContrast,
      ),
      builder: (context, prefs, _) {
        final gradient = prefs.highContrast
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ds.AppColors.neutral900, ds.AppColors.neutral800],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF101828), Color(0xFF0B1220)],
              );

        final duration = prefs.reducedMotion
            ? Duration.zero
            : ds.DesignTokens.durationSlow;
        final curve = prefs.reducedMotion
            ? Curves.linear
            : ds.DesignTokens.curveSmooth;

        Widget content = body;

        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        if (useSafeArea) {
          content = SafeArea(child: content);
        }

        return AnimatedContainer(
          key: _containerKey,
          duration: duration,
          curve: curve,
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (enableGlassHalo) const _GlassHalo(),
              Scaffold(
                backgroundColor: Colors.transparent,
                extendBody: true,
                extendBodyBehindAppBar: extendBodyBehindAppBar,
                appBar: appBar,
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                bottomNavigationBar: bottomNavigationBar,
                body: content,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassHalo extends StatelessWidget {
  const _GlassHalo();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.only(
            top: ds.DesignTokens.spaceXXXL,
            right: ds.DesignTokens.spaceXXXL,
          ),
          width: 260,
          height: 260,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x33FFFFFF),
                Color(0x11000000),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurfacePreferences {
  const _SurfacePreferences({
    required this.reducedMotion,
    required this.highContrast,
  });

  final bool reducedMotion;
  final bool highContrast;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _SurfacePreferences &&
        other.reducedMotion == reducedMotion &&
        other.highContrast == highContrast;
  }

  @override
  int get hashCode => Object.hash(reducedMotion, highContrast);
}
