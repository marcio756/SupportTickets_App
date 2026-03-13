import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_request.dart';

void main() {
  group('VacationRequest Model Tests', () {
    test('Should correctly parse from JSON', () {
      final Map<String, dynamic> json = {
        'id': '123',
        'userId': 'user_1',
        'teamId': 'team_1',
        'startDate': '2026-07-01T00:00:00Z',
        'endDate': '2026-07-15T00:00:00Z',
        'totalDays': 15,
        'status': 'approved',
      };

      final vacation = VacationRequest.fromJson(json);

      expect(vacation.id, '123');
      expect(vacation.userId, 'user_1');
      expect(vacation.totalDays, 15);
      expect(vacation.status, VacationStatus.approved);
    });

    test('Should correctly serialize to JSON', () {
      final vacation = VacationRequest(
        id: '123',
        userId: 'user_1',
        teamId: 'team_1',
        startDate: DateTime.utc(2026, 7, 1),
        endDate: DateTime.utc(2026, 7, 15),
        totalDays: 15,
        status: VacationStatus.pending,
      );

      final json = vacation.toJson();

      expect(json['userId'], 'user_1');
      expect(json['status'], 'pending');
      expect(json['totalDays'], 15);
    });
  });
}