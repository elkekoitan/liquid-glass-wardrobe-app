import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/gemini_service.dart';

/// Main state provider for FitCheck app
/// Manages outfit history, wardrobe items, loading states, and AI operations

class FitCheckProvider extends ChangeNotifier {
  // Core state
  String? _modelImageUrl;
  List<OutfitLayer> _outfitHistory = [];
  int _currentOutfitIndex = 0;
  final List<WardrobeItem> _wardrobe = [];

  // UI state
  bool _isLoading = false;
  String _loadingMessage = '';
  String? _error;
  int _currentPoseIndex = 0;

  // Services
  GeminiService? _geminiService;

  // Getters
  String? get modelImageUrl => _modelImageUrl;
  List<OutfitLayer> get outfitHistory => List.unmodifiable(_outfitHistory);
  int get currentOutfitIndex => _currentOutfitIndex;
  List<WardrobeItem> get wardrobe => List.unmodifiable(_wardrobe);
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;
  String? get error => _error;
  int get currentPoseIndex => _currentPoseIndex;

  // Computed getters
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
    if (_outfitHistory.isEmpty) return [];

    final currentLayer = _outfitHistory[_currentOutfitIndex];
    return currentLayer.poseImages.keys.toList();
  }

  bool get canUndo => _currentOutfitIndex > 0;
  bool get canRedo => _currentOutfitIndex < _outfitHistory.length - 1;

  /// Initialize Gemini service with API key
  void initializeGeminiService(String apiKey) {
    _geminiService = GeminiService(apiKey: apiKey);
  }

  /// Set loading state
  void _setLoading(bool loading, [String message = '']) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Process user image to create model photo
  Future<void> processModelImage(File userImage) async {
    if (_geminiService == null) {
      throw Exception('Gemini service not initialized');
    }

    try {
      _setLoading(true, 'Processing your photo...');
      _setError(null);

      final modelImageUrl = await _geminiService!.generateModelImage(userImage);

      _modelImageUrl = modelImageUrl;
      _outfitHistory = [
        OutfitLayer(
          garment: null,
          poseImages: {PoseInstructions.instructions[0]: modelImageUrl},
        ),
      ];
      _currentOutfitIndex = 0;
      _currentPoseIndex = 0;

      notifyListeners();
    } catch (e) {
      _setError('Failed to process model image: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Apply garment to current model
  Future<void> applyGarment(File garmentFile, WardrobeItem garmentInfo) async {
    if (_geminiService == null || displayImageUrl == null) {
      throw Exception('Service not initialized or no model image available');
    }

    try {
      // Check if this garment is already the next layer
      if (_currentOutfitIndex + 1 < _outfitHistory.length) {
        final nextLayer = _outfitHistory[_currentOutfitIndex + 1];
        if (nextLayer.garment?.id == garmentInfo.id) {
          _currentOutfitIndex++;
          _currentPoseIndex = 0;
          notifyListeners();
          return;
        }
      }

      _setLoading(true, 'Adding ${garmentInfo.name}...');
      _setError(null);

      final newImageUrl = await _geminiService!.generateVirtualTryOnImage(
        displayImageUrl!,
        garmentFile,
      );

      final currentPoseInstruction =
          PoseInstructions.instructions[_currentPoseIndex];
      final newLayer = OutfitLayer(
        garment: garmentInfo,
        poseImages: {currentPoseInstruction: newImageUrl},
      );

      // Remove any layers after current index and add new layer
      _outfitHistory = _outfitHistory.take(_currentOutfitIndex + 1).toList();
      _outfitHistory.add(newLayer);
      _currentOutfitIndex++;

      // Add to wardrobe if not already there
      if (!_wardrobe.any((item) => item.id == garmentInfo.id)) {
        _wardrobe.add(garmentInfo);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to apply garment: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Change pose of current outfit
  Future<void> changePose(int newPoseIndex) async {
    if (_geminiService == null ||
        _outfitHistory.isEmpty ||
        newPoseIndex == _currentPoseIndex ||
        _isLoading) {
      return;
    }

    final poseInstruction = PoseInstructions.instructions[newPoseIndex];
    final currentLayer = _outfitHistory[_currentOutfitIndex];

    // If pose already exists, just switch to it
    if (currentLayer.poseImages.containsKey(poseInstruction)) {
      _currentPoseIndex = newPoseIndex;
      notifyListeners();
      return;
    }

    try {
      _setLoading(true, 'Changing pose...');
      _setError(null);

      final baseImageUrl = currentLayer.poseImages.values.first;
      final newImageUrl = await _geminiService!.generatePoseVariation(
        baseImageUrl,
        poseInstruction,
      );

      // Update the layer with the new pose image
      final updatedLayer = currentLayer.addPoseImage(
        poseInstruction,
        newImageUrl,
      );
      _outfitHistory[_currentOutfitIndex] = updatedLayer;
      _currentPoseIndex = newPoseIndex;

      notifyListeners();
    } catch (e) {
      _setError('Failed to change pose: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Change color of garment in specific layer
  Future<void> changeGarmentColor(int layerIndex, String colorPrompt) async {
    if (_geminiService == null ||
        layerIndex >= _outfitHistory.length ||
        _isLoading) {
      return;
    }

    final layer = _outfitHistory[layerIndex];
    final garmentName = layer.garment?.name ?? 'garment';

    try {
      _setLoading(true, 'Changing color to $colorPrompt...');
      _setError(null);

      final baseImageUrl = layer.firstImageUrl!;
      final newImageUrl = await _geminiService!.generateColorVariation(
        baseImageUrl,
        garmentName,
        colorPrompt,
      );

      // Create new layer with color variation
      final newLayer = layer.copyWith(
        poseImages: {PoseInstructions.instructions[0]: newImageUrl},
      );

      // Replace the layer and move to it
      _outfitHistory[layerIndex] = newLayer;
      _currentOutfitIndex = layerIndex;
      _currentPoseIndex = 0;

      notifyListeners();
    } catch (e) {
      _setError('Failed to change color: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Undo to previous outfit layer
  void undoLastGarment() {
    if (_currentOutfitIndex > 0) {
      _currentOutfitIndex--;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  /// Redo to next outfit layer
  void redoLastGarment() {
    if (_currentOutfitIndex < _outfitHistory.length - 1) {
      _currentOutfitIndex++;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  /// Jump to specific outfit layer
  void jumpToLayer(int layerIndex) {
    if (layerIndex >= 0 && layerIndex < _outfitHistory.length) {
      _currentOutfitIndex = layerIndex;
      _currentPoseIndex = 0;
      notifyListeners();
    }
  }

  /// Add wardrobe item
  void addWardrobeItem(WardrobeItem item) {
    if (!_wardrobe.any((existing) => existing.id == item.id)) {
      _wardrobe.add(item);
      notifyListeners();
    }
  }

  /// Remove wardrobe item
  void removeWardrobeItem(String itemId) {
    _wardrobe.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clear all wardrobe items
  void clearWardrobe() {
    _wardrobe.clear();
    notifyListeners();
  }

  /// Start over - reset all state
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

  /// Get friendly error message
}
