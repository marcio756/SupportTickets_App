import '../../../core/network/api_client.dart';

/// Repository responsible for handling dashboard statistics and overview data.
class DashboardRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the DashboardRepository.
  ///
  /// The [apiClient] parameter is strictly required for network communication.
  DashboardRepository({required this.apiClient});

  /// Fetches the dashboard overview statistics.
  ///
  /// Returns a [Map] containing metrics like total tickets, open tickets, etc.
  Future<Map<String, dynamic>> getDashboardData() async {
    final Map<String, dynamic> response = await apiClient.get('/dashboard');
    
    // Extracts the inner data wrapper if it exists (standard Laravel Resource format)
    return response.containsKey('data') 
        ? response['data'] as Map<String, dynamic> 
        : response;
  }
}