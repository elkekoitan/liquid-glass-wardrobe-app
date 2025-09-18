import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini AI Service for virtual try-on functionality
/// Converted from TypeScript React service to Flutter Dart
///
/// Provides AI-powered image generation for:
/// - Model photo processing
/// - Virtual garment try-on
/// - Pose variations
/// - Color variations

class GeminiService {
  late final GenerativeModel _model;
  static const String _modelName = 'gemini-2.0-flash-image-preview';

  GeminiService({required String apiKey}) {
    _model = GenerativeModel(model: _modelName, apiKey: apiKey);
  }

  /// Convert File to base64 data part for Gemini API
  Future<DataPart> _fileToDataPart(File file) async {
    final bytes = await file.readAsBytes();
    final mimeType = _getMimeType(file.path);
    return DataPart(mimeType, bytes);
  }

  /// Convert base64 data URL to DataPart
  DataPart _dataUrlToDataPart(String dataUrl) {
    final parts = dataUrl.split(',');
    if (parts.length < 2) {
      throw Exception('Invalid data URL format');
    }

    final mimeMatch = RegExp(r':([^;]*);').firstMatch(parts[0]);
    if (mimeMatch == null) {
      throw Exception('Could not parse MIME type from data URL');
    }

    final mimeType = mimeMatch.group(1)!;
    final base64Data = parts[1];
    final bytes = base64Decode(base64Data);

    return DataPart(mimeType, bytes);
  }

  /// Get MIME type from file extension
  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Handle API response and extract image data
  String _handleApiResponse(GenerateContentResponse response) {
    // Check for prompt feedback issues
    if (response.promptFeedback?.blockReason != null) {
      final blockReason = response.promptFeedback!.blockReason;
      final blockMessage = response.promptFeedback!.blockReasonMessage ?? '';
      throw Exception(
        'Request was blocked. Reason: $blockReason. $blockMessage',
      );
    }

    final candidates = response.candidates;

    if (candidates.isEmpty) {
      throw Exception('No candidates returned by AI model.');
    }

    // Find image part in candidates
    for (final candidate in candidates) {
      final parts = candidate.content.parts;
      for (final part in parts) {
        if (part is DataPart) {
          final base64Data = base64Encode(part.bytes);
          return 'data:${part.mimeType};base64,$base64Data';
        }
      }
    }

    // Check finish reason
    final finishReason = candidates.first.finishReason;
    if (finishReason != null && finishReason != FinishReason.stop) {
      throw Exception(
        'Image generation stopped unexpectedly. Reason: $finishReason. '
        'This often relates to safety settings.',
      );
    }

    // If no image found, throw error
    final textResponse = response.text?.trim();
    throw Exception(
      'The AI model did not return an image. '
      '${textResponse != null ? 'The model responded with text: "$textResponse"' : 'This can happen due to safety filters or if the request is too complex. Please try a different image.'}',
    );
  }

  /// Generate model image from user photo
  /// Transforms user photo into professional model photo
  Future<String> generateModelImage(File userImage) async {
    try {
      final userImagePart = await _fileToDataPart(userImage);

      const prompt = '''
You are an expert fashion photographer AI. Transform the person in this image into a full-body fashion model photo suitable for an e-commerce website. The background must be a clean, neutral studio backdrop (light gray, #f0f0f0). The person should have a neutral, professional model expression. Preserve the person's identity, unique features, and body type, but place them in a standard, relaxed standing model pose. The final image must be photorealistic. Return ONLY the final image.
''';

      final response = await _model.generateContent([
        Content.multi([userImagePart, TextPart(prompt)]),
      ]);

      return _handleApiResponse(response);
    } catch (e) {
      throw Exception('Failed to generate model image: ${e.toString()}');
    }
  }

  /// Generate virtual try-on image
  /// Applies garment to model photo
  Future<String> generateVirtualTryOnImage(
    String modelImageUrl,
    File garmentImage,
  ) async {
    try {
      final modelImagePart = _dataUrlToDataPart(modelImageUrl);
      final garmentImagePart = await _fileToDataPart(garmentImage);

      const prompt = '''
You are an expert virtual try-on AI. You will be given a 'model image' and a 'garment image'. Your task is to create a new photorealistic image where the person from the 'model image' is wearing the clothing from the 'garment image'.

**Crucial Rules:**
1. **Complete Garment Replacement:** You MUST completely REMOVE and REPLACE the clothing item worn by the person in the 'model image' with the new garment. No part of the original clothing (e.g., collars, sleeves, patterns) should be visible in the final image.
2. **Preserve the Model:** The person's face, hair, body shape, and pose from the 'model image' MUST remain unchanged.
3. **Preserve the Background:** The entire background from the 'model image' MUST be preserved perfectly.
4. **Apply the Garment:** Realistically fit the new garment onto the person. It should adapt to their pose with natural folds, shadows, and lighting consistent with the original scene.
5. **Output:** Return ONLY the final, edited image. Do not include any text.
''';

      final response = await _model.generateContent([
        Content.multi([modelImagePart, garmentImagePart, TextPart(prompt)]),
      ]);

      return _handleApiResponse(response);
    } catch (e) {
      throw Exception(
        'Failed to generate virtual try-on image: ${e.toString()}',
      );
    }
  }

  /// Generate pose variation
  /// Changes the pose/perspective of the try-on image
  Future<String> generatePoseVariation(
    String tryOnImageUrl,
    String poseInstruction,
  ) async {
    try {
      final tryOnImagePart = _dataUrlToDataPart(tryOnImageUrl);

      final prompt =
          '''
You are an expert fashion photographer AI. Take this image and regenerate it from a different perspective. The person, clothing, and background style must remain identical. The new perspective should be: "$poseInstruction". Return ONLY the final image.
''';

      final response = await _model.generateContent([
        Content.multi([tryOnImagePart, TextPart(prompt)]),
      ]);

      return _handleApiResponse(response);
    } catch (e) {
      throw Exception('Failed to generate pose variation: ${e.toString()}');
    }
  }

  /// Generate color variation
  /// Changes the color of a specific garment in the image
  Future<String> generateColorVariation(
    String baseImageUrl,
    String garmentName,
    String colorPrompt,
  ) async {
    try {
      final baseImagePart = _dataUrlToDataPart(baseImageUrl);

      final prompt =
          '''
You are a virtual try-on photo editor AI. Your task is to change the color of a specific garment in the provided image.

**Instructions:**
1. **Identify the Garment:** The person in the image is wearing a "$garmentName".
2. **Change the Color:** Change the color of the "$garmentName" to "$colorPrompt".
3. **Preserve Everything Else:** The person's face, hair, body, pose, the background, and any other clothing items MUST remain completely unchanged.
4. **Realism:** Ensure the new color is applied realistically, with natural-looking shadows, highlights, and textures consistent with the original image's lighting.
5. **Output:** Return ONLY the final, edited image. Do not include any text or explanations.
''';

      final response = await _model.generateContent([
        Content.multi([baseImagePart, TextPart(prompt)]),
      ]);

      return _handleApiResponse(response);
    } catch (e) {
      throw Exception('Failed to generate color variation: ${e.toString()}');
    }
  }
}

/// Pose instruction constants - matching the React app
class PoseInstructions {
  static const List<String> instructions = [
    "Full frontal view, hands on hips",
    "Slightly turned, 3/4 view",
    "Side profile view",
    "Jumping in the air, mid-action shot",
    "Walking towards camera",
    "Leaning against a wall",
  ];
}
