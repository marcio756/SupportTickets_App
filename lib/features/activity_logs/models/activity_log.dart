import 'dart:convert';

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

  /// Factory constructor to create an ActivityLog from a JSON map.
  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Attempt to extract the causer's name securely
    String? causerName;
    if (json['causer'] != null && json['causer'] is Map) {
      causerName = json['causer']['name']?.toString();
    } else if (json['causer_id'] != null) {
      causerName = 'Utilizador #${json['causer_id']}';
    }

    final int parsedId = int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    // Garante a extração correta do objeto JSON Properties do Spatie ActivityLog
    Map<String, dynamic> parsedProperties = {};
    if (json['properties'] is Map) {
      parsedProperties = Map<String, dynamic>.from(json['properties'] as Map);
    } else if (json['properties'] is String && json['properties'].toString().trim().isNotEmpty) {
      try {
        parsedProperties = jsonDecode(json['properties'].toString()) as Map<String, dynamic>;
      } catch (_) {
        parsedProperties = {'raw': json['properties']};
      }
    }

    DateTime parsedDate = DateTime.now();
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    // Limpa a string da classe do Laravel de forma segura (ex: "App\Models\Ticket" para "Ticket")
    String? type = json['subject_type']?.toString();
    if (type != null && type.contains('\\')) {
      type = type.split('\\').last;
    }

    // O Spatie por vezes guarda o evento no log_name
    String ev = json['event']?.toString() ?? json['log_name']?.toString() ?? 'unknown';

    return ActivityLog(
      id: parsedId,
      description: json['description']?.toString() ?? 'Unknown',
      event: ev,
      causer: causerName,
      subjectType: type,
      properties: parsedProperties,
      createdAt: parsedDate,
    );
  }
}