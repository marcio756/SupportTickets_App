import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';
import 'package:supporttickets_app/features/work_sessions/repositories/work_session_repository.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_viewmodel.dart';

@GenerateMocks([WorkSessionRepository])
import 'work_session_viewmodel_test.mocks.dart';

void main() {
  late WorkSessionViewModel viewModel;
  late MockWorkSessionRepository mockRepository;

  final dummySession = WorkSession(
    id: 1, userId: 2, status: 'active', startedAt: DateTime.now(), totalDurationSeconds: 100,
  );

  setUp(() {
    mockRepository = MockWorkSessionRepository();
    viewModel = WorkSessionViewModel(repository: mockRepository);
  });

  group('WorkSessionViewModel', () {
    test('pauseSession updates status to paused and keeps time safely', () async {
      final pausedSession = WorkSession(
        id: 1, userId: 2, status: 'paused', startedAt: dummySession.startedAt, totalDurationSeconds: 0, // Simulando API a enviar 0
      );

      viewModel.currentSession = dummySession; // Timer local já vai a 100s
      when(mockRepository.pauseSession()).thenAnswer((_) async => pausedSession);

      await viewModel.pauseSession();

      expect(viewModel.isPaused, isTrue);
      // Deve ignorar o 0 da API e manter o tempo anterior para o utilizador não ver o tempo a zerar
      expect(viewModel.currentDurationSeconds, greaterThanOrEqualTo(100)); 
    });

    test('endSession updates status to completed and retains session data', () async {
      final endedSession = WorkSession(
        id: 1, userId: 2, status: 'completed', startedAt: dummySession.startedAt, endedAt: DateTime.now(), totalDurationSeconds: 200,
      );

      when(mockRepository.endSession()).thenAnswer((_) async => endedSession);

      viewModel.currentSession = dummySession;
      await viewModel.endSession();

      expect(viewModel.isCompleted, isTrue);
      expect(viewModel.currentDurationSeconds, equals(200));
    });
  });
}