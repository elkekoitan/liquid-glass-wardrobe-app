import 'package:flutter/material.dart';
import '../design_tokens.dart';

class EnhancedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;

  const EnhancedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
  });

  @override
  State<EnhancedImage> createState() => _EnhancedImageState();
}

class _EnhancedImageState extends State<EnhancedImage> {
  late ImageProvider imageProvider;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    if (widget.imagePath.startsWith('http')) {
      imageProvider = NetworkImage(widget.imagePath);
    } else {
      imageProvider = AssetImage(widget.imagePath);
    }

    // Pre-load image to check for errors
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() => _hasError = false);
              }
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              if (mounted) {
                setState(() => _hasError = true);
              }
            },
          ),
        );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.placeholderColor ?? AppColors.neutral200,
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neutral100, AppColors.neutral200],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: (widget.width != null && widget.height != null)
              ? (widget.width! + widget.height!) / 8
              : 32,
          color: AppColors.neutral500,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: widget.borderRadius,
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: (widget.width != null && widget.height != null)
                  ? (widget.width! + widget.height!) / 12
                  : 24,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: DesignTokens.spaceXS),
            Text(
              'Image not found',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neutral400,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Image(
        image: imageProvider,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _hasError = true);
            }
          });
          return _buildErrorWidget();
        },
      ),
    );
  }
}
