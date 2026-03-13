import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_request_viewmodel.dart';

/// A Manual Mock (Spy) for VacationRepository.
/// This completely avoids Mockito's Null Safety and internal buffer issues.
/// It's cleaner, faster, and predictable.
class VacationRepositorySpy implements VacationRepository {
  int bookVacationCallCount = 0;
  DateTime? lastStartDate;
  DateTime? lastEndDate;
  bool shouldThrow = false;

  @override
  Future<Vacation> bookVacation({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    bookVacationCallCount++;
    lastStartDate = startDate;
    lastEndDate = endDate;

    if (shouldThrow) {
      throw Exception('API Error');
    }

    return Vacation(
      id: 1,
      startDate: startDate,
      endDate: endDate,
      totalDays: 5,
      status: 'pending',
    );
  }

  @override
  Future<List<VacationTeam>> getCalendarData({required int year}) {
    throw UnimplementedError('Not needed for these tests');
  }
}

void main() {
  late VacationRequestViewModel viewModel;
  late VacationRepositorySpy spyRepository;

  setUp(() {
    spyRepository = VacationRepositorySpy();
    viewModel = VacationRequestViewModel(repository: spyRepository);
  });

  group('VacationRequestViewModel', () {
    test('submit returns false and sets error if dates are invalid', () async {
      // Arrange: Fim antes do início
      viewModel.setStartDate(DateTime(2026, 10, 10));
      viewModel.setEndDate(DateTime(2026, 10, 5));

      // Act
      final result = await viewModel.submitRequest();

      // Assert
      expect(result, false);
      expect(viewModel.errorMessage, 'The end date cannot be earlier than the start date.');
      // Verify repository was NEVER called
      expect(spyRepository.bookVacationCallCount, 0);
    });

    test('submit calls repository and returns true on success', () async {
      // Arrange
      final startDate = DateTime(2026, 10, 1);
      final endDate = DateTime(2026, 10, 5);
      viewModel.setStartDate(startDate);
      viewModel.setEndDate(endDate);

      // Act
      final result = await viewModel.submitRequest();

      // Assert
      expect(result, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      
      // Verify repository was called correctly
      expect(spyRepository.bookVacationCallCount, 1);
      expect(spyRepository.lastStartDate, startDate);
      expect(spyRepository.lastEndDate, endDate);
    });

    test('submit handles network errors gracefully', () async {
      // Arrange
      spyRepository.shouldThrow = true;
      viewModel.setStartDate(DateTime(2026, 10, 1));
      viewModel.setEndDate(DateTime(2026, 10, 5));

      // Act
      final result = await viewModel.submitRequest();

      // Assert
      expect(result, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Failed to submit vacation request. Please try again or check your dates.');
      expect(spyRepository.bookVacationCallCount, 1);
    });
  });
}