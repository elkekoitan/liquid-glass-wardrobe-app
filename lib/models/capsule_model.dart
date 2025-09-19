import 'package:equatable/equatable.dart';

/// Capsule availability state for roadmap sequencing.
enum CapsuleAvailability { live, scheduled, archived }

extension CapsuleAvailabilityX on CapsuleAvailability {
  static CapsuleAvailability fromKey(String? value) {
    switch (value) {
      case 'scheduled':
        return CapsuleAvailability.scheduled;
      case 'archived':
        return CapsuleAvailability.archived;
      default:
        return CapsuleAvailability.live;
    }
  }

  String get key {
    switch (this) {
      case CapsuleAvailability.scheduled:
        return 'scheduled';
      case CapsuleAvailability.archived:
        return 'archived';
      case CapsuleAvailability.live:
        return 'live';
    }
  }

  String get label {
    switch (this) {
      case CapsuleAvailability.live:
        return 'Live';
      case CapsuleAvailability.scheduled:
        return 'Scheduled';
      case CapsuleAvailability.archived:
        return 'Archived';
    }
  }

  bool get isSelectable => this == CapsuleAvailability.live;
}

class CapsulePersonalization extends Equatable {
  const CapsulePersonalization({
    this.primaryIntent = '',
    this.supportsReducedMotion = false,
    this.supportsHighContrast = false,
    this.recommendedWardrobeIds = const <String>[],
  });

  final String primaryIntent;
  final bool supportsReducedMotion;
  final bool supportsHighContrast;
  final List<String> recommendedWardrobeIds;

  factory CapsulePersonalization.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CapsulePersonalization();
    }

    final ids =
        (map['recommendedWardrobeIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(growable: false);

    return CapsulePersonalization(
      primaryIntent: map['primaryIntent'] as String? ?? '',
      supportsReducedMotion: map['supportsReducedMotion'] as bool? ?? false,
      supportsHighContrast: map['supportsHighContrast'] as bool? ?? false,
      recommendedWardrobeIds: ids,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'primaryIntent': primaryIntent,
      'supportsReducedMotion': supportsReducedMotion,
      'supportsHighContrast': supportsHighContrast,
      'recommendedWardrobeIds': recommendedWardrobeIds,
    };
  }

  CapsulePersonalization copyWith({
    String? primaryIntent,
    bool? supportsReducedMotion,
    bool? supportsHighContrast,
    List<String>? recommendedWardrobeIds,
  }) {
    return CapsulePersonalization(
      primaryIntent: primaryIntent ?? this.primaryIntent,
      supportsReducedMotion:
          supportsReducedMotion ?? this.supportsReducedMotion,
      supportsHighContrast: supportsHighContrast ?? this.supportsHighContrast,
      recommendedWardrobeIds:
          recommendedWardrobeIds ??
          List<String>.from(this.recommendedWardrobeIds),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    primaryIntent,
    supportsReducedMotion,
    supportsHighContrast,
    recommendedWardrobeIds,
  ];
}

class CapsuleMicrocopy extends Equatable {
  const CapsuleMicrocopy({
    required this.prompt,
    required this.success,
    required this.error,
  });

  final String prompt;
  final String success;
  final String error;

  factory CapsuleMicrocopy.fromMap(Map<String, dynamic> map) {
    return CapsuleMicrocopy(
      prompt: map['prompt'] as String? ?? '',
      success: map['success'] as String? ?? '',
      error: map['error'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'prompt': prompt, 'success': success, 'error': error};
  }

  @override
  List<Object?> get props => [prompt, success, error];
}

class CapsuleModel extends Equatable {
  const CapsuleModel({
    required this.id,
    required this.name,
    required this.mood,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.colorway,
    required this.signatureDetail,
    required this.heroImage,
    required this.accessibilityVariant,
    required this.tags,
    required this.microcopy,
    this.availability = CapsuleAvailability.live,
    this.personalization = const CapsulePersonalization(),
    this.wardrobeItemIds = const <String>[],
  });

  final String id;
  final String name;
  final String mood;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String description;
  final List<String> colorway;
  final String signatureDetail;
  final String heroImage;
  final String accessibilityVariant;
  final List<String> tags;
  final CapsuleMicrocopy microcopy;
  final CapsuleAvailability availability;
  final CapsulePersonalization personalization;
  final List<String> wardrobeItemIds;

  bool get isSeasonal => type == 'seasonal';
  bool get isWeekly => type == 'weekly';
  bool get isSpecial => type == 'special';
  bool get isSelectable => availability.isSelectable;

  factory CapsuleModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? input) {
      if (input == null || input.isEmpty) return null;
      return DateTime.tryParse(input);
    }

    final colorList = (map['colorway'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic color) => color.toString())
        .toList(growable: false);

    final tagList = (map['tags'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic tag) => tag.toString())
        .toList(growable: false);

    final wardrobeList =
        (map['wardrobeItemIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(growable: false);

    return CapsuleModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      type: map['type'] as String? ?? 'weekly',
      startDate: parseDate(map['startDate'] as String?),
      endDate: parseDate(map['endDate'] as String?),
      description: map['description'] as String? ?? '',
      colorway: colorList,
      signatureDetail: map['signatureDetail'] as String? ?? '',
      heroImage: map['heroImage'] as String? ?? '',
      accessibilityVariant: map['accessibilityVariant'] as String? ?? '',
      tags: tagList,
      microcopy: CapsuleMicrocopy.fromMap(
        (map['microcopy'] as Map<String, dynamic>? ?? const {}),
      ),
      availability: CapsuleAvailabilityX.fromKey(
        map['availability'] as String?,
      ),
      personalization: CapsulePersonalization.fromMap(
        map['personalization'] as Map<String, dynamic>?,
      ),
      wardrobeItemIds: wardrobeList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mood': mood,
      'type': type,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'colorway': colorway,
      'signatureDetail': signatureDetail,
      'heroImage': heroImage,
      'accessibilityVariant': accessibilityVariant,
      'tags': tags,
      'microcopy': microcopy.toMap(),
      'availability': availability.key,
      'personalization': personalization.toMap(),
      'wardrobeItemIds': wardrobeItemIds,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    mood,
    type,
    startDate,
    endDate,
    description,
    colorway,
    signatureDetail,
    heroImage,
    accessibilityVariant,
    tags,
    microcopy,
    availability,
    personalization,
    wardrobeItemIds,
  ];
}
