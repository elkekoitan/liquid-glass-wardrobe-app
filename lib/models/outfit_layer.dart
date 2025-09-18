import 'wardrobe_item.dart';

/// Outfit Layer model - represents a layer in the outfit history
/// Contains garment info and pose variations for that garment
/// Converted from TypeScript interface to Dart class

class OutfitLayer {
  final WardrobeItem? garment; // null represents the base model layer
  final Map<String, String> poseImages; // Maps pose instruction to image URL

  const OutfitLayer({this.garment, required this.poseImages});

  /// Create OutfitLayer from JSON
  factory OutfitLayer.fromJson(Map<String, dynamic> json) {
    final garmentJson = json['garment'];
    return OutfitLayer(
      garment: garmentJson != null
          ? WardrobeItem.fromJson(garmentJson as Map<String, dynamic>)
          : null,
      poseImages: Map<String, String>.from(json['poseImages'] as Map),
    );
  }

  /// Convert OutfitLayer to JSON
  Map<String, dynamic> toJson() {
    return {'garment': garment?.toJson(), 'poseImages': poseImages};
  }

  /// Create a copy of this layer with modified properties
  OutfitLayer copyWith({
    WardrobeItem? garment,
    Map<String, String>? poseImages,
  }) {
    return OutfitLayer(
      garment: garment ?? this.garment,
      poseImages: poseImages ?? Map.from(this.poseImages),
    );
  }

  /// Add a new pose image to this layer
  OutfitLayer addPoseImage(String pose, String imageUrl) {
    final newPoseImages = Map<String, String>.from(poseImages);
    newPoseImages[pose] = imageUrl;
    return copyWith(poseImages: newPoseImages);
  }

  /// Get the first available pose image URL
  String? get firstImageUrl {
    if (poseImages.isEmpty) return null;
    return poseImages.values.first;
  }

  /// Get available pose keys
  List<String> get availablePoses => poseImages.keys.toList();

  /// Check if this is the base model layer (no garment)
  bool get isBaseLayer => garment == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OutfitLayer &&
        other.garment == garment &&
        _mapEquals(other.poseImages, poseImages);
  }

  @override
  int get hashCode => garment.hashCode ^ poseImages.hashCode;

  @override
  String toString() {
    return 'OutfitLayer(garment: $garment, poseImages: ${poseImages.keys.toList()})';
  }

  /// Helper method to compare maps
  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
