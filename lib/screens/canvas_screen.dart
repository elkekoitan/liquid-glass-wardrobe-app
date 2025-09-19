import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fit_check_provider.dart';
import '../providers/personalization_provider.dart';
import '../providers/try_on_session_provider.dart';
import '../models/models.dart';
import '../services/gemini_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';
import '../providers/navigation_provider.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );

    return Consumer2<FitCheckProvider, TryOnSessionProvider>(
      builder: (context, provider, session, child) {
        final displayUrl = provider.displayImageUrl;
        final isBusy = session.isBusy;
        final hasError = session.hasError;
        final statusLabel = session.statusLabel;
        final progress = session.progress;
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
                    onPressed: isBusy
                        ? null
                        : () {
                            session.resetSession();
                            context.read<NavigationProvider>().maybePop();
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
                      session: session,
                      displayUrl: displayUrl,
                      highContrast: highContrast,
                      statusLabel: statusLabel,
                      progress: progress,
                      showBusyOverlay: isBusy && !hasError,
                      errorSurface: session.errorSurface,
                    ),
                  ),
                ),
              ),
              if (displayUrl != null && !isBusy)
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
    required this.session,
    required this.displayUrl,
    required this.highContrast,
    required this.statusLabel,
    required this.progress,
    required this.showBusyOverlay,
    required this.errorSurface,
  });

  final FitCheckProvider provider;
  final TryOnSessionProvider session;
  final String? displayUrl;
  final bool highContrast;
  final String statusLabel;
  final double progress;
  final bool showBusyOverlay;
  final GeminiErrorSurface? errorSurface;

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
        if (showBusyOverlay || errorSurface != null)
          Positioned.fill(
            child: GlassContainer.strong(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorSurface != null) ...[
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: highContrast ? Colors.white : AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        errorSurface!.title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: highContrast
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        errorSurface!.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: highContrast
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LiquidButton.primary(
                      text: errorSurface!.actionLabel,
                      onPressed: () {
                        session.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LiquidButton.secondary(
                      text: 'Start Over',
                      onPressed: () {
                        session.resetSession();
                      },
                    ),
                  ] else ...[
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: progress > 0 && progress < 1
                          ? CircularProgressIndicator(value: progress)
                          : const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        statusLabel,
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
    final session = context.watch<TryOnSessionProvider>();
    final poseList = PoseInstructions.instructions;
    final currentIndex = provider.currentPoseIndex;

    Future<void> previous() async {
      if (session.isBusy ||
          session.hasError ||
          provider.availablePoseKeys.length <= 1) {
        return;
      }
      final currentPose = poseList[currentIndex];
      final idxInAvailable = provider.availablePoseKeys.indexOf(currentPose);
      if (idxInAvailable == -1) {
        await session.requestPoseChange(
          (currentIndex - 1 + poseList.length) % poseList.length,
        );
        return;
      }
      final prevIdx =
          (idxInAvailable - 1 + provider.availablePoseKeys.length) %
          provider.availablePoseKeys.length;
      final prevPose = provider.availablePoseKeys[prevIdx];
      final newGlobal = poseList.indexOf(prevPose);
      if (newGlobal != -1) {
        await session.requestPoseChange(newGlobal);
      }
    }

    Future<void> next() async {
      if (session.isBusy || session.hasError) {
        return;
      }
      final currentPose = poseList[currentIndex];
      final idxInAvailable = provider.availablePoseKeys.indexOf(currentPose);
      if (idxInAvailable == -1 || provider.availablePoseKeys.isEmpty) {
        await session.requestPoseChange((currentIndex + 1) % poseList.length);
        return;
      }
      final nextIdx = idxInAvailable + 1;
      if (nextIdx < provider.availablePoseKeys.length) {
        final nextPose = provider.availablePoseKeys[nextIdx];
        final newGlobal = poseList.indexOf(nextPose);
        if (newGlobal != -1) {
          await session.requestPoseChange(newGlobal);
        }
      } else {
        await session.requestPoseChange((currentIndex + 1) % poseList.length);
      }
    }

    final Color textColor = highContrast ? Colors.white : AppColors.textPrimary;

    return GlassContainer.strong(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: (session.isBusy || session.hasError)
                ? null
                : () => previous(),
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
            onPressed: (session.isBusy || session.hasError)
                ? null
                : () => next(),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
