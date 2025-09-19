import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:provider/provider.dart';

import '../../design_system/design_tokens.dart';
import '../../models/models.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/try_on_session_provider.dart';
import '../../utils/image_utils.dart';

class ModernPhotoUploadScreen extends StatefulWidget {
  const ModernPhotoUploadScreen({super.key, this.onPhotoUploaded});

  final VoidCallback? onPhotoUploaded;

  @override
  State<ModernPhotoUploadScreen> createState() =>
      _ModernPhotoUploadScreenState();
}

class _ModernPhotoUploadScreenState extends State<ModernPhotoUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _uploadController;

  File? _selectedImage;
  bool _simulateProgress = false;
  double _simulatedProgress = 0.0;
  GeminiErrorSurface? _lastErrorSurface;

  @override
  void initState() {
    super.initState();
    _uploadController = AnimationController(
      duration: DesignTokens.durationSlow,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _uploadController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(picker.ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final File? pickedFile = await ImageUtils.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!ImageUtils.isValidImageFile(pickedFile)) {
        _showErrorSnackBar(
          messenger,
          'Please select a valid image file (JPG, PNG, WebP).',
        );
        return;
      }

      final File? croppedFile = await ImageUtils.cropImage(
        imageFile: pickedFile,
      );

      if (!mounted) return;
      if (croppedFile == null) return;

      setState(() {
        _selectedImage = croppedFile;
      });

      await _processImage(croppedFile);
    } catch (error) {
      _showErrorSnackBar(messenger, 'Failed to process image: $error');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final messenger = ScaffoldMessenger.of(context);
    final onPhotoUploaded = widget.onPhotoUploaded;
    final session = context.read<TryOnSessionProvider>();

    setState(() {
      _simulateProgress = true;
      _simulatedProgress = 0.0;
    });

    _uploadController.forward();

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _simulatedProgress = i / 100;
      });
    }

    final success = await session.prepareModelImage(imageFile);

    if (!mounted) return;

    setState(() {
      _simulateProgress = false;
      _lastErrorSurface = session.errorSurface;
    });

    if (success && session.errorSurface == null) {
      onPhotoUploaded?.call();
    } else {
      final surface = session.errorSurface ?? _lastErrorSurface;
      if (surface != null) {
        _showErrorSnackBar(messenger, surface.message);
      }
    }
  }

  void _showErrorSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _buildImageSourceBottomSheet(sheetContext),
    );
  }

  Widget _buildImageSourceBottomSheet(BuildContext sheetContext) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          Text(
            'Choose Photo Source',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceL),
          Text(
            'Select how you\'d like to add your photo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spaceXXL),
          GestureDetector(
            onTap: () {
              sheetContext.read<NavigationProvider>().pop();
              _pickImage(picker.ImageSource.camera);
            },
            child: _PhotoSourceTile(
              icon: Icons.photo_camera,
              title: 'Take Photo',
              subtitle: 'Use your device camera',
            ),
          ),
          const SizedBox(height: DesignTokens.spaceL),
          GestureDetector(
            onTap: () {
              sheetContext.read<NavigationProvider>().pop();
              _pickImage(picker.ImageSource.gallery);
            },
            child: _PhotoSourceTile(
              icon: Icons.photo_library_rounded,
              title: 'Photo Library',
              subtitle: 'Choose an existing photo',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TryOnSessionProvider>();
    final isBusy = session.isBusy;
    final previewProgress = session.progress > 0
        ? session.progress
        : _simulatedProgress;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isBusy
              ? null
              : () => context.read<NavigationProvider>().maybePop(),
        ),
        title: Text(
          'Upload Model Photo',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _selectedImage == null
          ? _buildEmptyState(isBusy)
          : _buildImagePreview(
              session: session,
              isBusy: isBusy,
              progressValue: previewProgress,
            ),
      floatingActionButton: isBusy
          ? null
          : FloatingActionButton.extended(
              onPressed: _showImageSourceDialog,
              label: const Text('Select Photo'),
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
    );
  }

  Widget _buildEmptyState(bool isBusy) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
              border: Border.all(color: AppColors.neutral200, width: 2),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          Text(
            'Let\'s begin your try-on',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceS),
          Text(
            'Upload a well-lit, full-body photo for the best results.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          ElevatedButton.icon(
            onPressed: isBusy ? null : _showImageSourceDialog,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Select Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview({
    required TryOnSessionProvider session,
    required bool isBusy,
    required double progressValue,
  }) {
    final statusLabel = session.statusLabel;

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
                border: Border.all(color: AppColors.neutral300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXL - 2),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                    if (isBusy || _simulateProgress)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.neutral900.withValues(alpha: 0.72),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  DesignTokens.spaceXL,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusXL,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value:
                                            (progressValue > 0 &&
                                                progressValue < 1)
                                            ? progressValue
                                            : null,
                                        strokeWidth: 6,
                                        backgroundColor: AppColors.neutral200,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.neutral900,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: DesignTokens.spaceL),
                                    Text(
                                      statusLabel,
                                      style: AppTextStyles.headlineMedium
                                          .copyWith(
                                            color: AppColors.neutral900,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: DesignTokens.spaceS),
                                    Text(
                                      '${(progressValue.clamp(0.0, 1.0) * 100).toInt()}%',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.neutral600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          if (!isBusy) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _lastErrorSurface = null;
                      });
                      session.resetSession();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spaceM,
                      ),
                      side: const BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusM,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_camera_back,
                          color: AppColors.neutral700,
                        ),
                        const SizedBox(width: DesignTokens.spaceS),
                        Text(
                          'Choose Different',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _processImage(_selectedImage!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spaceM,
                      ),
                      backgroundColor: AppColors.neutral900,
                      foregroundColor: AppColors.neutralWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusM,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Process Image',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceS),
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.neutralWhite,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(color: AppColors.neutral300),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppColors.neutral900),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
