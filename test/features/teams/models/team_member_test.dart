import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/teams/models/team_member.dart';

void main() {
  group('TeamMember Model Tests', () {
    test('Should correctly parse from JSON with valid shift', () {
      final Map<String, dynamic> json = {
        'id': 'user_1',
        'name': 'João Silva',
        'email': 'joao@example.com',
        'shift': 'morning',
        'role': 'support'
      };

      final member = TeamMember.fromJson(json);

      expect(member.id, 'user_1');
      expect(member.name, 'João Silva');
      expect(member.shift, ShiftType.morning);
    });

    test('Should fallback to unknown shift when parsing invalid data', () {
      final Map<String, dynamic> json = {
        'id': 'user_2',
        'name': 'Maria Santos',
        'email': 'maria@example.com',
        'shift': 'invalid_shift',
        'role': 'support'
      };

      final member = TeamMember.fromJson(json);

      expect(member.shift, ShiftType.unknown);
    });
  });
}