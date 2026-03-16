enum VacationStatus { pending, approved, rejected }

/// Represents the data structure for a user's vacation request.
/// Handles resilient JSON parsing to prevent type casting errors between Int and String.
class VacationRequest {
  final String? id;
  final String userId;
  final String teamId;
  final DateTime startDate;
  final DateTime endDate;
  final VacationStatus status;
  final int totalDays;
  final String? reason;

  VacationRequest({
    this.id,
    required this.userId,
    required this.teamId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalDays,
    this.reason,
  });

  factory VacationRequest.fromJson(Map<String, dynamic> json) {
    VacationStatus parsedStatus = VacationStatus.pending;
    if (json['status'] != null) {
      final statusStr = json['status'].toString().toLowerCase();
      if (statusStr == 'approved') {
        parsedStatus = VacationStatus.approved;
      } else if (statusStr == 'rejected') {
        parsedStatus = VacationStatus.rejected;
      }
    }

    return VacationRequest(
      id: json['id']?.toString(), 
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '', 
      teamId: json['team_id']?.toString() ?? json['teamId']?.toString() ?? '', 
      startDate: json['start_date'] != null 
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: parsedStatus,
      totalDays: json['total_days'] != null 
          ? int.tryParse(json['total_days'].toString()) ?? 0 
          : 0,
      reason: json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'team_id': teamId,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': status.name,
      'total_days': totalDays,
      if (reason != null) 'reason': reason,
    };
  }
}