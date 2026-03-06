import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';
import 'package:supporttickets_app/features/work_sessions/repositories/work_session_repository.dart';

// Gerar o mock da ApiClient corretamente para evitar erros de Null Safety
@GenerateMocks([ApiClient])
import 'work_session_repository_test.mocks.dart';

void main() {
  late WorkSessionRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = WorkSessionRepository(apiClient: mockApiClient);
  });

  group('WorkSessionRepository', () {
    final mockSessionJson = {
      'id': 1,
      'user_id': 2,
      'status': 'active',
      'started_at': '2026-03-06T09:00:00.000000Z',
      'ended_at': null,
      'total_duration_seconds': 3600,
    };

    test('getCurrentSession returns a WorkSession when API call is successful', () async {
      when(mockApiClient.get('/work-sessions/current', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => {'data': mockSessionJson});

      final result = await repository.getCurrentSession();

      expect(result, isA<WorkSession>());
      expect(result?.id, equals(1));
    });

    test('getCurrentSession returns null when there is no active session', () async {
      when(mockApiClient.get('/work-sessions/current', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => {'data': null});

      final result = await repository.getCurrentSession();
      expect(result, isNull);
    });

    test('startSession calls the correct endpoint and returns the new session', () async {
      when(mockApiClient.post('/work-sessions/start', data: anyNamed('data')))
          .thenAnswer((_) async => {'data': mockSessionJson});

      final result = await repository.startSession();
      expect(result.id, equals(1));
    });

    test('pauseSession calls the correct endpoint and returns the updated session', () async {
      final pausedJson = Map<String, dynamic>.from(mockSessionJson)..['status'] = 'paused';
      when(mockApiClient.post('/work-sessions/pause', data: anyNamed('data')))
          .thenAnswer((_) async => {'data': pausedJson});

      final result = await repository.pauseSession();
      expect(result.status, equals('paused'));
    });

    test('resumeSession calls the correct endpoint and returns the updated session', () async {
      when(mockApiClient.post('/work-sessions/resume', data: anyNamed('data')))
          .thenAnswer((_) async => {'data': mockSessionJson});

      final result = await repository.resumeSession();
      expect(result.status, equals('active'));
    });

    test('endSession calls the correct endpoint and returns the completed session', () async {
      final endedJson = Map<String, dynamic>.from(mockSessionJson)
        ..['status'] = 'completed'
        ..['ended_at'] = '2026-03-06T10:00:00.000000Z';
        
      when(mockApiClient.post('/work-sessions/end', data: anyNamed('data')))
          .thenAnswer((_) async => {'data': endedJson});

      final result = await repository.endSession();
      expect(result.status, equals('completed'));
    });
  });
}