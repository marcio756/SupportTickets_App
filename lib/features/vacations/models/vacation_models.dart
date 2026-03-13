/// Represents an individual vacation booking request.
/// Contains the exact dates, duration, and approval state of the request.
class Vacation {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String status;

  Vacation({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
  });

  factory Vacation.fromJson(Map<String, dynamic> json) {
    return Vacation(
      id: json['id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalDays: json['total_days'] as int,
      status: json['status'] as String,
    );
  }
}

/// Summarizes the vacation quota and usage for a specific user in a given year.
/// Used to determine how many days the user can still book.
class VacationSummary {
  final int totalAllowed;
  final int usedDays;
  final int remainingDays;
  final int year;

  VacationSummary({
    required this.totalAllowed,
    required this.usedDays,
    required this.remainingDays,
    required this.year,
  });

  factory VacationSummary.fromJson(Map<String, dynamic> json) {
    return VacationSummary(
      totalAllowed: json['total_allowed'] as int,
      usedDays: json['used_days'] as int,
      remainingDays: json['remaining_days'] as int,
      year: json['year'] as int,
    );
  }
}

/// Represents a user within the context of the vacation calendar.
/// Aggregates their personal summary and their list of booked vacations.
class VacationMember {
  final int id;
  final String name;
  final VacationSummary summary;
  final List<Vacation> vacations;

  VacationMember({
    required this.id,
    required this.name,
    required this.summary,
    required this.vacations,
  });

  factory VacationMember.fromJson(Map<String, dynamic> json) {
    return VacationMember(
      id: json['id'] as int,
      name: json['name'] as String,
      summary: VacationSummary.fromJson(json['vacation_summary'] as Map<String, dynamic>),
      vacations: (json['vacations'] as List<dynamic>)
          .map((v) => Vacation.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a team grouping in the calendar view.
/// Useful for filtering and displaying conflicts within the same shift.
class VacationTeam {
  final int id;
  final String name;
  final String shift;
  final List<VacationMember> members;

  VacationTeam({
    required this.id,
    required this.name,
    required this.shift,
    required this.members,
  });

  factory VacationTeam.fromJson(Map<String, dynamic> json) {
    return VacationTeam(
      id: json['id'] as int,
      name: json['name'] as String,
      shift: json['shift'] as String,
      members: (json['members'] as List<dynamic>)
          .map((m) => VacationMember.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}