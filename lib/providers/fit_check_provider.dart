import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/gemini_service.dart';

/// Main state provider for FitCheck app.
///
/// Manages outfit history, wardrobe items, and coordinates Gemini operations.
class FitCheckProvider extends ChangeNotifier {
  String? _modelImageUrl;
  List<OutfitLayer> _outfitHistory = <OutfitLayer>[];
  int _currentOutfitIndex = 0;
  final List<WardrobeItem> _wardrobe = <WardrobeItem>[];

  bool _isLoading = false;
  String _loadingMessage = '';
  String? _error;
  int _currentPoseIndex = 0;

  GeminiService? _geminiService;

  void attachGeminiService(GeminiService service) {
    _geminiService = service;
  }

  bool get hasGeminiService => _geminiService != null;

  String? get modelImageUrl => _modelImageUrl;
  List<OutfitLayer> get outfitHistory =>
      List<OutfitLayer>.unmodifiable(_outfitHistory);
  int get currentOutfitIndex => _currentOutfitIndex;
  List<WardrobeItem> get wardrobe => List<WardrobeItem>.unmodifiable(_wardrobe);
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;
  String? get error => _error;
  int get currentPoseIndex => _currentPoseIndex;

  List<OutfitLayer> get activeOutfitLayers =>
      _outfitHistory.take(_currentOutfitIndex + 1).toList();

  List<String> get activeGarmentIds => activeOutfitLayers
      .map((layer) => layer.garment?.id)
      .where((id) => id != null)
      .cast<String>()
      .toList();

  String? get displayImageUrl {
    if (_outfitHistory.isEmpty) return _modelImageUrl;
    final currentLayer = _outfitHistory[_currentOutfitIndex];
    final poseInstruction = PoseInstructions.instructions[_currentPoseIndex];
    return currentLayer.poseImages[poseInstruction] ??
        currentLayer.poseImages.values.first;
  }

  List<String> get availablePoseKeys {
    if (_outfitHistory.isEmpty) return <String>[];
    final currentLayer = _outfitHistory[_currentOutfitIndex];
    return currentLayer.poseImages.keys.toList();
  }

  bool get canUndo => _currentOutfitIndex > 0;
  bool get canRedo => _currentOutfitIndex < _outfitHistory.length - 1;

  GeminiService _requireService() {
    final service = _geminiService;
    if (service == null) {
      throw StateError('Gemini service is not attached.');
    }
    return service;
  }

