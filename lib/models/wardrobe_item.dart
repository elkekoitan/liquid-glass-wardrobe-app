import 'package:equatable/equatable.dart';

/// Availability states for wardrobe items.
enum WardrobeAvailability { available, limited, archived }

extension WardrobeAvailabilityX on WardrobeAvailability {
  static WardrobeAvailability fromKey(String? value) {
    switch (value) {
      case 'limited':
        return WardrobeAvailability.limited;
      case 'archived':
        return WardrobeAvailability.archived;
      default:
        return WardrobeAvailability.available;
    }
  }

  String get key {
    switch (this) {
      case WardrobeAvailability.limited:
        return 'limited';
      case WardrobeAvailability.archived:
        return 'archived';
      case WardrobeAvailability.available:
        return 'available';
    }
  }

  String get label {
    switch (this) {
      case WardrobeAvailability.limited:
        return 'Limited';
      case WardrobeAvailability.archived:
        return 'Archived';
      case WardrobeAvailability.available:
        return 'Available';
    }
  }

  bool get isSelectable => this != WardrobeAvailability.archived;
}

/// Personalization metadata for wardrobe items.
class WardrobePersonalization extends Equatable {
  const WardrobePersonalization({
    this.primaryCapsuleId = '',
    this.focusTags = const <String>[],
    this.supportsColorSwap = true,
    this.supportsLayering = true,
  });

  final String primaryCapsuleId;
  final List<String> focusTags;
  final bool supportsColorSwap;
  final bool supportsLayering;

  factory WardrobePersonalization.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const WardrobePersonalization();
    }

    final tags = (json['focusTags'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) => value.toString())
        .toList(growable: false);

    return WardrobePersonalization(
      primaryCapsuleId: json['primaryCapsuleId'] as String? ?? '',
      focusTags: tags,
      supportsColorSwap: json['supportsColorSwap'] as bool? ?? true,
      supportsLayering: json['supportsLayering'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'primaryCapsuleId': primaryCapsuleId,
      'focusTags': focusTags,
      'supportsColorSwap': supportsColorSwap,
      'supportsLayering': supportsLayering,
    };
  }

  WardrobePersonalization copyWith({
    String? primaryCapsuleId,
    List<String>? focusTags,
    bool? supportsColorSwap,
    bool? supportsLayering,
  }) {
    return WardrobePersonalization(
      primaryCapsuleId: primaryCapsuleId ?? this.primaryCapsuleId,
      focusTags: focusTags ?? List<String>.from(this.focusTags),
      supportsColorSwap: supportsColorSwap ?? this.supportsColorSwap,
      supportsLayering: supportsLayering ?? this.supportsLayering,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    primaryCapsuleId,
    focusTags,
    supportsColorSwap,
    supportsLayering,
  ];
}

/// Wardrobe Item model - represents a clothing item that can be tried on.
class WardrobeItem extends Equatable {
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.url,
    this.tags = const <String>[],
    this.availability = WardrobeAvailability.available,
    this.personalization = const WardrobePersonalization(),
  });

  final String id;
  final String name;
  final String url;
  final List<String> tags;
  final WardrobeAvailability availability;
  final WardrobePersonalization personalization;

  bool get isSelectable => availability.isSelectable;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) => value.toString())
        .toList(growable: false);

    return WardrobeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      tags: tags,
      availability: WardrobeAvailabilityX.fromKey(
        json['availability'] as String?,
      ),
      personalization: WardrobePersonalization.fromJson(
        json['personalization'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'tags': tags,
      'availability': availability.key,
      'personalization': personalization.toJson(),
    };
  }

  WardrobeItem copyWith({
    String? id,
    String? name,
    String? url,
    List<String>? tags,
    WardrobeAvailability? availability,
    WardrobePersonalization? personalization,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      tags: tags ?? List<String>.from(this.tags),
      availability: availability ?? this.availability,
      personalization: personalization ?? this.personalization,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    url,
    tags,
    availability,
    personalization,
  ];

  @override
  String toString() {
    return 'WardrobeItem(id: $id, tags: $tags, availability: ${availability.key})';
  }
}
