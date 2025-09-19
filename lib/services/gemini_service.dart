import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/models.dart';

class GeminiServiceConfig {
  const GeminiServiceConfig({
    this.modelName = 'gemini-2.0-flash-image-preview',
    this.requestTimeout = const Duration(seconds: 60),
  });

  final String modelName;
  final Duration requestTimeout;

  GeminiServiceConfig copyWith({String? modelName, Duration? requestTimeout}) {
    return GeminiServiceConfig(
      modelName: modelName ?? this.modelName,
      requestTimeout: requestTimeout ?? this.requestTimeout,
    );
  }

  static GeminiServiceConfig fromEnv(Map<String, String> env) {
    final model = env['GEMINI_VTO_MODEL']?.trim();
    final timeout = env['GEMINI_TIMEOUT']?.trim();

    Duration? parsedTimeout;
    if (timeout != null && timeout.isNotEmpty) {
      final seconds = int.tryParse(timeout);
      if (seconds != null && seconds > 0) {
        parsedTimeout = Duration(seconds: seconds);
      }
    }

    return GeminiServiceConfig(
      modelName: (model != null && model.isNotEmpty)
          ? model
          : 'gemini-2.0-flash-image-preview',
      requestTimeout: parsedTimeout ?? const Duration(seconds: 60),
    );
  }
}

class GeminiService {
  factory GeminiService({
    required String apiKey,
    GeminiServiceConfig? config,
    GenerativeModel? client,
    Future<GenerateContentResponse> Function(Iterable<Content> prompt)?
    overrideGenerator,
  }) {
    final resolved = config ?? const GeminiServiceConfig();
    final model =
        client ?? GenerativeModel(model: resolved.modelName, apiKey: apiKey);
    return GeminiService._(resolved, model, override: overrideGenerator);
  }

  GeminiService._(
    this._config,
    this._model, {
    Future<GenerateContentResponse> Function(Iterable<Content> prompt)?
    override,
  }) {
    _contentGenerator = override ?? (prompt) => _model.generateContent(prompt);
  }

  final GeminiServiceConfig _config;
  final GenerativeModel _model;
  late final Future<GenerateContentResponse> Function(Iterable<Content> prompt)
  _contentGenerator;

  GeminiServiceConfig get config => _config;

