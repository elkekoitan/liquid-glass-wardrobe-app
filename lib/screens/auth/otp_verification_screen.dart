import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../providers/otp_provider.dart';
import '../../models/capsule_model.dart';
import '../../providers/personalization_provider.dart';
import '../../services/capsule_service.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final personalization = context.watch<PersonalizationProvider>();

    if (!personalization.hasLoaded) {
      return _buildLoadingShell(highContrast: personalization.highContrast);
    }

    return FutureBuilder<CapsuleModel?>(
      future: CapsuleService.instance.loadCapsuleById(
        personalization.defaultCapsule,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShell(highContrast: personalization.highContrast);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorShell(
            message: 'Unable to load capsule data. Please try again.',
            highContrast: personalization.highContrast,
          );
        }

        final capsule = snapshot.data!;
        return ChangeNotifierProvider<OtpProvider>(
          create: (_) => OtpProvider(
            capsuleId: capsule.id,
            capsuleName: capsule.name,
            capsuleMood: capsule.mood,
            heroCopy: capsule.microcopy.prompt,
          ),
          child: const _OtpVerificationView(),
        );
      },
    );
  }

  Widget _buildLoadingShell({required bool highContrast}) {
    return _buildShell(
      highContrast: highContrast,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorShell({
    required String message,
    required bool highContrast,
  }) {
    return _buildShell(
      highContrast: highContrast,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.huge),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildShell({required Widget child, required bool highContrast}) {
    final LinearGradient gradient = highContrast
        ? const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF10151F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF0D1218), Color(0xFF1F2937)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(child: child),
      ),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  const _OtpVerificationView();

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  String _lastSyncedCode = '';
  int _lastCodeLength = 0;
  OtpEntryStatus _lastStatus = OtpEntryStatus.idle;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OtpProvider>();
    final reducedMotion = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.reducedMotion,
    );
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final hapticsEnabled = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.haptics,
    );
    final soundEffectsEnabled = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.soundEffects,
    );

    if (_lastSyncedCode != provider.code) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _lastSyncedCode = provider.code;
        _textController
          ..text = provider.code
          ..selection = TextSelection.collapsed(offset: provider.code.length);
      });
    }

    final codeLength = provider.code.length;
    if (codeLength != _lastCodeLength) {
      if (codeLength > _lastCodeLength) {
        if (hapticsEnabled) {
          HapticFeedback.selectionClick();
        }
        if (soundEffectsEnabled) {
          SystemSound.play(SystemSoundType.click);
        }
      }
      _lastCodeLength = codeLength;
    }

    final status = provider.status;
    if (_lastStatus != status) {
      if (status == OtpEntryStatus.success) {
        if (hapticsEnabled) {
          HapticFeedback.mediumImpact();
        }
        if (soundEffectsEnabled) {
          SystemSound.play(SystemSoundType.click);
        }
      } else if (status == OtpEntryStatus.error) {
        if (hapticsEnabled) {
          HapticFeedback.vibrate();
        }
        if (soundEffectsEnabled) {
          SystemSound.play(SystemSoundType.alert);
        }
      }
      _lastStatus = status;
    }

    final backgroundGradient = highContrast
        ? const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF0D1218), Color(0xFF1F2937)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: _requestFocus,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(gradient: backgroundGradient),
          child: SafeArea(
            child: Stack(
              children: [
                if (!highContrast)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              radius: 0.85,
                              center: const Alignment(-0.6, -0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenMarginHorizontal,
                    vertical: AppSpacing.screenMarginVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CapsuleHero(provider: provider),
                      const SizedBox(height: AppSpacing.xxl),
                      _OtpCard(
                        provider: provider,
                        controller: _textController,
                        focusNode: _focusNode,
                        onInputChanged: provider.handleInput,
                        reducedMotion: reducedMotion,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _ActionBar(
                        provider: provider,
                        onShowMethods: () => _showMethodSheet(context),
                        onResend: provider.resendCode,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const _SupportNote(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMethodSheet(BuildContext context) async {
    final provider = context.read<OtpProvider>();

    final selectedMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      barrierColor: Colors.black.withValues(alpha: 0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.huge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose another way',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...provider.methods.map(
                (method) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.verified_user,
                    color: method.id == provider.activeMethod.id
                        ? AppColors.liquidCyan
                        : Colors.white54,
                  ),
                  title: Text(
                    method.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    method.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  trailing: method.id == provider.activeMethod.id
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(method.id),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedMethod != null) {
      provider.selectMethod(selectedMethod);
      _requestFocus();
    }
  }
}

class _CapsuleHero extends StatelessWidget {
  const _CapsuleHero({required this.provider});

  final OtpProvider provider;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.capsuleMood,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    provider.capsuleName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.liquidCyan, AppColors.liquidViolet],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            provider.heroCopy,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.provider,
    required this.controller,
    required this.focusNode,
    required this.onInputChanged,
    required this.reducedMotion,
  });

  final OtpProvider provider;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onInputChanged;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final isWarning = provider.secondsRemaining <= 10 && !provider.isSuccess;
    final isExpired = provider.isTimerExpired && !provider.isSuccess;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.cardPadding * 1.2,
      ),
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: reducedMotion ? 0 : 300),
            switchInCurve: reducedMotion ? Curves.linear : Curves.easeInOut,
            switchOutCurve: reducedMotion ? Curves.linear : Curves.easeInOut,
            child: provider.isSuccess
                ? _SuccessState(provider: provider)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimerChip(
                        label: isExpired
                            ? 'Code expired'
                            : '${provider.formattedTimer} left',
                        status: isExpired
                            ? _TimerChipStatus.expired
                            : isWarning
                            ? _TimerChipStatus.warning
                            : _TimerChipStatus.normal,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Enter the 6-digit code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        provider.activeMethod.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            FocusScope.of(context).requestFocus(focusNode),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(OtpProvider.codeLength, (
                            index,
                          ) {
                            final digit = provider.digits[index];
                            final isActive =
                                !provider.isSuccess &&
                                !provider.hasError &&
                                provider.code.length == index;
                            return _OtpDigitCell(
                              digit: digit,
                              isActive: isActive,
                              hasError: provider.hasError,
                              reducedMotion: reducedMotion,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (provider.hasError && provider.errorMessage != null)
                        Text(
                          provider.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Demo tip: use 123456 to experience the full success flow.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
          ),
          Offstage(
            offstage: provider.isSuccess,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: OtpProvider.codeLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: Colors.transparent,
              style: const TextStyle(color: Colors.transparent),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: onInputChanged,
            ),
          ),
          if (provider.isVerifying)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.provider});

  final OtpProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.successGlass.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Verified',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Access granted. Let the look unfold.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Monday Reset is live across your vault. Explore the glow while it lasts.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GlassButton(
          width: double.infinity,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpDigitCell extends StatelessWidget {
  const _OtpDigitCell({
    required this.digit,
    required this.isActive,
    required this.hasError,
    required this.reducedMotion,
  });

  final String digit;
  final bool isActive;
  final bool hasError;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final displayDigit = digit.isEmpty ? '' : digit;

    return AnimatedContainer(
      duration: Duration(milliseconds: reducedMotion ? 0 : 200),
      width: 60,
      height: 72,
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.errorGlass.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasError
              ? Colors.redAccent.withValues(alpha: 0.8)
              : isActive
              ? AppColors.liquidCyan
              : Colors.white24,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.liquidCyan.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Center(
        child: Text(
          displayDigit,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.provider,
    required this.onShowMethods,
    required this.onResend,
  });

  final OtpProvider provider;
  final VoidCallback onShowMethods;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onShowMethods,
          child: Row(
            children: const [
              Icon(Icons.sync_alt, color: Colors.white70, size: 18),
              SizedBox(width: AppSpacing.xs),
              Text('Switch method', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        TextButton(
          onPressed: provider.canResend ? () => onResend() : null,
          child: provider.isResendInFlight
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  provider.canResend
                      ? 'Resend code'
                      : 'Resend in ${provider.formattedTimer}',
                  style: TextStyle(
                    color: provider.canResend ? Colors.white : Colors.white30,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SupportNote extends StatelessWidget {
  const _SupportNote();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need a calmer flow?',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Adjust reduced motion or high contrast in Personalization ? Comfort settings. Your preferences sync across devices.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white38, height: 1.5),
        ),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.label, required this.status});

  final String label;
  final _TimerChipStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case _TimerChipStatus.warning:
        background = Colors.orange.withValues(alpha: 0.25);
        foreground = Colors.orangeAccent;
        break;
      case _TimerChipStatus.expired:
        background = Colors.redAccent.withValues(alpha: 0.2);
        foreground = Colors.redAccent;
        break;
      case _TimerChipStatus.normal:
        background = Colors.white.withValues(alpha: 0.12);
        foreground = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.av_timer, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _TimerChipStatus { normal, warning, expired }
