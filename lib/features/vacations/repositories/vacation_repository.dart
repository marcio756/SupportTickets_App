import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vacation_request.dart';

/// Handles all external data fetching and mutation for vacations.
/// Abstracts the HTTP logic so the ViewModel remains unaware of network protocols.
class VacationRepository {
  final http.Client client;
  final String baseUrl = 'https://api.yourdomain.com/v1';

  VacationRepository({required this.client});

  /// Retrieves the vacation history and active requests for a specific user.
  Future<List<VacationRequest>> fetchVacations(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/vacations?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => VacationRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vacations. Server returned ${response.statusCode}');
    }
  }

  /// Submits a new vacation request to the backend validation pipeline.
  Future<VacationRequest> createVacationRequest(VacationRequest request) async {
    final response = await client.post(
      Uri.parse('$baseUrl/vacations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return VacationRequest.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create vacation request. Server returned ${response.statusCode}');
    }
  }

  /// Cancels an existing vacation request by its unique identifier.
  Future<void> cancelVacationRequest(String vacationId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/vacations/$vacationId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to cancel vacation request.');
    }
  }
}