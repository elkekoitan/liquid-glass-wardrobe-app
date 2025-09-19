import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'fit_check_provider.dart';
import '../providers/personalization_provider.dart';
import '../services/gemini_service.dart';

class TryOnSessionProvider extends ChangeNotifier {
  FitCheckProvider? _fitCheck;
  PersonalizationProvider? _personalization;
  GeminiService? _gemini;
  GeminiServiceConfig? _config;

  TryOnSessionStage _stage = TryOnSessionStage.idle;
  double _progress = 0.0;
  String? _statusMessage;
  GeminiErrorSurface? _errorSurface;

  void updateDependencies({
    required FitCheckProvider fitCheck,
    required PersonalizationProvider personalization,
    required String? apiKey,
    GeminiServiceConfig? config,
  }) {
    final trimmedKey = apiKey?.trim();
    _fitCheck = fitCheck;
    _personalization = personalization;

    if (trimmedKey == null || trimmedKey.isEmpty) {
      return;
    }

    final resolvedConfig = config ?? const GeminiServiceConfig();
    final needsService =
        _gemini == null ||
        _config?.modelName != resolvedConfig.modelName ||
        _config?.requestTimeout != resolvedConfig.requestTimeout;

    if (needsService) {
      _gemini = GeminiService(apiKey: trimmedKey, config: resolvedConfig);
      _config = resolvedConfig;
      fitCheck.attachGeminiService(_gemini!);
    } else {
      fitCheck.attachGeminiService(_gemini!);
    }
  }

  TryOnSessionStage get stage => _stage;
  double get progress => _progress.clamp(0.0, 1.0);
  String get statusLabel => _statusMessage ?? _defaultStatusForStage(_stage);
  GeminiErrorSurface? get errorSurface => _errorSurface;

  bool get isBusy =>
      _stage == TryOnSessionStage.uploading ||
      _stage == TryOnSessionStage.processingModel ||
      _stage == TryOnSessionStage.blending ||
      _stage == TryOnSessionStage.updatingPose ||
      _stage == TryOnSessionStage.updatingColor;

  bool get hasError => _stage == TryOnSessionStage.failed;
  bool get isConfigured => _gemini != null;

  Future<bool> prepareModelImage(File userImage) async {
    final fitCheck = _ensureFitCheck();
    if (!isConfigured) {
      await _recordFailure(
        'configuration',
        StateError('Missing Gemini API key.'),
      );
      return false;
    }

    _startOperation(
      TryOnSessionStage.uploading,
      message: 'Uploading photo…',
      progress: 0.1,
    );

    try {
      await fitCheck.processModelImage(
        userImage,
        contextHints: _buildContextHints(),
      );

      _completeOperation(message: 'Model ready');
      return true;
    } on GeminiFailure catch (failure) {
      await _recordFailure('model_image', failure);
      return false;
    } catch (error) {
      await _recordFailure('model_image', error);
      return false;
    }
  }

  Future<bool> blendGarment(File garmentFile, WardrobeItem garment) async {
    final fitCheck = _ensureFitCheck();
    if (!isConfigured) {
      await _recordFailure(
        'configuration',
        StateError('Missing Gemini API key.'),
      );
      return false;
    }

    _startOperation(
      TryOnSessionStage.blending,
      message: 'Blending ${garment.name}…',
      progress: 0.15,
    );

    try {
      await fitCheck.applyGarment(
        garmentFile,
        garment,
        contextHints: _buildContextHints(
          additional: <String, String>{
            'garment_id': garment.id,
            'garment_name': garment.name,
          },
        ),
      );

      _completeOperation(message: '${garment.name} applied');
      return true;
    } on GeminiFailure catch (failure) {
      await _recordFailure('garment_blend', failure);
      return false;
    } catch (error) {
      await _recordFailure('garment_blend', error);
      return false;
    }
  }

  Future<bool> requestPoseChange(int newPoseIndex) async {
    final fitCheck = _ensureFitCheck();
    if (!isConfigured) {
      await _recordFailure(
        'configuration',
        StateError('Missing Gemini API key.'),
      );
      return false;
    }

    _startOperation(
      TryOnSessionStage.updatingPose,
      message: 'Reframing pose…',
      progress: 0.2,
    );

    try {
      await fitCheck.changePose(
        newPoseIndex,
        contextHints: _buildContextHints(),
      );

      _completeOperation(message: 'Pose updated');
      return true;
    } on GeminiFailure catch (failure) {
      await _recordFailure('pose_generation', failure);
      return false;
    } catch (error) {
      await _recordFailure('pose_generation', error);
      return false;
    }
  }

