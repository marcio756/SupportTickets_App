import '../../../core/network/api_client.dart';
import '../models/activity_log.dart';

/// Repository responsible for fetching Activity Logs.
class ActivityLogRepository {
  final ApiClient apiClient;

  ActivityLogRepository({required this.apiClient});

  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    dynamic data = response.containsKey('data') ? response['data'] : response;
    if (data is Map && data.containsKey('data') && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    if (data is Map) return data.values.toList();
    return [];
  }

  /// Fetches a list of activity logs from the server.
  Future<List<ActivityLog>> getLogs() async {
    final response = await apiClient.get('/activity-logs');
    final dataList = _extractDataList(response);
    return dataList.map((json) => ActivityLog.fromJson(json as Map<String, dynamic>)).toList();
  }
}