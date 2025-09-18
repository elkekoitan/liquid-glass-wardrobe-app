/// Wardrobe Item model - represents a clothing item that can be tried on
/// Converted from TypeScript interface to Dart class
library;

class WardrobeItem {
  final String id;
  final String name;
  final String url;

  const WardrobeItem({required this.id, required this.name, required this.url});

  /// Create WardrobeItem from JSON
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Convert WardrobeItem to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'url': url};
  }

  /// Create a copy of this item with modified properties
  WardrobeItem copyWith({String? id, String? name, String? url}) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WardrobeItem &&
        other.id == id &&
        other.name == name &&
        other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ url.hashCode;

  @override
  String toString() {
    return 'WardrobeItem(id: $id, name: $name, url: $url)';
  }
}
