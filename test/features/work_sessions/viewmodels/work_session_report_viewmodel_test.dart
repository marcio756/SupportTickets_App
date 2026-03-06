import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/features/work_sessions/repositories/work_session_repository.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_report_viewmodel.dart';

@GenerateMocks([WorkSessionRepository])
import 'work_session_report_viewmodel_test.mocks.dart';

void main() {
  late WorkSessionReportViewModel viewModel;
  late MockWorkSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkSessionRepository();
    viewModel = WorkSessionReportViewModel(repository: mockRepository);
  });

  group('WorkSessionReportViewModel', () {
    final mockData = {
      'data': {
        'sessions': {
          'data': [
            {'id': 1, 'status': 'completed', 'total_time_formatted': '8h 0m'}
          ],
          'current_page': 1,
          'last_page': 1,
        },
        'users': [
          {'id': 2, 'name': 'John Supporter'}
        ],
        'summary': {'total_hours': 8, 'total_minutes': 0}
      }
    };

    test('loadReports fetches data and updates state correctly', () async {
      when(mockRepository.getReports(page: 1, userId: null, date: null))
          .thenAnswer((_) async => mockData);

      await viewModel.loadReports();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.sessions.length, equals(1));
      expect(viewModel.summary['total_hours'], equals(8));
      expect(viewModel.usersList.length, equals(1));
      expect(viewModel.errorMessage, isNull);
    });

    test('setFilters resets pagination and reloads data', () async {
      when(mockRepository.getReports(page: 1, userId: '2', date: '2026-03-06'))
          .thenAnswer((_) async => mockData);

      viewModel.setFilters(userId: '2', date: DateTime(2026, 3, 6));

      expect(viewModel.isLoading, isTrue); // Should be loading after setting filter
      await Future.delayed(Duration.zero); // Let the async load finish
      
      verify(mockRepository.getReports(page: 1, userId: '2', date: '2026-03-06')).called(1);
      expect(viewModel.selectedUserId, equals('2'));
    });
  });
}