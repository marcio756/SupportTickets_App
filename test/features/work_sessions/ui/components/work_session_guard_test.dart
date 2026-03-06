import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_viewmodel.dart';
import 'package:supporttickets_app/features/work_sessions/ui/components/work_session_guard.dart';

@GenerateMocks([ProfileRepository])
import 'work_session_guard_test.mocks.dart';

class FakeWorkSessionViewModel extends ChangeNotifier implements WorkSessionViewModel {
  @override WorkSession? currentSession;
  @override bool isLoading = false;
  @override int currentDurationSeconds = 0;
  
  @override bool get isActive => currentSession?.status == 'active';
  @override bool get isPaused => currentSession?.status == 'paused';
  @override bool get isCompleted => currentSession?.status == 'completed';
  @override String? get errorMessage => null;

  @override Future<void> loadCurrentSession() async {}
  @override Future<void> startSession() async {}
  @override Future<void> pauseSession() async {}
  @override Future<void> resumeSession() async {}
  @override Future<void> endSession() async {}
}

void main() {
  late MockProfileRepository mockProfileRepository;
  late FakeWorkSessionViewModel fakeViewModel;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    fakeViewModel = FakeWorkSessionViewModel();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<WorkSessionViewModel>.value(
          value: fakeViewModel,
          child: WorkSessionGuard(
            profileRepository: mockProfileRepository,
            child: const Text('PROTECTED CONTENT'),
          ),
        ),
      ),
    );
  }

  group('WorkSessionGuard Tests', () {
    testWidgets('Bypasses guard and shows content if user is a customer', (tester) async {
      when(mockProfileRepository.getProfile()).thenAnswer((_) async => {'data': {'role': 'customer'}});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Resolve o Future do loading

      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
      expect(find.text('Access Restricted'), findsNothing);
    });

    testWidgets('Shows blocker if user is supporter and has NO active session', (tester) async {
      when(mockProfileRepository.getProfile()).thenAnswer((_) async => {'data': {'role': 'supporter'}});
      fakeViewModel.currentSession = null; // Sem sessão

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); 

      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('Access Restricted'), findsOneWidget);
    });

    testWidgets('Shows content if user is supporter and HAS active session', (tester) async {
      when(mockProfileRepository.getProfile()).thenAnswer((_) async => {'data': {'role': 'supporter'}});
      fakeViewModel.currentSession = WorkSession(
        id: 1, userId: 1, status: 'active', startedAt: DateTime.now(), totalDurationSeconds: 100,
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); 

      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
      expect(find.text('Access Restricted'), findsNothing);
    });
  });
}