import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart' as picker;
import '../../design_system/design_tokens.dart';
import '../../providers/fit_check_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/image_utils.dart';

class ModernPhotoUploadScreen extends StatefulWidget {
  final VoidCallback? onPhotoUploaded;

  const ModernPhotoUploadScreen({super.key, this.onPhotoUploaded});

  @override
  State<ModernPhotoUploadScreen> createState() =>
      _ModernPhotoUploadScreenState();
}

class _ModernPhotoUploadScreenState extends State<ModernPhotoUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _uploadController;

  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
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
    } catch (e) {
      _showErrorSnackBar(messenger, 'Failed to process image: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final messenger = ScaffoldMessenger.of(context);
    final onPhotoUploaded = widget.onPhotoUploaded;
    final provider = context.read<FitCheckProvider>();

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadController.forward();

    // Simulate upload progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 100;
        });
      }
    }

    await provider.processModelImage(imageFile);

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (provider.error == null) {
      onPhotoUploaded?.call();
    } else {
      _showErrorSnackBar(messenger, provider.error!);
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
          // Handle bar
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

          // Camera option
          GestureDetector(
            onTap: () {
              sheetContext.read<NavigationProvider>().pop();
              _pickImage(picker.ImageSource.camera);
            },
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                border: Border.all(color: AppColors.neutral300),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.neutral700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          'Take a new photo',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.neutral400,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceM),

          // Gallery option
          GestureDetector(
            onTap: () {
              sheetContext.read<NavigationProvider>().pop();
              _pickImage(picker.ImageSource.gallery);
            },
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                border: Border.all(color: AppColors.neutral300),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppColors.neutral700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          'Choose from your photos',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.neutral400,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.neutralWhite,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main Content
              Expanded(
                child: _selectedImage == null
                    ? _buildUploadInterface()
                    : _buildImagePreview(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (headerContext) => Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => headerContext.read<NavigationProvider>().maybePop(),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.neutral700,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Virtual Fitting',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'AI-powered virtual try-on technology',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadInterface() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Upload Area
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
                border: Border.all(color: AppColors.neutral300, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceL),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusRound,
                      ),
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.neutral700,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceL),
                  Text(
                    'Tap to Upload',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceS),
                  Text(
                    'Add your photo here',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXXL),

          // Tips
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceS),
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                      ),
                      child: Icon(
                        Icons.tips_and_updates,
                        color: AppColors.neutral700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceM),
                    Text(
                      'Tips for Best Results',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceL),
                ...[
                  'Natural lighting produces the best results',
                  'Full body shots ensure accurate sizing',
                  'Hold phone vertically at chest height',
                  'Form-fitting clothes show true silhouette',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.spaceS),
                    child: Text(
                      tip,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Column(
        children: [
          // Image Preview
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
                    // Image
                    Positioned.fill(
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),

                    // Upload Progress Overlay
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.neutral900.withValues(alpha: 0.7),
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
                                        value: _uploadProgress,
                                        strokeWidth: 6,
                                        backgroundColor: AppColors.neutral200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.neutral900,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: DesignTokens.spaceL),
                                    Text(
                                      'Creating Your Model...',
                                      style: AppTextStyles.headlineMedium
                                          .copyWith(
                                            color: AppColors.neutral900,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: DesignTokens.spaceS),
                                    Text(
                                      '${(_uploadProgress * 100).toInt()}%',
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

          // Action Buttons
          if (!_isUploading) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spaceM,
                      ),
                      side: BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusM,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
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
                        Icon(
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
