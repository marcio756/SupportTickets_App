import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supporttickets_app/features/teams/models/team_member.dart';
import 'package:supporttickets_app/features/teams/repositories/team_repository.dart';
import 'package:supporttickets_app/features/teams/viewmodels/team_viewmodel.dart';

/// Fake implementation isolating the ViewModel from actual network requests.
class FakeTeamRepository implements TeamRepository {
  @override
  http.Client get client => throw UnimplementedError();

  @override
  String get baseUrl => throw UnimplementedError();

  @override
  Future<List<TeamMember>> fetchTeamMembers(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return [
      TeamMember(id: '1', name: 'Test', email: 'test@test.com', shift: ShiftType.morning, role: 'user')
    ];
  }
}

void main() {
  group('TeamViewModel Tests', () {
    late TeamViewModel viewModel;
    late FakeTeamRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeTeamRepository();
      viewModel = TeamViewModel(repository: fakeRepository);
    });

    test('Should update loading state and populate members on success', () async {
      final future = viewModel.loadTeamMembers('team_1');
      
      expect(viewModel.isLoading, true);
      
      await future;
      
      expect(viewModel.isLoading, false);
      expect(viewModel.members.length, 1);
      expect(viewModel.hasError, false);
    });
  });
}