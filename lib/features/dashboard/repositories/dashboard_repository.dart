import '../../../core/network/api_client.dart';

/// Repository responsible for fetching dashboard statistics and overview data.
class DashboardRepository {
  final ApiClient _apiClient;

  /// Initializes the DashboardRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  DashboardRepository(this._apiClient);

  /// Retrieves the main dashboard data.
  ///
  /// Returns a Map containing the dashboard statistics.
  Future<Map<String, dynamic>> getDashboard() async {
    return await _apiClient.get('/dashboard');
  }
}