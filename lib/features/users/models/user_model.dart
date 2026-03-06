/// Represents a system user (Customer, Supporter, or Admin).
/// Kept lightweight to hold only necessary data for management views.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Factory constructor to safely map Laravel JSON responses to the Dart object.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
    );
  }

  /// Converts the model back to JSON, useful for caching or specific API mutations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}