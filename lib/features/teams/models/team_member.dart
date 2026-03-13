/// Defines the working shifts available in the system.
/// Kept as an enum to guarantee type safety across the UI when rendering shift indicators.
enum ShiftType { morning, afternoon, night, unknown }

/// Domain model representing a colleague within the same operational team.
class TeamMember {
  final String id;
  final String name;
  final String email;
  final ShiftType shift;
  final String role;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.shift,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      shift: _parseShift(json['shift'] as String?),
      role: json['role'] as String,
    );
  }

  static ShiftType _parseShift(String? shift) {
    switch (shift?.toLowerCase()) {
      case 'morning':
        return ShiftType.morning;
      case 'afternoon':
        return ShiftType.afternoon;
      case 'night':
        return ShiftType.night;
      default:
        return ShiftType.unknown;
    }
  }
}