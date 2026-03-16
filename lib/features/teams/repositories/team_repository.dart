import 'package:supporttickets_app/core/network/api_client.dart';
import '../models/team.dart';
import '../models/team_member.dart';

/// Handles data retrieval and mutation for Teams.
class TeamRepository {
  final ApiClient apiClient;

  TeamRepository({required this.apiClient});

  /// Recursive helper to unpack Laravel's double "data" arrays when pagination is active.
  List<dynamic> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) return _extractList(data['data']);
      return [data];
    }
    return [];
  }

  Future<List<TeamMember>> fetchTeamMembers(String teamId) async {
    final response = await apiClient.get('/teams/$teamId/members');
    final List<dynamic> listData = _extractList(response['data'] ?? response);
    return listData.map((json) => TeamMember.fromJson(json)).toList();
  }

  Future<List<Team>> fetchAllTeams() async {
    final response = await apiClient.get('/teams');
    final List<dynamic> listData = _extractList(response['data'] ?? response);
    return listData.map((json) => Team.fromJson(json)).toList();
  }

  /// Fetches all users and filters those designated strictly as 'supporter'
  Future<List<TeamMember>> fetchAllSupporters() async {
    final response = await apiClient.get('/users');
    final List<dynamic> listData = _extractList(response['data'] ?? response);
    
    return listData
        .map((json) => TeamMember.fromJson(json))
        .where((user) => user.role.toLowerCase() == 'supporter')
        .toList();
  }

  /// Submits the batch list of assigned user IDs to the team membership endpoint
  Future<void> assignTeamMembers(String teamId, List<String> userIds) async {
    await apiClient.post(
      '/teams/$teamId/members', // Ajusta se a tua rota do AssignTeamMembersRequest for diferente (ex: /teams/assign)
      data: {
        'user_ids': userIds.map((id) => int.tryParse(id) ?? id).toList(),
      },
    );
  }

  Future<Team> createTeam(String name, String shift) async {
    final response = await apiClient.post('/teams', data: {'name': name, 'shift': shift});
    return Team.fromJson(response['data'] ?? response);
  }

  Future<Team> updateTeam(String teamId, String name, String shift) async {
    final response = await apiClient.put('/teams/$teamId', data: {'name': name, 'shift': shift});
    return Team.fromJson(response['data'] ?? response);
  }

  Future<void> deleteTeam(String teamId) async {
    await apiClient.delete('/teams/$teamId');
  }
}