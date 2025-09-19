import 'dart:io';

import 'package:equatable/equatable.dart';

class GeminiModelRequest extends Equatable {
  const GeminiModelRequest({
    required this.userImage,
    this.prompt = GeminiPrompts.modelPhoto,
    this.contextHints = const <String, String>{},
  });

  final File userImage;
  final String prompt;
  final Map<String, String> contextHints;

  @override
  List<Object?> get props => <Object?>[userImage.path, prompt, contextHints];
}

class GeminiBlendRequest extends Equatable {
  const GeminiBlendRequest({
    required this.modelImageDataUrl,
    required this.garmentImage,
    required this.garmentName,
    this.garmentId,
    this.prompt = GeminiPrompts.garmentBlend,
    this.contextHints = const <String, String>{},
  });

  final String modelImageDataUrl;
  final File garmentImage;
  final String garmentName;
  final String? garmentId;
  final String prompt;
  final Map<String, String> contextHints;

  @override
  List<Object?> get props => <Object?>[
        modelImageDataUrl,
        garmentImage.path,
        garmentName,
        garmentId,
        prompt,
        contextHints,
      ];
}

class GeminiPoseRequest extends Equatable {
  const GeminiPoseRequest({
    required this.baseImageDataUrl,
    required this.poseInstruction,
    this.promptTemplate = GeminiPrompts.poseTemplate,
    this.contextHints = const <String, String>{},
  });

  final String baseImageDataUrl;
  final String poseInstruction;
  final String promptTemplate;
  final Map<String, String> contextHints;

  @override
  List<Object?> get props => <Object?>[
        baseImageDataUrl,
        poseInstruction,
        promptTemplate,
        contextHints,
      ];
}

class GeminiColorRequest extends Equatable {
  const GeminiColorRequest({
    required this.baseImageDataUrl,
    required this.garmentName,
    required this.colorPrompt,
    this.promptTemplate = GeminiPrompts.colorTemplate,
    this.contextHints = const <String, String>{},
  });

  final String baseImageDataUrl;
  final String garmentName;
  final String colorPrompt;
  final String promptTemplate;
  final Map<String, String> contextHints;

  @override
  List<Object?> get props => <Object?>[
        baseImageDataUrl,
        garmentName,
        colorPrompt,
        promptTemplate,
        contextHints,
      ];
}

class GeminiErrorSurface extends Equatable {
  const GeminiErrorSurface({
    required this.code,
    required this.title,
    required this.message,
    this.actionLabel = 'Try Again',
    this.explanation,
    this.illustrationDataUrl,
    this.severity = GeminiErrorSeverity.warning,
    this.canRetry = true,
  });

  final String code;
  final String title;
  final String message;
  final String actionLabel;
  final String? explanation;
  final String? illustrationDataUrl;
  final GeminiErrorSeverity severity;
  final bool canRetry;

  @override
  List<Object?> get props => <Object?>[
        code,
        title,
        message,
        actionLabel,
        explanation,
        illustrationDataUrl,
        severity,
        canRetry,
      ];
}

class GeminiErrorSurfaceRequest extends Equatable {
  const GeminiErrorSurfaceRequest({
    required this.operation,
    required this.error,
    this.highContrast = false,
    this.reducedMotion = false,
    this.contextHints = const <String, String>{},
  });

  final String operation;
  final Object error;
  final bool highContrast;
  final bool reducedMotion;
  final Map<String, String> contextHints;

  @override
  List<Object?> get props => <Object?>[
        operation,
        error,
        highContrast,
        reducedMotion,
        contextHints,
      ];
}

class GeminiImageResult extends Equatable {
  const GeminiImageResult({
    required this.imageDataUrl,
    this.elapsed = Duration.zero,
    this.attributionToken,
    this.warnings = const <String>[],
    this.metadata = const <String, Object?>{},
  });

  final String imageDataUrl;
  final Duration elapsed;
  final String? attributionToken;
  final List<String> warnings;
  final Map<String, Object?> metadata;

  @override
  List<Object?> get props => <Object?>[
        imageDataUrl,
        elapsed,
        attributionToken,
        warnings,
        metadata,
      ];
}

class GeminiFailure implements Exception {
  GeminiFailure({
    required this.code,
    required this.message,
    required this.surface,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String message;
  final GeminiErrorSurface surface;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'GeminiFailure(code: $code, message: $message)';
}

enum GeminiErrorSeverity {
  info,
  warning,
  critical,
}

class GeminiPrompts {
  static const String modelPhoto = '''
You are an expert fashion photographer AI. Transform the person in this image into a full-body fashion model photo suitable for an e-commerce website. The background must be a clean, neutral studio backdrop (light gray, #f0f0f0). The person should have a neutral, professional model expression. Preserve the person's identity, unique features, and body type, but place them in a standard, relaxed standing model pose. The final image must be photorealistic. Return ONLY the final image.
''';

  static const String garmentBlend = '''
You are an expert virtual try-on AI. You will be given a 'model image' and a 'garment image'. Your task is to create a new photorealistic image where the person from the 'model image' is wearing the clothing from the 'garment image'.

**Crucial Rules:**
1. **Complete Garment Replacement:** You MUST completely REMOVE and REPLACE the clothing item worn by the person in the 'model image' with the new garment. No part of the original clothing (e.g., collars, sleeves, patterns) should be visible in the final image.
2. **Preserve the Model:** The person's face, hair, body shape, and pose from the 'model image' MUST remain unchanged.
3. **Preserve the Background:** The entire background from the 'model image' MUST be preserved perfectly.
4. **Apply the Garment:** Realistically fit the new garment onto the person. It should adapt to their pose with natural folds, shadows, and lighting consistent with the original scene.
5. **Output:** Return ONLY the final, edited image. Do not include any text.
''';

  static const String poseTemplate = '''
You are an expert fashion photographer AI. Take this image and regenerate it from a different perspective. The person, clothing, and background style must remain identical. The new perspective should be: "{pose}". Return ONLY the final image.
''';

  static const String colorTemplate = '''
You are a virtual try-on photo editor AI. Your task is to change the color of a specific garment in the provided image.

**Instructions:**
1. **Identify the Garment:** The person in the image is wearing a "{garment}".
2. **Change the Color:** Change the color of the "{garment}" to "{color}".
3. **Preserve Everything Else:** The person's face, hair, body, pose, the background, and any other clothing items MUST remain completely unchanged.
4. **Realism:** Ensure the new color is applied realistically, with natural-looking shadows, highlights, and textures consistent with the original image's lighting.
5. **Output:** Return ONLY the final, edited image. Do not include any text or explanations.
''';
}
