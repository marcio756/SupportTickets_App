import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';

void main() {
  group('VacationRepository Tests', () {
    test('Should throw an exception when API response is not 200 on fetch', () async {
      // Utilizing the official MockClient from the http package for robust network testing
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repository = VacationRepository(client: mockClient);

      expect(() => repository.fetchVacations('user_1'), throwsException);
    });
  });
}