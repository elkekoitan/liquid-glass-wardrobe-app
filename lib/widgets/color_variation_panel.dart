import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/fit_check_provider.dart';
import '../providers/try_on_session_provider.dart';
import '../services/gemini_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';

/// Color Variation Panel - Shows color options and allows custom color input
class ColorVariationPanel extends StatefulWidget {
  final int layerIndex;
  final String garmentName;
  final VoidCallback? onClose;

  const ColorVariationPanel({
    super.key,
    required this.layerIndex,
    required this.garmentName,
    this.onClose,
  });

  @override
  State<ColorVariationPanel> createState() => _ColorVariationPanelState();
}

class _ColorVariationPanelState extends State<ColorVariationPanel> {
  final TextEditingController _customColorController = TextEditingController();
  String? _selectedPresetColor;
  bool _isApplyingColor = false;

  // Predefined color options
  static const List<ColorOption> _colorOptions = [
    ColorOption('Red', '🔴', 'bright red'),
    ColorOption('Blue', '🔵', 'bright blue'),
    ColorOption('Green', '🟢', 'bright green'),
    ColorOption('Yellow', '🟡', 'bright yellow'),
    ColorOption('Purple', '🟣', 'bright purple'),
    ColorOption('Orange', '🟠', 'bright orange'),
    ColorOption('Pink', '🩷', 'bright pink'),
    ColorOption('Brown', '🤎', 'brown'),
    ColorOption('Black', '⚫', 'black'),
    ColorOption('White', '⚪', 'white'),
    ColorOption('Gray', '🩶', 'gray'),
    ColorOption('Navy', '🔷', 'navy blue'),
  ];

  @override
  void dispose() {
    _customColorController.dispose();
    super.dispose();
  }

  Future<void> _applyColor(String colorPrompt) async {
    if (_isApplyingColor) return;

    setState(() {
      _isApplyingColor = true;
    });

    try {
      final session = context.read<TryOnSessionProvider>();
      final success = await session.requestColorChange(
        widget.layerIndex,
        colorPrompt,
      );

      if (success && session.errorSurface == null) {
        widget.onClose?.call();
      }
    } catch (_) {
      // Session provider surfaces the error; UI reacts via Consumer.
    } finally {
      setState(() {
        _isApplyingColor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TryOnSessionProvider>();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer.strong(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Color',
                          style: AppTypography.headingMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.garmentName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isApplyingColor ? null : widget.onClose,
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Loading indicator
              if (_isApplyingColor) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          session.statusLabel,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Error display
              if (session.errorSurface != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          session.errorSurface!.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Preset color options
              if (!_isApplyingColor) ...[
                Text(
                  'Choose a color:',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Color grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final colorOption = _colorOptions[index];
                    final isSelected =
                        _selectedPresetColor == colorOption.prompt;

                    return _ColorOptionTile(
                          colorOption: colorOption,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedPresetColor = colorOption.prompt;
                              _customColorController.clear();
                            });
                          },
                        )
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .scale(
                          delay: (index * 50).ms,
                          curve: Curves.elasticOut,
                        );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Custom color input
                Text(
                  'Or describe a custom color:',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                TextField(
                  controller: _customColorController,
                  onChanged: (value) {
                    if (value.isNotEmpty && _selectedPresetColor != null) {
                      setState(() {
                        _selectedPresetColor = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g., "bright neon green", "dark burgundy"',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: LiquidButton.secondary(
                        text: 'Cancel',
                        onPressed: widget.onClose,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      flex: 2,
                      child: LiquidButton.primary(
                        text: 'Apply Color',
                        onPressed:
                            (_selectedPresetColor != null ||
                                _customColorController.text.trim().isNotEmpty)
                            ? () {
                                final colorPrompt =
                                    _selectedPresetColor ??
                                    _customColorController.text.trim();
                                _applyColor(colorPrompt);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorOptionTile extends StatelessWidget {
  final ColorOption colorOption;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOptionTile({
    required this.colorOption,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: isSelected ? 3 : 1,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(colorOption.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              colorOption.name,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ColorOption {
  final String name;
  final String emoji;
  final String prompt;

  const ColorOption(this.name, this.emoji, this.prompt);
}

/// Pose Selection Panel - Shows available poses for selection
class PoseSelectionPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const PoseSelectionPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FitCheckProvider, TryOnSessionProvider>(
      builder: (context, provider, session, child) {
        final poseInstructions = PoseInstructions.instructions;
        final currentPoseIndex = provider.currentPoseIndex;
        final availablePoses = provider.availablePoseKeys;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer.strong(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Pose',
                        style: AppTypography.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Choose a different pose for your model:',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Pose options
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: poseInstructions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final pose = poseInstructions[index];
                        final isCurrentPose = index == currentPoseIndex;
                        final isAvailable = availablePoses.contains(pose);
                        final isLoading = session.isBusy;

                        return _PoseOptionTile(
                              pose: pose,
                              poseNumber: index + 1,
                              isCurrentPose: isCurrentPose,
                              isAvailable: isAvailable,
                              isLoading: isLoading,
                              onTap: (isLoading || isCurrentPose)
                                  ? null
                                  : () {
                                      session.requestPoseChange(index).then((success) {
                                        if (success && session.errorSurface == null) {
                                          onClose?.call();
                                        }
                                      });
                                    },
                            )
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .slideX(
                              begin: -0.3,
                              delay: (index * 100).ms,
                              curve: Curves.easeOut,
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PoseOptionTile extends StatelessWidget {
  final String pose;
  final int poseNumber;
  final bool isCurrentPose;
  final bool isAvailable;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PoseOptionTile({
    required this.pose,
    required this.poseNumber,
    required this.isCurrentPose,
    required this.isAvailable,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentPose
              ? AppColors.primary.withValues(alpha: 0.2)
              : isAvailable
              ? AppColors.success.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          border: Border.all(
            color: isCurrentPose
                ? AppColors.primary
                : isAvailable
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: isCurrentPose ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Pose number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentPose
                    ? AppColors.primary
                    : isAvailable
                    ? AppColors.success
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$poseNumber',
                  style: AppTypography.bodySmall.copyWith(
                    color: (isCurrentPose || isAvailable)
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Pose description
            Expanded(
              child: Text(
                pose,
                style: AppTypography.bodyMedium.copyWith(
                  color: isCurrentPose
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: isCurrentPose
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),

            // Status indicators
            if (isCurrentPose) ...[
              Icon(Icons.visibility, color: AppColors.primary, size: 20),
            ] else if (isAvailable) ...[
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 20,
              ),
            ] else if (onTap != null) ...[
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
