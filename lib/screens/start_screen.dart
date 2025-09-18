 import 'dart:io';
 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/fit_check_provider.dart';
 import '../utils/image_utils.dart';
 import 'package:image_picker/image_picker.dart' as picker;

 import '../design_system/design_tokens.dart';
 import '../design_system/components/modern_button.dart';

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
  File? _userImageFile;
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

      setState(() {
        _userImageFile = croppedFile;
        _userImageUrl = dataUrl;
        _showComparison = true;
      });

      // Process with AI
      final provider = context.read<FitCheckProvider>();
      await provider.processModelImage(croppedFile);

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
                    color: AppColors.error.withOpacity(0.2),
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
      _userImageFile = null;
      _userImageUrl = null;
      _showComparison = false;
    });

    final provider = context.read<FitCheckProvider>();
    provider.startOver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: SafeArea(
        child: Consumer<FitCheckProvider>(
          builder: (context, provider, child) {
            return AnimatedSwitcher(
              duration: DesignTokens.durationSlow,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: DesignTokens.curveSmooth,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _showComparison
                  ? _buildComparisonView(provider)
                  : _buildWelcomeView(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Section
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceXXL),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Column(
                        children: [
                          // AI Icon
                          Container(
                            padding: const EdgeInsets.all(
                              DesignTokens.spaceL,
                            ),
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
                              color: AppColors.neutral900,
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
                              style: AppTextStyles.headlineMedium
                                  .copyWith(
                                    color: AppColors.neutralWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: DesignTokens.spaceXL),

                          Text(
                            'Upload your photo and let our advanced AI create your personal virtual model. Try on clothes, experiment with styles, and see how you look before you buy.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.neutral700,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spaceXXL),

                    // Features Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            title: 'Fast',
                            subtitle: 'Results in seconds',
                            icon: Icons.flash_on,
                            iconColor: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceM),
                        Expanded(
                          child: _buildFeatureCard(
                            title: 'Accurate',
                            subtitle: 'AI-powered precision',
                            icon: Icons.gps_fixed,
                            iconColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceM),
                        Expanded(
                          child: _buildFeatureCard(
                            title: 'Private',
                            subtitle: 'Your photos stay secure',
                            icon: Icons.security,
                            iconColor: AppColors.primaryMain,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.spaceXXL),

                    // Upload Button Section
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceXL),
                      decoration: BoxDecoration(
                        color: AppColors.neutralWhite,
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
                            padding: const EdgeInsets.all(
                              DesignTokens.spaceM,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoSurface,
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusM,
                              ),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: DesignTokens.spaceS),
                                Expanded(
                                  child: Text(
                                    'Best results with clear, full-body photos. Face-only photos also work.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.info,
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
                              color: AppColors.neutral500,
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
      ),
    );
  }

  Widget _buildComparisonView(FitCheckProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceXL),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              children: [
                Text(
                  'AI Processing',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: DesignTokens.spaceS),

                Text(
                  provider.isLoading
                      ? 'Creating your virtual model...'
                      : 'Your transformation is complete!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.neutral700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Image Processing Display
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
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
                          color: AppColors.neutral200,
                          border: Border.all(
                            color: AppColors.primaryMain.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                DesignTokens.spaceL,
                              ),
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
                                color: AppColors.neutral900,
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
                                  color: AppColors.neutral700,
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
                          color: AppColors.errorSurface,
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                DesignTokens.spaceL,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 48,
                              ),
                            ),

                            const SizedBox(height: DesignTokens.spaceXL),

                            Text(
                              'Processing Failed',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.neutral900,
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
                                  color: AppColors.neutral700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (provider.displayImageUrl != null &&
                        _userImageUrl != null) ...[
                      // Success - show result
                      Container(
                        width: 320,
                        height: 450,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusL,
                          ),
                          color: AppColors.neutralWhite,
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
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
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Action Buttons
          if (provider.error != null) ...[
            ModernButton(
              text: 'Try Again',
              leadingIcon: Icons.refresh,
              variant: ModernButtonVariant.secondary,
              size: ModernButtonSize.large,
              isExpanded: true,
              onPressed: _resetImage,
            ),
          ] else if (!provider.isLoading &&
              provider.displayImageUrl != null) ...[
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
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
