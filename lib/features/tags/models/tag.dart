/// Represents a system Tag domain model.
class Tag {
  final int id;
  final String name;
  final String? color;

  Tag({
    required this.id,
    required this.name,
    this.color,
  });

  /// Factory constructor to create a Tag from a JSON map.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? 'Unknown Tag',
      color: json['color']?.toString(),
    );
  }

  /// Converts the Tag instance back to a Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}