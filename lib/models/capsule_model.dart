import 'package:equatable/equatable.dart';

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

  bool get isSeasonal => type == 'seasonal';
  bool get isWeekly => type == 'weekly';
  bool get isSpecial => type == 'special';

  factory CapsuleModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? input) {
      if (input == null || input.isEmpty) return null;
      return DateTime.tryParse(input);
    }

    final colorList = (map['colorway'] as List<dynamic>? ?? <dynamic>[])
        .map((color) => color.toString())
        .toList(growable: false);

    final tagList = (map['tags'] as List<dynamic>? ?? <dynamic>[])
        .map((tag) => tag.toString())
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
  ];
}
