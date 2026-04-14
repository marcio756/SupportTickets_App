// Ficheiro: lib/features/users/models/user_model.dart
/// Represents a system user (Customer, Supporter, or Admin).
/// Kept lightweight to hold only necessary data for management views.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.deletedAt,
  });

  /// Factory constructor to safely map Laravel JSON responses to the Dart object.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'].toString()) : null,
    );
  }

  /// Converts the model back to JSON, useful for caching or specific API mutations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}