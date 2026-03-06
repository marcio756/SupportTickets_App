/// Represents a work session for a user, tracking their time and status.
class WorkSession {
  final int id;
  final int userId;
  final String status; // e.g., 'active', 'paused', 'completed'
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalDurationSeconds;

  /// Creates a new WorkSession instance.
  ///
  /// @param id The unique identifier of the work session.
  /// @param userId The ID of the user who owns this session.
  /// @param status The current status of the session.
  /// @param startedAt The timestamp when the session started.
  /// @param endedAt The optional timestamp when the session ended.
  /// @param totalDurationSeconds The total duration worked in seconds.
  const WorkSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.totalDurationSeconds,
  });

  /// Factory constructor to create a WorkSession from a JSON map.
  ///
  /// @param json The JSON map representing the work session data.
  /// @return A WorkSession instance.
  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
      totalDurationSeconds: json['total_duration_seconds'] as int? ?? 0,
    );
  }

  /// Converts the WorkSession instance into a JSON map.
  ///
  /// @return A map containing the serialized work session data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'total_duration_seconds': totalDurationSeconds,
    };
  }
}