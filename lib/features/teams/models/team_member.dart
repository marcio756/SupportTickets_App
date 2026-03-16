/// Represents the working shift assigned to a team member.
enum ShiftType { morning, afternoon, night, unknown }

/// Represents a user assigned to a specific support team.
class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final ShiftType shift;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shift = ShiftType.unknown,
  });

  /// Factory constructor to create a TeamMember instance from a JSON map.
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    ShiftType parsedShift = ShiftType.unknown;

    if (json['shift'] != null) {
      final shiftStr = json['shift'].toString().toLowerCase();
      if (shiftStr == 'morning') {
        parsedShift = ShiftType.morning;
      } else if (shiftStr == 'afternoon') {
        parsedShift = ShiftType.afternoon;
      } else if (shiftStr == 'night') {
        parsedShift = ShiftType.night;
      }
    }

    return TeamMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'supporter',
      shift: parsedShift,
    );
  }
}