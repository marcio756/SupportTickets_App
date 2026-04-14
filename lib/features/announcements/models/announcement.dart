// Ficheiro: lib/features/announcements/models/announcement.dart
/// Represents a global system announcement and email record.
class Announcement {
  final int id;
  final String subject;
  final String message;
  final String targetAudience; 
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.subject,
    required this.message,
    required this.targetAudience,
    required this.createdAt,
  });

  /// Factory constructor to safely map Laravel JSON responses.
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetAudience: json['target_audience'] as String? ?? 'all_customers',
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'target_audience': targetAudience,
      'created_at': createdAt.toIso8601String(),
    };
  }
}