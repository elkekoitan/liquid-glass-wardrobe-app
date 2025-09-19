import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fit_check_provider.dart';
import '../providers/personalization_provider.dart';
import '../services/gemini_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';

/// Canvas Screen - Main try-on viewer with pose controls
class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );

    return Consumer<FitCheckProvider>(
      builder: (context, provider, child) {
        final displayUrl = provider.displayImageUrl;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Stack(
            children: [
              Positioned(
                top: AppSpacing.lg,
                left: AppSpacing.lg,
                child: GlassContainer.light(
                  child: LiquidButton.secondary(
                    text: 'Start Over',
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            provider.startOver();
                            Navigator.maybePop(context);
                          },
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: _CanvasViewport(
                      provider: provider,
                      displayUrl: displayUrl,
                      highContrast: highContrast,
                    ),
                  ),
                ),
              ),
              if (displayUrl != null && !provider.isLoading)
                Positioned(
                  bottom: AppSpacing.xl,
                  left: 0,
                  right: 0,
                  child: _PoseControls(highContrast: highContrast),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CanvasViewport extends StatelessWidget {
  const _CanvasViewport({
    required this.provider,
    required this.displayUrl,
    required this.highContrast,
  });

  final FitCheckProvider provider;
  final String? displayUrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassContainer.light(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: displayUrl != null
                ? _ImageFromDataUrl(url: displayUrl!)
                : const _PlaceholderLoading(message: 'Loading Model...'),
          ),
        ),
        if (provider.isLoading)
          Positioned.fill(
            child: GlassContainer.strong(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const CircularProgressIndicator(),
                  if (provider.loadingMessage.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        provider.loadingMessage,
                        style: AppTypography.bodyMedium.copyWith(
                          color: highContrast
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageFromDataUrl extends StatelessWidget {
  const _ImageFromDataUrl({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    try {
      final data = Uri.parse(url).data;
      if (data == null) return const SizedBox.shrink();
      final bytes = data.contentAsBytes();
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } catch (_) {
      return const Center(child: Text('Unable to render image'));
    }
  }
}

class _PlaceholderLoading extends StatelessWidget {
  const _PlaceholderLoading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant.withValues(alpha: 0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PoseControls extends StatelessWidget {
  const _PoseControls({required this.highContrast});

  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitCheckProvider>();
    final poseList = PoseInstructions.instructions;
    final currentIndex = provider.currentPoseIndex;

    void previous() {
      if (provider.isLoading || provider.availablePoseKeys.length <= 1) return;
      final currentPose = poseList[currentIndex];
      final idxInAvailable = provider.availablePoseKeys.indexOf(currentPose);
      if (idxInAvailable == -1) {
        provider.changePose(
          (currentIndex - 1 + poseList.length) % poseList.length,
        );
        return;
      }
      final prevIdx =
          (idxInAvailable - 1 + provider.availablePoseKeys.length) %
          provider.availablePoseKeys.length;
      final prevPose = provider.availablePoseKeys[prevIdx];
      final newGlobal = poseList.indexOf(prevPose);
      if (newGlobal != -1) provider.changePose(newGlobal);
    }

    void next() {
      if (provider.isLoading) return;
      final currentPose = poseList[currentIndex];
      final idxInAvailable = provider.availablePoseKeys.indexOf(currentPose);
      if (idxInAvailable == -1 || provider.availablePoseKeys.isEmpty) {
        provider.changePose((currentIndex + 1) % poseList.length);
        return;
      }
      final nextIdx = idxInAvailable + 1;
      if (nextIdx < provider.availablePoseKeys.length) {
        final nextPose = provider.availablePoseKeys[nextIdx];
        final newGlobal = poseList.indexOf(nextPose);
        if (newGlobal != -1) provider.changePose(newGlobal);
      } else {
        provider.changePose((currentIndex + 1) % poseList.length);
      }
    }

    final Color textColor = highContrast ? Colors.white : AppColors.textPrimary;

    return GlassContainer.strong(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: provider.isLoading ? null : previous,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 220,
            child: Text(
              poseList[currentIndex],
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: provider.isLoading ? null : next,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
