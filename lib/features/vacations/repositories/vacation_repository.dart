import 'package:supporttickets_app/core/network/api_client.dart';
import '../models/vacation_request.dart';

/// Handles all external data fetching and mutation for vacations.
/// Abstracts the HTTP logic so the ViewModel remains unaware of network protocols.
class VacationRepository {
  final ApiClient apiClient;

  VacationRepository({required this.apiClient});

  /// Método recursivo para desempacotar respostas aninhadas (ex: Paginação do Laravel ou ApiResponser).
  /// Evita o erro "Map is not a subtype of List".
  List<dynamic> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) {
        return _extractList(data['data']);
      }
      // Se for um único objeto sem a key 'data', colocamos numa lista.
      return [data];
    }
    return [];
  }

  /// Retrieves the vacation history and active requests for a specific user.
  Future<List<VacationRequest>> fetchVacations(String userId) async {
    final response = await apiClient.get('/vacations?userId=$userId');
    
    // Extrai a lista corretamente contornando duplos "data" do Laravel
    final List<dynamic> listData = _extractList(response['data'] ?? response);
    
    return listData.map((json) => VacationRequest.fromJson(json)).toList();
  }

  /// Submits a new vacation request to the backend validation pipeline.
  Future<VacationRequest> createVacationRequest(VacationRequest request) async {
    final response = await apiClient.post(
      '/vacations',
      data: request.toJson(),
    );
    
    dynamic responseData = response['data'] ?? response;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      responseData = responseData['data'];
    }
    
    return VacationRequest.fromJson(responseData is List ? responseData.first : responseData);
  }

  /// Cancels an existing vacation request by its unique identifier.
  Future<void> cancelVacationRequest(String vacationId) async {
    await apiClient.delete('/vacations/$vacationId');
  }
}