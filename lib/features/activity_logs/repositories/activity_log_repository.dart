import '../../../core/network/api_client.dart';

/// Repository responsible for fetching system audit and activity logs.
class ActivityLogRepository {
  /// The HTTP client used for network requests.
  final ApiClient apiClient;

  /// Initializes the ActivityLogRepository.
  ActivityLogRepository({required this.apiClient});

  /// Retrieves a paginated list of system activity logs.
  /// 
  /// [page] Defines the pagination index.
  Future<Map<String, dynamic>> getActivityLogs({int page = 1}) async {
    return await apiClient.get(
      '/activity-logs', 
      queryParameters: {'page': page.toString()},
    );
  }
}