import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/design_tokens.dart' as ds;
import '../../providers/personalization_provider.dart';
import '../glass_container.dart';

/// Common header used across entry points to keep branding consistent.
class MainSectionHeader extends StatelessWidget {
  const MainSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final bool highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );

    final Color titleColor = highContrast
        ? ds.AppColors.neutral100
        : ds.AppColors.neutral900;
    final Color subtitleColor = highContrast
        ? ds.AppColors.neutral200
        : ds.AppColors.neutral600;

    return GlassContainer.light(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceL,
        vertical: DesignTokens.spaceM,
      ),
      borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ??
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color: highContrast
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
                child: Icon(
                  Icons.blur_on,
                  size: 20,
                  color: highContrast
                      ? ds.AppColors.neutralWhite
                      : ds.AppColors.neutral700,
                ),
              ),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DesignTokens.spaceXS),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
