import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import 'modern_card.dart';
import 'modern_button.dart';
import 'enhanced_image.dart';

/// Fashion Category Card - Pinterest inspired
class FashionCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color? overlayColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const FashionCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.overlayColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralBlack.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: EnhancedImage(
                      imagePath: imagePath,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: overlayColor != null
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    overlayColor!,
                                    overlayColor!.withValues(alpha: 0.8),
                                  ],
                                )
                              : AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.style_rounded,
                            color: AppColors.neutralWhite,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.neutralBlack.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Selection Indicator
                  if (isSelected)
                    Positioned(
                      top: DesignTokens.spaceM,
                      right: DesignTokens.spaceM,
                      child: Container(
                        padding: const EdgeInsets.all(DesignTokens.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.neutralWhite,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusRound,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neutralBlack.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 16,
                        ),
                      ),
                    ),

                  // Content
                  Positioned(
                    left: DesignTokens.spaceL,
                    right: DesignTokens.spaceL,
                    bottom: DesignTokens.spaceL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutralWhite.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 100.ms)
        .scale(delay: 100.ms, curve: Curves.elasticOut);
  }
}

/// Outfit Combination Card - Modern Pinterest style
class OutfitCard extends StatefulWidget {
  final String outfitName;
  final List<String> itemImages;
  final String modelImage;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onTryOn;

  const OutfitCard({
    super.key,
    required this.outfitName,
    required this.itemImages,
    required this.modelImage,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onTryOn,
  });

  @override
  State<OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<OutfitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _onFavoritePressed() {
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    widget.onFavorite?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      variant: CardVariant.elevated,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Image with overlay
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              child: Stack(
                children: [
                  // Model Background
                  Positioned.fill(
                    child: EnhancedImage(
                      imagePath: widget.modelImage,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.fashionAIGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: AppColors.neutralWhite,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: DesignTokens.spaceM,
                    right: DesignTokens.spaceM,
                    child: AnimatedBuilder(
                      animation: _favoriteAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _favoriteAnimation.value,
                          child: GestureDetector(
                            onTap: _onFavoritePressed,
                            child: Container(
                              padding: const EdgeInsets.all(
                                DesignTokens.spaceS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutralWhite.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusRound,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neutralBlack.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: widget.isFavorite
                                    ? AppColors.error
                                    : AppColors.neutral600,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Item Preview Row
                  Positioned(
                    bottom: DesignTokens.spaceM,
                    left: DesignTokens.spaceM,
                    right: DesignTokens.spaceM,
                    child: Row(
                      children: [
                        ...widget.itemImages
                            .take(3)
                            .map(
                              (image) => Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(
                                  right: DesignTokens.spaceS,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.neutralWhite,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusS,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusS - 2,
                                  ),
                                  child: EnhancedImage(
                                    imagePath: image,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: AppColors.neutral300,
                                      child: const Icon(
                                        Icons.checkroom,
                                        color: AppColors.neutral600,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        if (widget.itemImages.length > 3)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.neutralWhite.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusS,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${widget.itemImages.length - 3}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.neutral900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceM),

          // Outfit Info
          Text(
            widget.outfitName,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: DesignTokens.spaceS),

          Text(
            '${widget.itemImages.length} items',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),

          const SizedBox(height: DesignTokens.spaceM),

          // Try On Button
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: 'Try On',
              leadingIcon: Icons.auto_awesome,
              variant: ModernButtonVariant.gradient,
              size: ModernButtonSize.small,
              onPressed: widget.onTryOn,
            ),
          ),
        ],
      ),
    );
  }
}

/// Model Display Grid Item - Pinterest grid style
class ModelGridItem extends StatelessWidget {
  final String imageUrl;
  final String modelName;
  final String outfitCount;
  final VoidCallback? onTap;

  const ModelGridItem({
    super.key,
    required this.imageUrl,
    required this.modelName,
    required this.outfitCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralBlack.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              child: Stack(
                children: [
                  // Model Image
                  Positioned.fill(
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.fashionAIGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.neutralWhite,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.neutralBlack.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Model Info
                  Positioned(
                    left: DesignTokens.spaceM,
                    right: DesignTokens.spaceM,
                    bottom: DesignTokens.spaceM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          modelName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          '$outfitCount outfits',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutralWhite.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms)
        .scale(delay: 200.ms, curve: Curves.easeOut);
  }
}

/// Wishlist Item Card - Modern design
class WishlistItemCard extends StatelessWidget {
  final String itemName;
  final String brand;
  final String price;
  final String imageUrl;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToOutfit;

  const WishlistItemCard({
    super.key,
    required this.itemName,
    required this.brand,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.onTap,
    this.onRemove,
    this.onAddToOutfit,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      variant: CardVariant.outlined,
      onTap: onTap,
      child: Row(
        children: [
          // Item Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              color: AppColors.neutral100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.neutral200,
                    child: const Icon(
                      Icons.checkroom,
                      color: AppColors.neutral600,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: DesignTokens.spaceM),

          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  brand,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceS),
                Row(
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceS,
                        vertical: DesignTokens.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusS,
                        ),
                      ),
                      child: Text(
                        isAvailable ? 'In Stock' : 'Out of Stock',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isAvailable
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: DesignTokens.spaceM),

          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: onAddToOutfit,
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary500,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceS),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick Action Buttons - Floating style
class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.iconColor = AppColors.neutralWhite,
    this.onPressed,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceL,
                vertical: DesignTokens.spaceM,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: widget.iconColor, size: 20),
                  const SizedBox(width: DesignTokens.spaceS),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.iconColor,
                      fontWeight: FontWeight.w600,
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
