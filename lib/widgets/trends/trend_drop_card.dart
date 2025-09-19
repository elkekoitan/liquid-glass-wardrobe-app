import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../design_system/design_tokens.dart';
import '../../features/trend_pulse/domain/trend_pulse_models.dart';
import '../glass_button.dart';
import '../glass_container.dart';

class TrendDropCard extends StatelessWidget {
  const TrendDropCard({
    super.key,
    required this.drop,
    required this.highContrast,
    required this.reducedMotion,
    required this.onCtaTap,
  });

  final TrendDrop drop;
  final bool highContrast;
  final bool reducedMotion;
  final void Function(TrendCallToAction) onCtaTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> gradient = drop.accentColors.isEmpty
        ? [const Color(0xFFF7F7FF), const Color(0xFFB8AFFE)]
        : drop.accentColors;

    final Color titleColor = highContrast
        ? Colors.white
        : Colors.black.withValues(alpha: 0.86);
    final Color bodyColor = highContrast
        ? Colors.white.withValues(alpha: 0.78)
        : Colors.black.withValues(alpha: 0.68);
    final String windowLabel = _buildWindowLabel(drop);

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  drop.heroImageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: DesignTokens.spaceL,
                  right: DesignTokens.spaceL,
                  bottom: DesignTokens.spaceL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drop.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: DesignTokens.spaceS),
                      Text(
                        drop.tagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceL),
        Text(
          'Pinned by ${drop.pinterestCurator}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: bodyColor,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          'Board • ${drop.pinterestBoardId}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: bodyColor.withValues(alpha: highContrast ? 0.72 : 0.6),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceM),
        Text(
          drop.tagline,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        Text(
          windowLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: bodyColor),
        ),
        const SizedBox(height: DesignTokens.spaceM),
        Wrap(
          spacing: DesignTokens.spaceS,
          runSpacing: DesignTokens.spaceS,
          children: drop.badges
              .map(
                (badge) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceM,
                    vertical: DesignTokens.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: highContrast
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.06),
                    border: Border.all(
                      color: highContrast
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                  child: Text(
                    badge,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: highContrast
                          ? Colors.white
                          : Colors.black.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: DesignTokens.spaceL),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: drop.callToActions
              .map(
                (cta) => Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spaceS),
                  child: GlassButton(
                    onPressed: () => onCtaTap(cta),
                    child: Text(
                      cta.label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );

    final Widget card = GlassContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      gradientColors: highContrast ? [Colors.black, Colors.black] : gradient,
      borderColor: highContrast
          ? Colors.white.withValues(alpha: 0.16)
          : Colors.black.withValues(alpha: 0.08),
      showLiquidEffects: !highContrast && !reducedMotion,
      liquidIntensity: 0.7,
      child: content,
    );

    if (reducedMotion) {
      return card;
    }

    return card
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  String _buildWindowLabel(TrendDrop drop) {
    if (!drop.isLive) {
      return 'Replay the drop in your capsule locker';
    }
    final Duration remaining = drop.remainingWindow;
    if (remaining.isNegative) {
      return 'Drop window closed';
    }
    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes.remainder(60);
    if (hours == 0) {
      return 'Live for $minutes minutes';
    }
    if (minutes == 0) {
      return 'Live for $hours hours';
    }
    return 'Live for $hours h $minutes m';
  }
}
