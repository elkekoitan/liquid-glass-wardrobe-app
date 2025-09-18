import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/fit_check_provider.dart';
import '../models/models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';

/// Outfit Stack - Shows outfit layers with history management
class OutfitStack extends StatelessWidget {
  final Function(int layerIndex)? onInitiateColorChange;

  const OutfitStack({super.key, this.onInitiateColorChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitCheckProvider>(
      builder: (context, provider, child) {
        final currentIndex = provider.currentOutfitIndex;
        final activeHistory = provider.activeOutfitLayers;

        return GlassContainer.light(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with history controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outfit Stack',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Undo button
                      IconButton(
                        onPressed: provider.canUndo
                            ? provider.undoLastGarment
                            : null,
                        icon: Icon(
                          Icons.undo,
                          color: provider.canUndo
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        tooltip: 'Undo last garment',
                      ),
                      // Redo button
                      IconButton(
                        onPressed: provider.canRedo
                            ? provider.redoLastGarment
                            : null,
                        icon: Icon(
                          Icons.redo,
                          color: provider.canRedo
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        tooltip: 'Redo garment',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Outfit layers list
              if (activeHistory.isEmpty) ...[
                // Empty state
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 32,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No outfit layers yet',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Outfit layers
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeHistory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final layer = activeHistory[index];
                    final isTopLayer =
                        index > 0 && index == activeHistory.length - 1;
                    final isCurrentLayer = index == currentIndex;

                    return _OutfitLayerTile(
                          layer: layer,
                          layerNumber: index + 1,
                          isTopLayer: isTopLayer,
                          isCurrentLayer: isCurrentLayer,
                          onRemove: isTopLayer
                              ? provider.undoLastGarment
                              : null,
                          onColorChange:
                              (isTopLayer && onInitiateColorChange != null)
                              ? () => onInitiateColorChange!(index)
                              : null,
                          onTap: () => provider.jumpToLayer(index),
                        )
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .slideX(
                          begin: -0.2,
                          delay: (index * 100).ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
              ],

              // Help text for empty state
              if (activeHistory.length <= 1) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Select garments from your wardrobe to build your outfit stack!',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],

              // Stats
              if (activeHistory.length > 1) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${activeHistory.length - 1} garment${activeHistory.length > 2 ? 's' : ''} applied',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(delay: 300.ms, curve: Curves.elasticOut),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OutfitLayerTile extends StatelessWidget {
  final OutfitLayer layer;
  final int layerNumber;
  final bool isTopLayer;
  final bool isCurrentLayer;
  final VoidCallback? onRemove;
  final VoidCallback? onColorChange;
  final VoidCallback? onTap;

  const _OutfitLayerTile({
    required this.layer,
    required this.layerNumber,
    required this.isTopLayer,
    required this.isCurrentLayer,
    this.onRemove,
    this.onColorChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentLayer
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
          border: Border.all(
            color: isCurrentLayer
                ? AppColors.primary
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: isCurrentLayer ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Layer number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentLayer
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$layerNumber',
                  style: AppTypography.bodySmall.copyWith(
                    color: isCurrentLayer
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Garment thumbnail (if available)
            if (layer.garment != null && layer.garment!.url.isNotEmpty) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: layer.garment!.url.startsWith('data:')
                      ? Image.memory(
                          Uri.parse(layer.garment!.url).data!.contentAsBytes(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: AppColors.textTertiary,
                              size: 24,
                            );
                          },
                        )
                      : Image.network(
                          layer.garment!.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: AppColors.textTertiary,
                              size: 24,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],

            // Layer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    layer.garment?.name ?? 'Base Model',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (layer.garment != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${layer.availablePoses.length} pose${layer.availablePoses.length > 1 ? 's' : ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons (only for top layer)
            if (isTopLayer) ...[
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color change button
                  if (onColorChange != null)
                    IconButton(
                      onPressed: onColorChange,
                      icon: Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      tooltip: 'Change color',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),

                  // Remove button
                  if (onRemove != null)
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      tooltip: 'Remove layer',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],

            // Current layer indicator
            if (isCurrentLayer && !isTopLayer) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.visibility, color: AppColors.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Outfit History Controls Widget
class OutfitHistoryControls extends StatelessWidget {
  const OutfitHistoryControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitCheckProvider>(
      builder: (context, provider, child) {
        final outfitHistory = provider.outfitHistory;
        return GlassContainer.strong(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Undo button
              Expanded(
                child: LiquidButton.secondary(
                  text: '↶ Undo',
                  onPressed: provider.canUndo ? provider.undoLastGarment : null,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Layer info
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Layer ${provider.currentOutfitIndex + 1} of ${outfitHistory.length}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (outfitHistory.length > 1)
                        Text(
                          '${outfitHistory.length - 1} garment${outfitHistory.length > 2 ? 's' : ''} applied',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Redo button
              Expanded(
                child: LiquidButton.secondary(
                  text: 'Redo ↷',
                  onPressed: provider.canRedo ? provider.redoLastGarment : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
