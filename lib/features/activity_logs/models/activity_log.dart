/// Represents a system Activity Log entry.
class ActivityLog {
  final int id;
  final String description;
  final String event;
  final String? causer;
  final String? subjectType;
  final Map<String, dynamic> properties;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.description,
    required this.event,
    this.causer,
    this.subjectType,
    required this.properties,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Attempt to extract the causer's name securely
    String? causerName;
    if (json['causer'] != null && json['causer'] is Map) {
      causerName = json['causer']['name']?.toString();
    }

    return ActivityLog(
      id: int.parse(json['id'].toString()),
      description: json['description']?.toString() ?? 'Unknown',
      event: json['event']?.toString() ?? 'unknown',
      causer: causerName,
      subjectType: json['subject_type']?.toString().split('\\').last, // Cleans up 'App\Models\Ticket' to 'Ticket'
      properties: json['properties'] is Map ? json['properties'] as Map<String, dynamic> : {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}