  Future<bool> requestColorChange(int layerIndex, String prompt) async {
    final fitCheck = _ensureFitCheck();
    if (!isConfigured) {
      await _recordFailure(
        'configuration',
        StateError('Missing Gemini API key.'),
      );
      return false;
    }

    _startOperation(
      TryOnSessionStage.updatingColor,
      message: 'Recolouring layer…',
      progress: 0.2,
    );

    try {
      await fitCheck.changeGarmentColor(
        layerIndex,
        prompt,
        contextHints: _buildContextHints(
          additional: <String, String>{'color_prompt': prompt},
        ),
      );

      _completeOperation(message: 'Colour updated');
      return true;
    } on GeminiFailure catch (failure) {
      await _recordFailure('color_variation', failure);
      return false;
    } catch (error) {
      await _recordFailure('color_variation', error);
      return false;
    }
  }

  void resetSession() {
    _fitCheck?.startOver();
    _stage = TryOnSessionStage.idle;
    _progress = 0.0;
    _statusMessage = null;
    _errorSurface = null;
    notifyListeners();
  }

  void clearError() {
    if (_stage == TryOnSessionStage.failed) {
      _stage = TryOnSessionStage.idle;
      _statusMessage = null;
      _errorSurface = null;
      notifyListeners();
    }
  }

  FitCheckProvider _ensureFitCheck() {
    final provider = _fitCheck;
    if (provider == null) {
      throw StateError('FitCheckProvider not wired into TryOnSessionProvider.');
    }
    return provider;
  }

  void _startOperation(
    TryOnSessionStage stage, {
    required String message,
    double progress = 0.0,
  }) {
    _stage = stage;
    _progress = progress;
    _statusMessage = message;
    _errorSurface = null;
    notifyListeners();
  }

  void _completeOperation({required String message}) {
    _stage = TryOnSessionStage.ready;
    _progress = 1.0;
    _statusMessage = message;
    _errorSurface = null;
    notifyListeners();
  }

  Future<void> _recordFailure(String operation, Object error) async {
    final surface = await _resolveSurface(operation, error);
    _stage = TryOnSessionStage.failed;
    _progress = 0.0;
    _statusMessage = surface.message;
    _errorSurface = surface;
    notifyListeners();
  }

  Future<GeminiErrorSurface> _resolveSurface(
    String operation,
    Object error,
  ) async {
    if (error is GeminiFailure) {
      return error.surface;
    }

    final service = _gemini;
    if (service != null) {
      return service.generateErrorSurface(
        GeminiErrorSurfaceRequest(
          operation: operation,
          error: error,
          highContrast: _personalization?.highContrast ?? false,
          reducedMotion: _personalization?.reducedMotion ?? false,
          contextHints: _buildContextHints(),
        ),
      );
    }

    return GeminiErrorSurface(
      code: '${operation}_fallback',
      title: 'Try-On Issue',
      message: 'We could not finish the $operation request.',
      explanation: error.toString(),
      actionLabel: 'Try Again',
      severity: GeminiErrorSeverity.warning,
    );
  }

  Map<String, String> _buildContextHints({
    Map<String, String> additional = const <String, String>{},
  }) {
    final personalization = _personalization;
    final hints = <String, String>{
      ...additional,
      if (personalization != null) ...<String, String>{
        'personalization.highContrast': personalization.highContrast.toString(),
        'personalization.reducedMotion': personalization.reducedMotion
            .toString(),
        'personalization.defaultCapsule': personalization.defaultCapsule,
      },
    };

    hints.removeWhere((key, value) => value.isEmpty);
    return hints;
  }

  String _defaultStatusForStage(TryOnSessionStage stage) {
    switch (stage) {
      case TryOnSessionStage.idle:
        return 'Ready when you are';
      case TryOnSessionStage.uploading:
        return 'Uploading photo…';
      case TryOnSessionStage.processingModel:
        return 'Processing model…';
      case TryOnSessionStage.blending:
        return 'Applying garment…';
      case TryOnSessionStage.updatingPose:
        return 'Updating pose…';
      case TryOnSessionStage.updatingColor:
        return 'Updating colour…';
      case TryOnSessionStage.ready:
        return 'Model ready';
      case TryOnSessionStage.failed:
        return 'Something went wrong';
    }
  }
}

enum TryOnSessionStage {
  idle,
  uploading,
  processingModel,
  blending,
  updatingPose,
  updatingColor,
  ready,
  failed,
}
