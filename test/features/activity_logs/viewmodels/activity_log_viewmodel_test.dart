import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/activity_logs/models/activity_log.dart';
import 'package:supporttickets_app/features/activity_logs/repositories/activity_log_repository.dart';
import 'package:supporttickets_app/features/activity_logs/viewmodels/activity_log_viewmodel.dart';

class FakeActivityLogRepository extends Fake implements ActivityLogRepository {
  @override
  Future<List<ActivityLog>> getLogs() async {
    return [
      ActivityLog(
        id: 1,
        description: 'created',
        event: 'created',
        causer: 'Admin',
        subjectType: 'Ticket',
        properties: {'attributes': {'title': 'New Ticket'}},
        createdAt: DateTime.now(),
      )
    ];
  }
}

void main() {
  late ActivityLogViewModel viewModel;
  late FakeActivityLogRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeActivityLogRepository();
    viewModel = ActivityLogViewModel(repository: fakeRepository);
  });

  group('ActivityLogViewModel - TDD', () {
    test('Must load activity logs successfully', () async {
      await viewModel.loadLogs();
      
      expect(viewModel.logs.length, 1);
      expect(viewModel.logs.first.event, 'created');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });
  });
}