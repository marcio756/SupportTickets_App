/// Represents the possible states of a vacation request within the approval pipeline.
enum VacationStatus { pending, approved, rejected }

/// Domain model representing a user's vacation request.
/// Ensures strict type safety when moving data between the API layer and the UI.
class VacationRequest {
  final String? id;
  final String userId;
  final String teamId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final VacationStatus status;

  VacationRequest({
    this.id,
    required this.userId,
    required this.teamId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
  });

  factory VacationRequest.fromJson(Map<String, dynamic> json) {
    return VacationRequest(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      teamId: json['teamId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      status: _parseStatus(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'teamId': teamId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'status': status.name,
    };
  }

  static VacationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return VacationStatus.approved;
      case 'rejected':
        return VacationStatus.rejected;
      case 'pending':
      default:
        return VacationStatus.pending;
    }
  }
}