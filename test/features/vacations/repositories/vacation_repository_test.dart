import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';

@GenerateMocks([ApiClient])
import 'vacation_repository_test.mocks.dart';

void main() {
  late VacationRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = VacationRepository(apiClient: mockApiClient);
  });

  group('VacationRepository', () {
    test('getCalendarData successfully parses the hierarchical JSON response', () async {
      final int targetYear = 2026;
      final mockJsonResponse = {
        'data': {
          'teams': [
            {
              'id': 1,
              'name': 'Frontend Squad',
              'shift': 'morning',
              'members': [
                {
                  'id': 14,
                  'name': 'Jane Doe',
                  'vacation_summary': {
                    'total_allowed': 22,
                    'used_days': 5,
                    'remaining_days': 17,
                    'year': 2026
                  },
                  'vacations': [
                    {
                      'id': 105,
                      'start_date': '2026-08-10',
                      'end_date': '2026-08-14',
                      'total_days': 5,
                      'status': 'approved'
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      when(mockApiClient.get('/api/vacations/calendar', queryParameters: {'year': targetYear}))
          .thenAnswer((_) async => mockJsonResponse);

      final result = await repository.getCalendarData(year: targetYear);

      expect(result, isA<List<VacationTeam>>());
      expect(result.length, 1);
      verify(mockApiClient.get('/api/vacations/calendar', queryParameters: {'year': targetYear})).called(1);
    });

    test('bookVacation sends correct payload and returns a Vacation object', () async {
      final startDate = DateTime(2026, 10, 1);
      final endDate = DateTime(2026, 10, 10);
      
      final mockResponse = {
        'data': {
          'id': 201,
          'start_date': '2026-10-01',
          'end_date': '2026-10-10',
          'total_days': 8,
          'status': 'pending'
        }
      };

      when(mockApiClient.post('/api/vacations', data: {
        'start_date': '2026-10-01',
        'end_date': '2026-10-10',
      })).thenAnswer((_) async => mockResponse);

      final result = await repository.bookVacation(startDate: startDate, endDate: endDate);

      expect(result.id, 201);
      expect(result.status, 'pending');
      expect(result.totalDays, 8);
    });
  });
}