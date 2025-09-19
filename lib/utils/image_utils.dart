import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Image utilities for photo selection, cropping, and processing
/// Handles all image operations needed for the fit-check app

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  static Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  /// Crop image with custom aspect ratio
  static Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF1A1A1A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            showCropGrid: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      throw Exception('Failed to crop image: ${e.toString()}');
    }
  }

  /// Convert image file to base64 data URL
  static Future<String> fileToDataUrl(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _getMimeType(imageFile.path);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to convert file to data URL: ${e.toString()}');
    }
  }

  /// Convert a base64 data URL into raw bytes.
  static Uint8List dataUrlToBytes(String dataUrl) {
    final parts = dataUrl.split(',');
    if (parts.length != 2) {
      throw FormatException('Invalid data URL format');
    }
    return base64Decode(parts[1]);
  }

  /// Convert base64 data URL to File
  static Future<File> dataUrlToFile(String dataUrl, {String? fileName}) async {
    try {
      final parts = dataUrl.split(',');
      if (parts.length != 2) {
        throw Exception('Invalid data URL format');
      }

      final base64String = parts[1];
      final bytes = base64Decode(base64String);

      final tempDir = await getTemporaryDirectory();
      final name = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}';
      final extension = _getExtensionFromDataUrl(dataUrl);
      final file = File(path.join(tempDir.path, '$name.$extension'));

      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw Exception('Failed to convert data URL to file: ${e.toString()}');
    }
  }

  /// Resize image to specific dimensions
  static Future<File> resizeImage({
    required File imageFile,
    int? width,
    int? height,
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      late img.Image resized;

      if (width != null && height != null) {
        resized = img.copyResize(image, width: width, height: height);
      } else if (width != null) {
        resized = img.copyResize(image, width: width);
      } else if (height != null) {
        resized = img.copyResize(image, height: height);
      } else {
        resized = image;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final resizedFile = File(path.join(tempDir.path, fileName));

      await resizedFile.writeAsBytes(img.encodeJpg(resized, quality: quality));
      return resizedFile;
    } catch (e) {
      throw Exception('Failed to resize image: ${e.toString()}');
    }
  }

  /// Compress image to reduce file size
  static Future<File> compressImage({
    required File imageFile,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      late img.Image processed = image;

      // Resize if dimensions are specified
      if (maxWidth != null || maxHeight != null) {
        final currentWidth = image.width;
        final currentHeight = image.height;

        int newWidth = currentWidth;
        int newHeight = currentHeight;

        if (maxWidth != null && currentWidth > maxWidth) {
          newWidth = maxWidth;
          newHeight = (currentHeight * maxWidth / currentWidth).round();
        }

        if (maxHeight != null && newHeight > maxHeight) {
          newHeight = maxHeight;
          newWidth = (newWidth * maxHeight / newHeight).round();
        }

        if (newWidth != currentWidth || newHeight != currentHeight) {
          processed = img.copyResize(image, width: newWidth, height: newHeight);
        }
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(path.join(tempDir.path, fileName));

      await compressedFile.writeAsBytes(
        img.encodeJpg(processed, quality: quality),
      );
      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
    }
  }

  /// Save image to gallery/photos (platform specific)
  static Future<bool> saveImageToGallery(File imageFile) async {
    try {
      // This would require additional packages like gal or image_gallery_saver
      // For now, we'll just copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'fit_check_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File(path.join(appDir.path, fileName));

      await imageFile.copy(savedFile.path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get image dimensions
  static Future<Size> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      throw Exception('Failed to get image dimensions: ${e.toString()}');
    }
  }

  /// Get MIME type from file path
  static String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Get file extension from data URL
  static String _getExtensionFromDataUrl(String dataUrl) {
    final mimeMatch = RegExp(r'data:image/([a-zA-Z]*);').firstMatch(dataUrl);
    if (mimeMatch != null) {
      final mimeType = mimeMatch.group(1)!.toLowerCase();
      switch (mimeType) {
        case 'jpeg':
          return 'jpg';
        case 'png':
          return 'png';
        case 'webp':
          return 'webp';
        case 'gif':
          return 'gif';
        default:
          return 'jpg';
      }
    }
    return 'jpg';
  }

  /// Validate if file is a supported image format
  static bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp'].contains(extension);
  }

  /// Get file size in bytes
  static Future<int> getFileSizeInBytes(File file) async {
    return await file.length();
  }

  /// Get human readable file size
  static String getHumanReadableFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}

/// Size class for image dimensions
class Size {
  final double width;
  final double height;

  const Size(this.width, this.height);

  @override
  String toString() => 'Size($width, $height)';
}
