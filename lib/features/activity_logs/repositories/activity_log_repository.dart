import '../../../core/network/api_client.dart';
import '../models/activity_log.dart';

/// Repository responsible for fetching Activity Logs.
class ActivityLogRepository {
  final ApiClient apiClient;

  ActivityLogRepository({required this.apiClient});

  /// Fetches a list of activity logs from the server.
  Future<List<ActivityLog>> getLogs() async {
    final response = await apiClient.get('/activity-logs');
    
    // Extrai o 'data' da resposta (criado pela ApiResponser do Laravel)
    dynamic data = response.containsKey('data') ? response['data'] : response;
    List<dynamic> rawLogs = [];

    // Navega pela estrutura complexa: { data: { logs: { current_page: 1, data: [...] }, options: {...} } }
    if (data is Map) {
      if (data.containsKey('logs')) {
        dynamic logsData = data['logs'];
        
        // Lida com a paginação do Laravel escondida dentro de 'logs'
        if (logsData is Map && logsData.containsKey('data')) {
          rawLogs = logsData['data'] is List ? logsData['data'] : [];
        } else if (logsData is List) {
          rawLogs = logsData;
        }
      } else if (data.containsKey('data') && data['data'] is List) {
        // Fallback genérico caso a API mude no futuro
        rawLogs = data['data'];
      }
    } else if (data is List) {
      rawLogs = data;
    }

    return rawLogs.map((json) => ActivityLog.fromJson(json as Map<String, dynamic>)).toList();
  }
}