  void _setLoading(bool loading, [String message = '']) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> processModelImage(
    File userImage, {
    Map<String, String> contextHints = const <String, String>{},
  }) async {
    final service = _requireService();

    try {
      _setLoading(true, 'Processing your photo...');
      _setError(null);

      final result = await service.generateModelImage(
        GeminiModelRequest(userImage: userImage, contextHints: contextHints),
      );

      _modelImageUrl = result.imageDataUrl;
      _outfitHistory = <OutfitLayer>[
        OutfitLayer(
          garment: null,
          poseImages: <String, String>{
            PoseInstructions.instructions[0]: result.imageDataUrl,
          },
        ),
      ];
      _currentOutfitIndex = 0;
      _currentPoseIndex = 0;

      notifyListeners();
    } on GeminiFailure catch (failure) {
      _setError(failure.surface.message);
      rethrow;
    } catch (error) {
      final failure = GeminiFailure(
        code: 'model_image_error',
        message: 'Failed to process model image.',
        surface: GeminiErrorSurface(
          code: 'model_image_error',
          title: 'Try-On Failed',
          message: 'Failed to process model image.',
          explanation: error.toString(),
          actionLabel: 'Try Again',
          severity: GeminiErrorSeverity.critical,
        ),
        cause: error,
      );
      _setError(failure.surface.message);
      throw failure;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyGarment(
    File garmentFile,
    WardrobeItem garmentInfo, {
    Map<String, String> contextHints = const <String, String>{},
  }) async {
    final service = _requireService();
    final currentDisplay = displayImageUrl;

    if (currentDisplay == null) {
      throw StateError('No model image available to apply garments.');
    }

    if (_currentOutfitIndex + 1 < _outfitHistory.length) {
      final nextLayer = _outfitHistory[_currentOutfitIndex + 1];
      if (nextLayer.garment?.id == garmentInfo.id) {
        _currentOutfitIndex++;
        _currentPoseIndex = 0;
        notifyListeners();
        return;
      }
    }

    try {
      _setLoading(true, 'Adding ${garmentInfo.name}...');
      _setError(null);

      final result = await service.blendGarment(
        GeminiBlendRequest(
          modelImageDataUrl: currentDisplay,
          garmentImage: garmentFile,
          garmentName: garmentInfo.name,
          garmentId: garmentInfo.id,
          contextHints: contextHints,
        ),
      );

      final poseKey = PoseInstructions.instructions[_currentPoseIndex];
      final newLayer = OutfitLayer(
        garment: garmentInfo,
        poseImages: <String, String>{poseKey: result.imageDataUrl},
      );

      _outfitHistory = _outfitHistory.take(_currentOutfitIndex + 1).toList();
      _outfitHistory.add(newLayer);
      _currentOutfitIndex = _outfitHistory.length - 1;
      _currentPoseIndex = 0;

      if (!_wardrobe.any((item) => item.id == garmentInfo.id)) {
        _wardrobe.add(garmentInfo);
      }

      notifyListeners();
    } on GeminiFailure catch (failure) {
      _setError(failure.surface.message);
      rethrow;
    } catch (error) {
      final failure = GeminiFailure(
        code: 'garment_blend_error',
        message: 'Failed to apply garment.',
        surface: GeminiErrorSurface(
          code: 'garment_blend_error',
          title: 'Try-On Failed',
          message: 'Failed to apply garment.',
          explanation: error.toString(),
          actionLabel: 'Try Again',
          severity: GeminiErrorSeverity.critical,
        ),
        cause: error,
      );
      _setError(failure.surface.message);
      throw failure;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePose(
    int newPoseIndex, {
    Map<String, String> contextHints = const <String, String>{},
  }) async {
    if (_outfitHistory.isEmpty ||
        newPoseIndex == _currentPoseIndex ||
        _isLoading) {
      return;
    }

    final service = _requireService();
    final poseInstruction = PoseInstructions.instructions[newPoseIndex];
    final currentLayer = _outfitHistory[_currentOutfitIndex];

    if (currentLayer.poseImages.containsKey(poseInstruction)) {
      _currentPoseIndex = newPoseIndex;
      notifyListeners();
      return;
    }

    try {
      _setLoading(true, 'Changing pose...');
      _setError(null);

      final baseImageUrl = currentLayer.poseImages.values.first;
      final result = await service.generatePoseVariation(
        GeminiPoseRequest(
          baseImageDataUrl: baseImageUrl,
          poseInstruction: poseInstruction,
          contextHints: contextHints,
        ),
      );

      final updatedLayer = currentLayer.addPoseImage(
        poseInstruction,
        result.imageDataUrl,
      );
      _outfitHistory[_currentOutfitIndex] = updatedLayer;
      _currentPoseIndex = newPoseIndex;

      notifyListeners();
    } on GeminiFailure catch (failure) {
      _setError(failure.surface.message);
      rethrow;
    } catch (error) {
      final failure = GeminiFailure(
        code: 'pose_generation_error',
        message: 'Failed to change pose.',
        surface: GeminiErrorSurface(
          code: 'pose_generation_error',
          title: 'Try-On Failed',
          message: 'Failed to change pose.',
          explanation: error.toString(),
          actionLabel: 'Try Again',
          severity: GeminiErrorSeverity.critical,
        ),
        cause: error,
      );
      _setError(failure.surface.message);
      throw failure;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeGarmentColor(
    int layerIndex,
    String colorPrompt, {
    Map<String, String> contextHints = const <String, String>{},
  }) async {
    if (layerIndex >= _outfitHistory.length || _isLoading) {
      return;
    }

    final service = _requireService();
    final layer = _outfitHistory[layerIndex];
    final baseImageUrl = layer.firstImageUrl;

    if (baseImageUrl == null) {
      return;
    }

    final garmentName = layer.garment?.name ?? 'garment';

    try {
      _setLoading(true, 'Changing colour to $colorPrompt...');
      _setError(null);

      final result = await service.generateColorVariation(
        GeminiColorRequest(
          baseImageDataUrl: baseImageUrl,
          garmentName: garmentName,
          colorPrompt: colorPrompt,
          contextHints: contextHints,
        ),
      );

      final newLayer = layer.copyWith(
        poseImages: <String, String>{
          PoseInstructions.instructions[0]: result.imageDataUrl,
        },
      );

      _outfitHistory[layerIndex] = newLayer;
      _currentOutfitIndex = layerIndex;
      _currentPoseIndex = 0;

      notifyListeners();
    } on GeminiFailure catch (failure) {
      _setError(failure.surface.message);
      rethrow;
    } catch (error) {
      final failure = GeminiFailure(
        code: 'color_variation_error',
        message: 'Failed to change colour.',
        surface: GeminiErrorSurface(
          code: 'color_variation_error',
          title: 'Try-On Failed',
          message: 'Failed to change colour.',
          explanation: error.toString(),
          actionLabel: 'Try Again',
          severity: GeminiErrorSeverity.critical,
        ),
        cause: error,
      );
      _setError(failure.surface.message);
      throw failure;
    } finally {
      _setLoading(false);
    }
  }

  void undoLastGarment() {
    if (_currentOutfitIndex > 0) {
      _currentOutfitIndex--;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  void redoLastGarment() {
    if (_currentOutfitIndex < _outfitHistory.length - 1) {
      _currentOutfitIndex++;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  void jumpToLayer(int layerIndex) {
    if (layerIndex >= 0 && layerIndex < _outfitHistory.length) {
      _currentOutfitIndex = layerIndex;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  void addWardrobeItem(WardrobeItem item) {
    if (!_wardrobe.any((existing) => existing.id == item.id)) {
      _wardrobe.add(item);
      notifyListeners();
    }
  }

  void removeWardrobeItem(String itemId) {
    _wardrobe.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearWardrobe() {
    _wardrobe.clear();
    notifyListeners();
  }

  void startOver() {
    _modelImageUrl = null;
    _outfitHistory.clear();
    _currentOutfitIndex = 0;
    _currentPoseIndex = 0;
    _isLoading = false;
    _loadingMessage = '';
    _error = null;
    _wardrobe.clear();

    notifyListeners();
  }
}
