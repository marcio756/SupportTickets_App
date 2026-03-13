import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team_member.dart';

/// Handles network operations related to team synchronization.
/// Isolates HTTP logic to ensure ViewModels remain platform-agnostic.
class TeamRepository {
  final http.Client client;
  final String baseUrl = 'https://api.yourdomain.com/v1';

  TeamRepository({required this.client});

  /// Fetches the roster of members belonging to a specific team ID.
  Future<List<TeamMember>> fetchTeamMembers(String teamId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/teams/$teamId/members'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => TeamMember.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load team members. Server returned ${response.statusCode}');
    }
  }
}