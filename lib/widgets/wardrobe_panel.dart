import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/fit_check_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/try_on_session_provider.dart';
import '../models/models.dart';
import '../utils/image_utils.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';
import 'package:image_picker/image_picker.dart' as picker;

/// Wardrobe Panel - Shows available garments and upload option
class WardrobePanel extends StatefulWidget {
  final Function(File garmentFile, WardrobeItem garmentInfo)? onGarmentSelect;

  const WardrobePanel({super.key, this.onGarmentSelect});

  @override
  State<WardrobePanel> createState() => _WardrobePanelState();
}

class _WardrobePanelState extends State<WardrobePanel> {
  String? _error;

  void _clearError() {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  void _showError(String error) {
    setState(() {
      _error = error;
    });
  }

  Future<void> _handleGarmentUpload() async {
    _clearError();

    try {
      final File? pickedFile = await ImageUtils.pickImage(
        source: picker.ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!ImageUtils.isValidImageFile(pickedFile)) {
        _showError('Please select a valid image file (JPG, PNG, WebP).');
        return;
      }

      // Create wardrobe item for the uploaded garment
      final customGarmentInfo = WardrobeItem(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: pickedFile.path.split('/').last,
        url: await ImageUtils.fileToDataUrl(pickedFile),
      );

      if (!mounted) return;

      // Add to provider's wardrobe
      final provider = context.read<FitCheckProvider>();
      provider.addWardrobeItem(customGarmentInfo);

      // Trigger the selection callback
      widget.onGarmentSelect?.call(pickedFile, customGarmentInfo);
    } catch (e) {
      _showError('Failed to upload garment: $e');
    }
  }

  Future<void> _handleGarmentSelect(WardrobeItem item) async {
    final provider = context.read<FitCheckProvider>();
    final session = context.read<TryOnSessionProvider>();

    if (session.isBusy || provider.activeGarmentIds.contains(item.id)) {
      return;
    }

    _clearError();

    try {
      // For uploaded items with data URLs, convert back to file
      if (item.url.startsWith('data:')) {
        final file = await ImageUtils.dataUrlToFile(
          item.url,
          fileName: item.name,
        );
        if (!mounted) return;
        widget.onGarmentSelect?.call(file, item);
      } else {
        // For default wardrobe items with URLs, we'd need to download
        // For now, show an error as we can't easily convert URLs to files in Flutter
        _showError(
          'Default wardrobe items not yet supported. Please upload your own garments.',
        );
      }
    } catch (e) {
      _showError('Failed to load garment: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer.strong(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Garment',
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              LiquidButton.primary(
                text: '📷 Camera',
                onPressed: () {
                  dialogContext.read<NavigationProvider>().pop();
                  _pickFromCamera();
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              LiquidButton.secondary(
                text: '🖼️ Gallery',
                onPressed: () {
                  dialogContext.read<NavigationProvider>().pop();
                  _handleGarmentUpload();
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              TextButton(
                onPressed: () => dialogContext.read<NavigationProvider>().pop(),
                child: Text(
                  'Cancel',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    _clearError();

    try {
      final File? pickedFile = await ImageUtils.pickImage(
        source: picker.ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!ImageUtils.isValidImageFile(pickedFile)) {
        _showError('Please select a valid image file.');
        return;
      }

      final customGarmentInfo = WardrobeItem(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Camera_${DateTime.now().millisecondsSinceEpoch}',
        url: await ImageUtils.fileToDataUrl(pickedFile),
      );

      if (!mounted) return;

      final provider = context.read<FitCheckProvider>();
      provider.addWardrobeItem(customGarmentInfo);
      widget.onGarmentSelect?.call(pickedFile, customGarmentInfo);
    } catch (e) {
      _showError('Failed to capture garment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitCheckProvider>(
      builder: (context, provider, child) {
        final wardrobe = provider.wardrobe;
        final activeIds = provider.activeGarmentIds;

        return GlassContainer.light(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wardrobe',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (wardrobe.isNotEmpty)
                    TextButton(
                      onPressed: provider.clearWardrobe,
                      child: Text(
                        'Clear All',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Wardrobe Grid
              if (wardrobe.isEmpty) ...[
                // Empty state
                Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.surfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Your wardrobe is empty',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Upload garments to start styling!',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOut),
              ] else ...[
                // Wardrobe items grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: wardrobe.length + 1, // +1 for upload button
                  itemBuilder: (context, index) {
                    if (index == wardrobe.length) {
                      // Upload button
                      return _UploadButton(
                            onTap: _showImageSourceDialog,
                            isLoading: provider.isLoading,
                          )
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .scale(
                            delay: (index * 100).ms,
                            curve: Curves.elasticOut,
                          );
                    }

                    final item = wardrobe[index];
                    final isActive = activeIds.contains(item.id);

                    return _WardrobeItemTile(
                          item: item,
                          isActive: isActive,
                          isLoading: provider.isLoading,
                          onTap: () => _handleGarmentSelect(item),
                        )
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .scale(
                          delay: (index * 100).ms,
                          curve: Curves.elasticOut,
                        );
                  },
                ),
              ],

              // Upload button (always visible)
              if (wardrobe.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child:
                      LiquidButton.primary(
                            text: '+ Add Garment',
                            onPressed: provider.isLoading
                                ? null
                                : _showImageSourceDialog,
                          )
                          .animate()
                          .fadeIn(delay: 800.ms)
                          .slideY(begin: 0.3, curve: Curves.elasticOut),
                ),
              ],

              // Error message
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
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
                          _error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.error,
                        ),
                        onPressed: _clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WardrobeItemTile extends StatelessWidget {
  final WardrobeItem item;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  const _WardrobeItemTile({
    required this.item,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isActive) ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.success : AppColors.surfaceVariant,
            width: isActive ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              // Image
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: item.url.startsWith('data:')
                    ? Image.memory(
                        Uri.parse(item.url).data!.contentAsBytes(),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        item.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.3,
                            ),
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      ),
              ),

              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Item name
              Positioned(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Text(
                  item.name,
                  style: AppTypography.bodyExtraSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Active indicator
              if (isActive)
                Positioned.fill(
                  child: Container(
                    color: AppColors.success.withValues(alpha: 0.8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

              // Loading overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _UploadButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: isLoading ? AppColors.textTertiary : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Upload',
              style: AppTypography.bodySmall.copyWith(
                color: isLoading ? AppColors.textTertiary : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
