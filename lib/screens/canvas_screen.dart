import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fit_check_provider.dart';
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceVariant.withOpacity(0.7),
              AppColors.surface,
              AppColors.surfaceVariant.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<FitCheckProvider>(
            builder: (context, provider, child) {
              final displayUrl = provider.displayImageUrl;
              return Stack(
                children: [
                  // Start Over button
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: GlassContainer.light(
                      child: LiquidButton.secondary(
                        text: '↺ Start Over',
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                provider.startOver();
                                Navigator.maybePop(context);
                              },
                      ),
                    ),
                  ),

                  // Center image view
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: Stack(
                            children: [
                              GlassContainer.light(
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: displayUrl != null
                                      ? _ImageFromDataUrl(url: displayUrl)
                                      : _PlaceholderLoading(
                                          message: 'Loading Model...',
                                        ),
                                ),
                              ),

                              // Loading overlay
                              if (provider.isLoading)
                                Positioned.fill(
                                  child: GlassContainer.strong(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: AppSpacing.md),
                                        const CircularProgressIndicator(),
                                        if (provider
                                            .loadingMessage
                                            .isNotEmpty) ...[
                                          const SizedBox(height: AppSpacing.md),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                            ),
                                            child: Text(
                                              provider.loadingMessage,
                                              style: AppTypography.bodyMedium
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
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
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pose controls (bottom center)
                  if (displayUrl != null && !provider.isLoading)
                    Positioned(
                      bottom: AppSpacing.xl,
                      left: 0,
                      right: 0,
                      child: Center(child: _PoseControls()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ImageFromDataUrl extends StatelessWidget {
  final String url;
  const _ImageFromDataUrl({required this.url});

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
  final String message;
  const _PlaceholderLoading({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant.withOpacity(0.4),
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
                color: AppColors.textPrimary,
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
