import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_viewmodel.dart';
import 'package:supporttickets_app/features/work_sessions/ui/components/work_session_timer_widget.dart';

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
  late FakeWorkSessionViewModel fakeViewModel;

  setUp(() => fakeViewModel = FakeWorkSessionViewModel());

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<WorkSessionViewModel>.value(
          value: fakeViewModel,
          child: const WorkSessionTimerWidget(),
        ),
      ),
    );
  }

  testWidgets('Returns Off the clock view when session is null', (tester) async {
    fakeViewModel.currentSession = null;
    await tester.pumpWidget(createWidgetUnderTest());
    
    expect(find.text('Off the clock'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
  });

  testWidgets('Displays Working status in English', (tester) async {
    fakeViewModel.currentSession = WorkSession(id: 1, userId: 1, status: 'active', startedAt: DateTime.now(), totalDurationSeconds: 3665);
    fakeViewModel.currentDurationSeconds = 3665;
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('01:01:05'), findsOneWidget);
    expect(find.text('Working'), findsOneWidget);
  });

  testWidgets('Displays Shift Completed when user finishes the day', (tester) async {
    fakeViewModel.currentSession = WorkSession(id: 1, userId: 1, status: 'completed', startedAt: DateTime.now(), totalDurationSeconds: 125);
    fakeViewModel.currentDurationSeconds = 125;
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Shift Completed'), findsOneWidget);
    expect(find.text('Already worked today.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}