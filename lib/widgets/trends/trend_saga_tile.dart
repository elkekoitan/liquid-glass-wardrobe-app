import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../design_system/design_tokens.dart';
import '../../features/trend_pulse/domain/trend_pulse_models.dart';
import '../glass_container.dart';

class TrendSagaTile extends StatelessWidget {
  const TrendSagaTile({
    super.key,
    required this.saga,
    required this.highContrast,
    required this.reducedMotion,
    required this.onFocused,
  });

  final TrendSaga saga;
  final bool highContrast;
  final bool reducedMotion;
  final VoidCallback onFocused;

  @override
  Widget build(BuildContext context) {
    final Widget tile = GestureDetector(
      onTap: onFocused,
      child: GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        gradientColors: highContrast
            ? [Colors.black, Colors.black]
            : [
                saga.accentColor.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.1),
              ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      saga.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black,
                        child: const Icon(Icons.style, color: Colors.white54),
                      ),
                    ),
                    Container(
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
                      left: DesignTokens.spaceM,
                      bottom: DesignTokens.spaceM,
                      right: DesignTokens.spaceM,
                      child: Text(
                        saga.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              saga.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highContrast
                    ? Colors.white
                    : Colors.black.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: saga.beats
                  .map(
                    (beat) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: DesignTokens.spaceS,
                      ),
                      child: _StageBadge(
                        stage: beat.stage,
                        label: beat.label,
                        description: beat.description,
                        highContrast: highContrast,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              'Board • ${saga.pinterestBoardId}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: highContrast
                    ? Colors.white.withValues(alpha: 0.72)
                    : Colors.black.withValues(alpha: 0.54),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );

    if (reducedMotion) {
      return tile;
    }

    return tile
        .animate()
        .fadeIn(duration: 320.ms)
        .move(
          begin: const Offset(0, 12),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
          duration: 280.ms,
        );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.stage,
    required this.label,
    required this.description,
    required this.highContrast,
  });

  final int stage;
  final String label;
  final String description;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final Color pillColor = highContrast
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.05);
    final Color textColor = highContrast
        ? Colors.white
        : Colors.black.withValues(alpha: 0.72);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceS,
            vertical: DesignTokens.spaceXS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            color: pillColor,
            border: Border.all(
              color: highContrast
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            'Stage $stage',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(
                    alpha: highContrast ? 0.76 : 0.64,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
