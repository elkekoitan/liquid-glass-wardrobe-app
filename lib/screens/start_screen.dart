import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fit_check_provider.dart';
import '../utils/image_utils.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../design_system/design_tokens.dart';
import '../design_system/components/modern_button.dart';
import '../widgets/layout/main_section_header.dart';
import '../providers/personalization_provider.dart';
import '../design_system/components/personalized_scaffold.dart';

/// Start Screen - First screen for uploading model photo
/// Features liquid glass UI with AI-powered model generation
/// Converted from React StartScreen component

class StartScreen extends StatefulWidget {
  final VoidCallback? onModelFinalized;

  const StartScreen({super.key, this.onModelFinalized});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? _userImageUrl;
  bool _showComparison = false;

  Future<void> _pickImage(picker.ImageSource source) async {
    try {
      final File? pickedFile = await ImageUtils.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Validate image file
      if (!ImageUtils.isValidImageFile(pickedFile)) {
        _showErrorDialog('Please select a valid image file (JPG, PNG, WebP).');
        return;
      }

      // Crop image
      final File? croppedFile = await ImageUtils.cropImage(
        imageFile: pickedFile,
      );

      if (croppedFile == null) return;

      // Convert to data URL for display
      final dataUrl = await ImageUtils.fileToDataUrl(croppedFile);

      if (!mounted) return;

      setState(() {
        _userImageUrl = dataUrl;
        _showComparison = true;
      });

      // Process with AI
      final provider = context.read<FitCheckProvider>();
      await provider.processModelImage(croppedFile);

      if (!mounted) return;

      // Show success and proceed button after processing
      if (provider.error == null) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.neutralWhite,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceXL),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            boxShadow: AppShadows.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 48,
                color: AppColors.primaryMain,
              ),
              const SizedBox(height: DesignTokens.spaceL),
              Text(
                'Choose Photo Source',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Text(
                'Select how you\'d like to add your photo',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceXL),

              ModernButton(
                text: 'Camera',
                leadingIcon: Icons.camera_alt,
                variant: ModernButtonVariant.primary,
                size: ModernButtonSize.large,
                isExpanded: true,
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(picker.ImageSource.camera);
                },
              ),

              const SizedBox(height: DesignTokens.spaceM),

