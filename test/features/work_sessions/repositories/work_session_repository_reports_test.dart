import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/work_sessions/repositories/work_session_repository.dart';

@GenerateMocks([ApiClient])
import 'work_session_repository_reports_test.mocks.dart';

void main() {
  late WorkSessionRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = WorkSessionRepository(apiClient: mockApiClient);
  });

  group('WorkSessionRepository - Reports', () {
    test('getReports constructs correct query parameters and returns data', () async {
      // Arrange
      final mockResponse = {
        'data': {
          'sessions': {'data': []},
          'summary': {'total_hours': 8, 'total_minutes': 30}
        }
      };
      
      when(mockApiClient.get('/work-sessions/reports', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getReports(page: 2, userId: '10', date: '2026-03-06');

      // Assert
      expect(result['summary']['total_hours'], equals(8));
      verify(mockApiClient.get(
        '/work-sessions/reports',
        queryParameters: {'page': '2', 'user_id': '10', 'date': '2026-03-06'},
      )).called(1);
    });
  });
}