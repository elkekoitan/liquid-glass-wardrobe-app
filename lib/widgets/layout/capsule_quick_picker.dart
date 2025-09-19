import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/capsule_model.dart';

/// Horizontally scrolling capsule picker that reacts to personalization.
class CapsuleQuickPicker extends StatelessWidget {
  const CapsuleQuickPicker({
    super.key,
    required this.capsules,
    required this.selectedId,
    required this.defaultId,
    required this.onSelect,
    this.reducedMotion = false,
    this.highContrast = false,
  });

  final List<CapsuleModel> capsules;
  final String selectedId;
  final String defaultId;
  final void Function(String id) onSelect;
  final bool reducedMotion;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final Color activeBorderColor = Colors.white;
    final Color defaultBorderColor = highContrast
        ? Colors.cyanAccent
        : Colors.pinkAccent;
    final Color inactiveBorderColor = highContrast
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.white24;
    final List<Color> tileGradient = highContrast
        ? [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.08),
          ]
        : [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.02),
          ];
    final Color titleColor = Colors.white;
    final Color subtitleColor = highContrast
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.white60;
    final Color defaultBadgeBackground = defaultBorderColor;
    final Color defaultBadgeTextColor = highContrast
        ? Colors.black
        : Colors.white;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: capsules.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          final capsule = capsules[index];
          final bool isActive = capsule.id == selectedId;
          final bool isDefault = capsule.id == defaultId;

          return GestureDetector(
            onTap: () => onSelect(capsule.id),
            child: AnimatedContainer(
              duration: Duration(milliseconds: reducedMotion ? 0 : 220),
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDefault
                      ? defaultBorderColor
                      : (isActive ? activeBorderColor : inactiveBorderColor),
                  width: isDefault || isActive ? 2.0 : 1.0,
                ),
                gradient: LinearGradient(
                  colors: tileGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  if (isActive || isDefault)
                    BoxShadow(
                      color:
                          (isDefault ? defaultBorderColor : activeBorderColor)
                              .withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 1.5,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              capsule.heroImage,
                              fit: BoxFit.cover,
                              color: Colors.black.withValues(alpha: 0.25),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          capsule.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          capsule.mood,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  if (isDefault)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: defaultBadgeBackground.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: defaultBadgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