              ModernButton(
                text: 'Gallery',
                leadingIcon: Icons.photo_library,
                variant: ModernButtonVariant.secondary,
                size: ModernButtonSize.large,
                isExpanded: true,
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(picker.ImageSource.gallery);
                },
              ),

              const SizedBox(height: DesignTokens.spaceL),

              ModernButton(
                text: 'Cancel',
                variant: ModernButtonVariant.ghost,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.neutralWhite,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceXL),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            boxShadow: AppShadows.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceL),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutral700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceXL),
              ModernButton(
                text: 'Got it',
                variant: ModernButtonVariant.primary,
                size: ModernButtonSize.medium,
                isExpanded: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.neutralWhite,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceXXL),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            boxShadow: AppShadows.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.neutralWhite,
                  size: 40,
                ),
              ),

              const SizedBox(height: DesignTokens.spaceXL),

              Text(
                'Model Ready!',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: DesignTokens.spaceM),

              Text(
                'Your personal AI model has been created successfully. Ready to try on some amazing outfits?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.neutral700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: DesignTokens.spaceXXL),

              ModernButton(
                text: 'Start Styling',
                trailingIcon: Icons.arrow_forward,
                variant: ModernButtonVariant.success,
                size: ModernButtonSize.large,
                isExpanded: true,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onModelFinalized?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetImage() {
    setState(() {
      _userImageUrl = null;
      _showComparison = false;
    });

    final provider = context.read<FitCheckProvider>();
    provider.startOver();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.reducedMotion,
    );
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );

    final switchDuration = reducedMotion
        ? Duration.zero
        : DesignTokens.durationSlow;
    final animationCurve = reducedMotion
        ? Curves.linear
        : DesignTokens.curveSmooth;

    return PersonalizedScaffold(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      body: Consumer<FitCheckProvider>(
        builder: (context, provider, child) {
          return AnimatedSwitcher(
            duration: switchDuration,
            transitionBuilder: reducedMotion
                ? (child, animation) => child
                : (child, animation) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.3, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: animationCurve,
                            ),
                          ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
            child: _showComparison
                ? _buildComparisonView(provider, highContrast)
                : _buildWelcomeView(highContrast),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeView(bool highContrast) {
    final Color heroSurface = highContrast
        ? AppColors.neutral900
        : AppColors.neutral100;
    final TextStyle heroDescriptionStyle = AppTextStyles.bodyLarge.copyWith(
      color: highContrast ? AppColors.neutral200 : AppColors.neutral700,
      height: 1.6,
    );
    final Color uploadSurface = highContrast
        ? AppColors.neutral900.withValues(alpha: 0.9)
        : AppColors.neutralWhite;
    final Color infoBackground = highContrast
        ? AppColors.primaryMain.withValues(alpha: 0.12)
        : AppColors.infoSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MainSectionHeader(
          title: 'Create Your Model',
          subtitle: 'Upload a clear photo to unlock the AI try-on',
          leading: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceS),
            decoration: BoxDecoration(
              color: highContrast
                  ? AppColors.primaryMain.withValues(alpha: 0.2)
                  : AppColors.primaryMain.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.neutralWhite,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceXL),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceXXL),
                    decoration: BoxDecoration(
                      color: heroSurface,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spaceL),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMain,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 48,
                            color: AppColors.neutralWhite,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXL),
                        Text(
                          'AI Virtual Try-On',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: highContrast
                                ? AppColors.neutral100
                                : AppColors.neutral900,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.spaceM),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spaceM,
                            vertical: DesignTokens.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMain,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusXXL,
                            ),
                          ),
                          child: Text(
                            'See Yourself in Any Outfit',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.neutralWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXL),
                        Text(
                          'Upload your photo and let our advanced AI create your personal virtual model. Try on clothes, experiment with styles, and see how you look before you buy.',
                          style: heroDescriptionStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXXL),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Fast',
                          subtitle: 'Results in seconds',
                          icon: Icons.flash_on,
                          iconColor: AppColors.warning,
                          highContrast: highContrast,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceM),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Accurate',
                          subtitle: 'AI-powered precision',
                          icon: Icons.gps_fixed,
                          iconColor: AppColors.success,
                          highContrast: highContrast,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceM),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Private',
                          subtitle: 'Your photos stay secure',
                          icon: Icons.security,
                          iconColor: AppColors.primaryMain,
                          highContrast: highContrast,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXXL),
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceXL),
                    decoration: BoxDecoration(
                      color: uploadSurface,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        ModernButton(
                          text: 'Upload Your Photo',
                          onPressed: _showImageSourceDialog,
                          variant: ModernButtonVariant.primary,
                          size: ModernButtonSize.large,
                          leadingIcon: Icons.camera_alt,
                          isExpanded: true,
                        ),
                        const SizedBox(height: DesignTokens.spaceL),
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spaceM),
                          decoration: BoxDecoration(
                            color: infoBackground,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusM,
                            ),
                            border: Border.all(
                              color: highContrast
                                  ? AppColors.primaryMain.withValues(alpha: 0.3)
                                  : AppColors.info.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: highContrast
                                    ? AppColors.primaryMain
                                    : AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: DesignTokens.spaceS),
                              Expanded(
                                child: Text(
                                  'Best results with clear, full-body photos. Face-only photos also work.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: highContrast
                                        ? AppColors.neutral100
                                        : AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceM),
                        Text(
                          'By continuing, you agree to use this service responsibly and ethically. No harmful or inappropriate content.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: highContrast
                                ? AppColors.neutral200
                                : AppColors.neutral500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView(FitCheckProvider provider, bool highContrast) {
    final String statusTitle = provider.isLoading
        ? 'Processing Model'
        : provider.error != null
        ? 'Please Try Again'
        : 'Model Ready';
    final String statusSubtitle = provider.isLoading
        ? 'We are creating your virtual avatar.'
        : provider.error != null
        ? 'Adjust your photo or network connection and retry.'
        : 'Review the preview or continue to styling.';
    final Color panelSurface = highContrast
        ? AppColors.neutral900
        : AppColors.neutralWhite;
    final TextStyle statusCopy = AppTextStyles.bodyLarge.copyWith(
      color: highContrast ? AppColors.neutral200 : AppColors.neutral700,
    );
    final Color borderBase = highContrast
        ? AppColors.primaryMain.withValues(alpha: 0.3)
        : AppColors.primaryMain.withValues(alpha: 0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MainSectionHeader(
          title: statusTitle,
          subtitle: statusSubtitle,
          leading: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceS),
            decoration: BoxDecoration(
              color: highContrast
                  ? AppColors.primaryMain.withValues(alpha: 0.18)
                  : AppColors.primaryMain.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
            child: Icon(
              provider.isLoading
                  ? Icons.auto_mode_rounded
                  : (provider.error != null
                        ? Icons.error_outline
                        : Icons.check_circle_outline),
              color: AppColors.neutralWhite,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceXL),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              decoration: BoxDecoration(
                color: panelSurface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.isLoading) ...[
                    Container(
                      width: 320,
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL,
                        ),
                        color: highContrast
                            ? AppColors.neutral800
                            : AppColors.neutral200,
                        border: Border.all(color: borderBase, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceL),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMain,
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.neutralWhite,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXL),
                          Text(
                            'AI Processing',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: highContrast
                                  ? AppColors.neutral100
                                  : AppColors.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceM),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceXL,
                            ),
                            child: Text(
                              provider.loadingMessage,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: highContrast
                                    ? AppColors.neutral200
                                    : AppColors.neutral700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (provider.error != null) ...[
                    Container(
                      width: 320,
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL,
                        ),
                        color: highContrast
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.errorSurface,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceL),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.neutralWhite,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXL),
                          Text(
                            'We need a quick retry',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: highContrast
                                  ? AppColors.neutral100
                                  : AppColors.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceM),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceXL,
                            ),
                            child: Text(
                              provider.error!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: highContrast
                                    ? AppColors.neutral200
                                    : AppColors.neutral700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (provider.displayImageUrl != null &&
                      _userImageUrl != null) ...[
                    Container(
                      width: 320,
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL,
                        ),
                        color: panelSurface,
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: AppShadows.lg,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL - 2,
                        ),
                        child: Stack(
                          children: [
                            Image.memory(
                              Uri.parse(
                                provider.displayImageUrl!,
                              ).data!.contentAsBytes(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: DesignTokens.spaceM,
                              right: DesignTokens.spaceM,
                              child: Container(
                                padding: const EdgeInsets.all(
                                  DesignTokens.spaceS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusRound,
                                  ),
                                  boxShadow: AppShadows.md,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.neutralWhite,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Upload a photo to begin your transformation.',
                      style: statusCopy,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceXL),
        if (provider.error != null) ...[
          ModernButton(
            text: 'Try Again',
            leadingIcon: Icons.refresh,
            variant: ModernButtonVariant.secondary,
            size: ModernButtonSize.large,
            isExpanded: true,
            onPressed: _resetImage,
          ),
        ] else if (!provider.isLoading && provider.displayImageUrl != null) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ModernButton(
                  text: 'Different Photo',
                  leadingIcon: Icons.photo_camera_back,
                  variant: ModernButtonVariant.secondary,
                  size: ModernButtonSize.medium,
                  onPressed: _resetImage,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                flex: 3,
                child: ModernButton(
                  text: 'Start Styling',
                  trailingIcon: Icons.arrow_forward,
                  variant: ModernButtonVariant.success,
                  size: ModernButtonSize.medium,
                  onPressed: () {
                    widget.onModelFinalized?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool highContrast = false,
  }) {
    final Color surface = highContrast
        ? AppColors.neutral900.withValues(alpha: 0.9)
        : AppColors.neutralWhite;
    final Color titleColor = highContrast
        ? AppColors.neutral100
        : AppColors.neutral900;
    final Color subtitleColor = highContrast
        ? AppColors.neutral200
        : AppColors.neutral600;
    final Color badgeColor = highContrast
        ? iconColor.withValues(alpha: 0.2)
        : iconColor.withValues(alpha: 0.1);
    final Color iconTint = highContrast ? AppColors.neutral100 : iconColor;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
            child: Icon(icon, color: iconTint, size: 24),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(color: titleColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: subtitleColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
