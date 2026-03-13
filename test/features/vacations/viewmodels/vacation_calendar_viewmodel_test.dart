import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_calendar_viewmodel.dart';

// Generates the mock class for VacationRepository
@GenerateMocks([VacationRepository])
import 'vacation_calendar_viewmodel_test.mocks.dart';

void main() {
  late VacationCalendarViewModel viewModel;
  late MockVacationRepository mockRepository;

  setUp(() {
    mockRepository = MockVacationRepository();
    viewModel = VacationCalendarViewModel(repository: mockRepository);
  });

  group('VacationCalendarViewModel', () {
    test('initial state should be empty and not loading', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.teams, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('loadCalendar fetches data and updates state successfully', () async {
      // Arrange
      final int targetYear = 2026;
      final mockTeams = [
        VacationTeam(id: 1, name: 'Support Squad', shift: 'morning', members: []),
      ];

      when(mockRepository.getCalendarData(year: targetYear))
          .thenAnswer((_) async => mockTeams);

      // Act
      final future = viewModel.loadCalendar(targetYear);
      
      // Assert intermediate loading state
      expect(viewModel.isLoading, true);
      
      await future;

      // Assert final state
      expect(viewModel.isLoading, false);
      expect(viewModel.teams, mockTeams);
      expect(viewModel.errorMessage, isNull);
      
      verify(mockRepository.getCalendarData(year: targetYear)).called(1);
    });

    test('loadCalendar handles exceptions and sets error message', () async {
      // Arrange
      when(mockRepository.getCalendarData(year: 2026))
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.loadCalendar(2026);

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.teams, isEmpty);
      expect(viewModel.errorMessage, 'Failed to load vacation calendar. Please try again.');
    });
  });
}