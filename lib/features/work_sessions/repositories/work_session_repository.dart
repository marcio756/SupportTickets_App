import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';

/// Repository responsible for handling work session data operations.
/// Communicates with the backend API to manage the user's time tracking.
class WorkSessionRepository {
  final ApiClient _apiClient;

  /// Initializes the repository with the provided ApiClient.
  ///
  /// [apiClient] The HTTP client used to make API requests.
  WorkSessionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Retrieves the currently active or paused work session for the authenticated user.
  Future<WorkSession?> getCurrentSession() async {
    final response = await _apiClient.get('/work-sessions/current');
    
    if (response['data'] == null) {
      return null;
    }
    
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Starts a new work session for the authenticated user.
  Future<WorkSession> startSession() async {
    final response = await _apiClient.post('/work-sessions/start');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Pauses the currently active work session.
  Future<WorkSession> pauseSession() async {
    final response = await _apiClient.post('/work-sessions/pause');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Resumes a currently paused work session.
  Future<WorkSession> resumeSession() async {
    final response = await _apiClient.post('/work-sessions/resume');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Ends the current work session.
  Future<WorkSession> endSession() async {
    final response = await _apiClient.post('/work-sessions/end');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Fetches paginated work session reports with optional filters.
  /// 
  /// Returns a map containing 'sessions' (pagination), 'users' (for admin filters), 
  /// and 'summary' (total hours and minutes).
  Future<Map<String, dynamic>> getReports({int page = 1, String? userId, String? date}) async {
    final Map<String, dynamic> queryParams = {'page': page.toString()};
    
    if (userId != null && userId.isNotEmpty) queryParams['user_id'] = userId;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;

    return await _apiClient.get('/work-sessions/reports', queryParameters: queryParams);
  }
}