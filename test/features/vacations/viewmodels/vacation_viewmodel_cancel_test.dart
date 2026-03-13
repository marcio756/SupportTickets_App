import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_request.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_viewmodel.dart';
import 'package:http/http.dart' as http;

class FakeCancelRepository implements VacationRepository {
  @override
  http.Client get client => throw UnimplementedError();

  @override
  String get baseUrl => throw UnimplementedError();

  @override
  Future<List<VacationRequest>> fetchVacations(String userId) async => [];

  @override
  Future<VacationRequest> createVacationRequest(VacationRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelVacationRequest(String vacationId) async {
    if (vacationId.isEmpty) throw Exception('Invalid ID');
    // Simulates successful network cancellation
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  group('VacationViewModel Cancellation Tests', () {
    late VacationViewModel viewModel;

    setUp(() {
      viewModel = VacationViewModel(repository: FakeCancelRepository());
      // Seed initial state
      viewModel.vacations.add(VacationRequest(
        id: 'vac_1',
        userId: 'user_1',
        teamId: 'team_1',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        totalDays: 5,
        status: VacationStatus.pending,
      ));
    });

    test('Should remove item from local state upon successful cancellation', () async {
      final success = await viewModel.cancelRequest('vac_1');
      
      expect(success, true);
      expect(viewModel.vacations.isEmpty, true);
      expect(viewModel.isLoading, false);
    });
  });
}