import '../../../core/network/api_client.dart';

/// Repository responsible for fetching aggregated statistics for the dashboard.
class DashboardRepository {
  /// The HTTP client used for network requests.
  final ApiClient apiClient;

  /// Initializes the DashboardRepository.
  DashboardRepository({required this.apiClient});

  /// Retrieves dashboard statistics and ranking data.
  /// 
  /// The backend automatically serves customer or supporter metrics
  /// based on the authenticated user's role.
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await apiClient.get('/dashboard');
    
    // Safely extract the 'data' payload if wrapped by Laravel ApiResponser
    if (response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response;
  }
}