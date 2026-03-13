import 'package:flutter/foundation.dart';
import '../models/team_member.dart';
import '../repositories/team_repository.dart';

/// Orchestrates the state for the team view.
/// Broadcasts changes to the UI layer whenever data is actively fetching or encounters an error.
class TeamViewModel extends ChangeNotifier {
  final TeamRepository repository;

  List<TeamMember> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  TeamViewModel({required this.repository});

  List<TeamMember> get members => _members;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Initiates a network call to retrieve team members and manages the loading flag safely.
  Future<void> loadTeamMembers(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await repository.fetchTeamMembers(teamId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}