import 'package:flutter/foundation.dart';
import '../models/team_member.dart';
import '../models/team.dart';
import '../repositories/team_repository.dart';

/// Orchestrates the state for the team view and admin team management.
/// Broadcasts changes to the UI layer whenever data is actively fetching or encounters an error.
class TeamViewModel extends ChangeNotifier {
  final TeamRepository repository;

  List<TeamMember> _members = [];
  List<Team> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;

  TeamViewModel({required this.repository});

  List<TeamMember> get members => _members;
  List<Team> get teams => _teams;
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

  /// Retrieves all teams for the administrative management view.
  Future<void> loadAllTeams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teams = await repository.fetchAllTeams();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Requests the creation of a new team and updates the local state upon success.
  Future<bool> createTeam(String name, String shift) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTeam = await repository.createTeam(name, shift);
      _teams.add(newTeam);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits an update for an existing team and reflects the changes in the UI state.
  Future<bool> updateTeam(String teamId, String name, String shift) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTeam = await repository.updateTeam(teamId, name, shift);
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes a team via the API and drops it from the local state.
  Future<bool> deleteTeam(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteTeam(teamId);
      _teams.removeWhere((t) => t.id == teamId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all available supporters globally from the data source.
  /// Used for populating batch assignment dialogs.
  Future<List<TeamMember>> fetchAllSupporters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await repository.fetchAllSupporters();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Assigns a batch of supporters to a specific team and refreshes the current team state.
  /// 
  /// [teamId] The unique identifier of the target team.
  /// [memberIds] A list of user IDs to associate with the team.
  Future<bool> assignTeamMembers(String teamId, List<String> memberIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.assignTeamMembers(teamId, memberIds);
      await loadTeamMembers(teamId); // Reload to reflect changes
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}