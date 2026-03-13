import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supporttickets_app/features/teams/repositories/team_repository.dart';

void main() {
  group('TeamRepository Tests', () {
    test('Should throw exception when fetching team members fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = TeamRepository(client: mockClient);

      expect(() => repository.fetchTeamMembers('team_1'), throwsException);
    });
  });
}