  Future<GeminiImageResult> generateModelImage(
    GeminiModelRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final userPart = await _fileToDataPart(request.userImage);
      final prompt = _mergePrompt(request.prompt, request.contextHints);

      final response = await _withTimeout(
        _contentGenerator([
          Content.multi([userPart, TextPart(prompt)]),
        ]),
      );

      stopwatch.stop();
      return _extractImage(
        response,
        elapsed: stopwatch.elapsed,
        contextHints: request.contextHints,
      );
    } on GeminiFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw _wrapException(
        code: 'model_image_error',
        message: 'Failed to generate model image.',
        error: error,
        stackTrace: stackTrace,
        contextHints: request.contextHints,
      );
    }
  }

  Future<GeminiImageResult> blendGarment(GeminiBlendRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final modelPart = _dataUrlToDataPart(request.modelImageDataUrl);
      final garmentPart = await _fileToDataPart(request.garmentImage);
      final prompt = _mergePrompt(request.prompt, <String, String>{
        ...request.contextHints,
        'garment_name': request.garmentName,
        if (request.garmentId != null) 'garment_id': request.garmentId!,
      });

      final response = await _withTimeout(
        _contentGenerator([
          Content.multi([modelPart, garmentPart, TextPart(prompt)]),
        ]),
      );

      stopwatch.stop();
      return _extractImage(
        response,
        elapsed: stopwatch.elapsed,
        contextHints: request.contextHints,
        extraMetadata: <String, Object?>{
          'garmentName': request.garmentName,
          if (request.garmentId != null) 'garmentId': request.garmentId,
        },
      );
    } on GeminiFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw _wrapException(
        code: 'garment_blend_error',
        message: 'Failed to blend garment onto the model.',
        error: error,
        stackTrace: stackTrace,
        contextHints: request.contextHints,
      );
    }
  }

  Future<GeminiImageResult> generatePoseVariation(
    GeminiPoseRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final basePart = _dataUrlToDataPart(request.baseImageDataUrl);
      final prompt = _mergePrompt(
        request.promptTemplate.replaceFirst('{pose}', request.poseInstruction),
        request.contextHints,
      );

      final response = await _withTimeout(
        _contentGenerator([
          Content.multi([basePart, TextPart(prompt)]),
        ]),
      );

      stopwatch.stop();
      return _extractImage(
        response,
        elapsed: stopwatch.elapsed,
        contextHints: request.contextHints,
        extraMetadata: <String, Object?>{'pose': request.poseInstruction},
      );
    } on GeminiFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw _wrapException(
        code: 'pose_generation_error',
        message: 'Failed to generate pose variation.',
        error: error,
        stackTrace: stackTrace,
        contextHints: request.contextHints,
      );
    }
  }

  Future<GeminiImageResult> generateColorVariation(
    GeminiColorRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final basePart = _dataUrlToDataPart(request.baseImageDataUrl);
      final prompt = _mergePrompt(
        request.promptTemplate
            .replaceFirst('{garment}', request.garmentName)
            .replaceFirst('{color}', request.colorPrompt),
        request.contextHints,
      );

      final response = await _withTimeout(
        _contentGenerator([
          Content.multi([basePart, TextPart(prompt)]),
        ]),
      );

      stopwatch.stop();
      return _extractImage(
        response,
        elapsed: stopwatch.elapsed,
        contextHints: request.contextHints,
        extraMetadata: <String, Object?>{
          'garmentName': request.garmentName,
          'color': request.colorPrompt,
        },
      );
    } on GeminiFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw _wrapException(
        code: 'color_variation_error',
        message: 'Failed to generate colour variation.',
        error: error,
        stackTrace: stackTrace,
        contextHints: request.contextHints,
      );
    }
  }

  Future<GeminiErrorSurface> generateErrorSurface(
    GeminiErrorSurfaceRequest request,
  ) async {
    if (request.error is GeminiFailure) {
      return (request.error as GeminiFailure).surface;
    }

    final explanation = request.error.toString();
    final title = request.highContrast ? 'Try-On Paused' : 'Try-On Issue';
    final action = request.reducedMotion ? 'Retry' : 'Try Again';

    return GeminiErrorSurface(
      code: '${request.operation}_fallback',
      title: title,
      message:
          'We couldn\'t finish the ${request.operation.replaceAll('_', ' ')} request.',
      explanation: explanation,
      actionLabel: action,
      severity: GeminiErrorSeverity.warning,
    );
  }

  Future<T> _withTimeout<T>(Future<T> future) =>
      future.timeout(_config.requestTimeout);

  Future<DataPart> _fileToDataPart(File file) async {
    final bytes = await file.readAsBytes();
    final mimeType = _getMimeType(file.path);
    return DataPart(mimeType, bytes);
  }

  DataPart _dataUrlToDataPart(String dataUrl) {
    final parts = dataUrl.split(',');
    if (parts.length < 2) {
      throw ArgumentError('Invalid data URL format.');
    }

    final mimeMatch = RegExp(r':([^;]*);').firstMatch(parts[0]);
    if (mimeMatch == null) {
      throw ArgumentError('Unable to parse MIME type from data URL.');
    }

    final mimeType = mimeMatch.group(1)!;
    final bytes = base64Decode(parts[1]);
    return DataPart(mimeType, bytes);
  }

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

  GeminiImageResult _extractImage(
    GenerateContentResponse response, {
    required Duration elapsed,
    Map<String, String> contextHints = const <String, String>{},
    Map<String, Object?> extraMetadata = const <String, Object?>{},
  }) {
    final feedback = response.promptFeedback;
    if (feedback?.blockReason != null) {
      throw _wrapException(
        code: 'request_blocked_${feedback!.blockReason!.name}',
        message:
            feedback.blockReasonMessage ??
            'The request was blocked by Gemini safety systems.',
        error: feedback,
        contextHints: contextHints,
      );
    }

    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is DataPart) {
          final dataUrl =
              'data:${part.mimeType};base64,${base64Encode(part.bytes)}';
          final warnings = <String>[];
          if (candidate.finishReason != null &&
              candidate.finishReason != FinishReason.stop) {
            warnings.add('finish_reason:${candidate.finishReason!.name}');
          }
          final metadata = <String, Object?>{
            ...extraMetadata,
            if (candidate.safetyRatings != null &&
                candidate.safetyRatings!.isNotEmpty)
              'safetyRatings': candidate.safetyRatings!
                  .map(
                    (rating) =>
                        '${rating.category.name}:${rating.probability.name}',
                  )
                  .toList(),
          };

          return GeminiImageResult(
            imageDataUrl: dataUrl,
            elapsed: elapsed,
            warnings: warnings,
            metadata: metadata,
          );
        }
      }
    }

    final finishReason = response.candidates.isNotEmpty
        ? response.candidates.first.finishReason
        : null;

    throw _wrapException(
      code: 'missing_image_candidate',
      message: 'Gemini did not return an image candidate.',
      error: finishReason ?? 'missing_candidate',
      contextHints: contextHints,
    );
  }

  GeminiFailure _wrapException({
    required String code,
    required String message,
    required Object error,
    StackTrace? stackTrace,
    Map<String, String> contextHints = const <String, String>{},
  }) {
    final surface = _surfaceFromError(
      code: code,
      message: message,
      error: error,
      contextHints: contextHints,
    );

    return GeminiFailure(
      code: code,
      message: surface.message,
      surface: surface,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  GeminiErrorSurface _surfaceFromError({
    required String code,
    required String message,
    required Object error,
    Map<String, String> contextHints = const <String, String>{},
  }) {
    if (error is PromptFeedback) {
      final reasonName = error.blockReason?.name ?? 'unknown';
      return GeminiErrorSurface(
        code: 'blocked_$reasonName',
        title: 'Request Blocked',
        message: error.blockReasonMessage ?? message,
        explanation:
            'Gemini blocked the request (${reasonName.toUpperCase()}).',
        actionLabel: 'Adjust Input',
        severity: GeminiErrorSeverity.warning,
        canRetry: false,
      );
    }

    if (error is TimeoutException) {
      return GeminiErrorSurface(
        code: '${code}_timeout',
        title: 'Connection Timed Out',
        message: 'Gemini took too long to respond. Please try again.',
        explanation: 'Timeout after ${_config.requestTimeout.inSeconds}s.',
        actionLabel: 'Retry',
        severity: GeminiErrorSeverity.warning,
      );
    }

    if (error is FinishReason && error != FinishReason.stop) {
      return GeminiErrorSurface(
        code: '${code}_${error.name}',
        title: 'Incomplete Response',
        message: 'Gemini stopped early while generating the image.',
        explanation: 'Finish reason: ${error.name}.',
        actionLabel: 'Retry',
        severity: GeminiErrorSeverity.warning,
      );
    }

    if (error is GenerativeAIException) {
      return GeminiErrorSurface(
        code: '${code}_${error.message}',
        title: 'Gemini Service Error',
        message: message,
        explanation: error.message,
        actionLabel: 'Retry',
        severity: GeminiErrorSeverity.warning,
      );
    }

    return GeminiErrorSurface(
      code: code,
      title: 'Try-On Failed',
      message: message,
      explanation: error.toString(),
      actionLabel: 'Try Again',
      severity: GeminiErrorSeverity.critical,
    );
  }

  String _mergePrompt(String prompt, Map<String, String> hints) {
    if (hints.isEmpty) {
      return prompt;
    }

    final buffer = StringBuffer(prompt.trim());
    buffer.writeln('\n\nContext hints:');
    hints.forEach((key, value) {
      buffer.writeln('- $key: $value');
    });
    return buffer.toString();
  }
}

class PoseInstructions {
  static const List<String> instructions = <String>[
    'Full frontal view, hands on hips',
    'Slightly turned, 3/4 view',
    'Side profile view',
    'Jumping in the air, mid-action shot',
    'Walking towards camera',
    'Leaning against a wall',
  ];
}
