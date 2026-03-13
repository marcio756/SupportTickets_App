import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supporttickets_app/features/vacations/models/vacation_request.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_viewmodel.dart';

/// Fake implementation to bypass Mockito Null Safety issues on required string parameters
class FakeVacationRepository implements VacationRepository {
  @override
  http.Client get client => throw UnimplementedError();

  @override
  String get baseUrl => throw UnimplementedError();

  @override
  Future<List<VacationRequest>> fetchVacations(String userId) async {
    // Simulates a network delay to accurately test loading states
    await Future.delayed(const Duration(milliseconds: 100));
    return <VacationRequest>[];
  }

  @override
  Future<VacationRequest> createVacationRequest(VacationRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelVacationRequest(String vacationId) {
    throw UnimplementedError();
  }
}

void main() {
  group('VacationViewModel State Management Tests', () {
    late VacationViewModel viewModel;
    late FakeVacationRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeVacationRepository();
      viewModel = VacationViewModel(repository: fakeRepository);
    });

    test('Should expose loading state while fetching vacations', () async {
      final future = viewModel.loadVacations('user_1');
      
      // Loading state should be active immediately after dispatching the call
      expect(viewModel.isLoading, true);
      
      await future;
      
      // Loading state should resolve to false once the operation concludes
      expect(viewModel.isLoading, false);
      expect(viewModel.hasError, false);
    });
  });
}