import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';

/// Repository responsible for handling work session data operations.
/// Communicates with the backend API to manage the user's time tracking.
class WorkSessionRepository {
  final ApiClient _apiClient;

  /// Initializes the repository with the provided ApiClient.
  ///
  /// @param apiClient The HTTP client used to make API requests.
  WorkSessionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Retrieves the currently active or paused work session for the authenticated user.
  ///
  /// @return A WorkSession instance if one is active, or null if the user has no ongoing session.
  /// @throws Exception If the API request fails.
  Future<WorkSession?> getCurrentSession() async {
    final response = await _apiClient.get('/work-sessions/current');
    
    if (response['data'] == null) {
      return null;
    }
    
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Starts a new work session for the authenticated user.
  ///
  /// @return The newly created WorkSession.
  /// @throws Exception If the API request fails or a session is already active.
  Future<WorkSession> startSession() async {
    final response = await _apiClient.post('/work-sessions/start');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Pauses the currently active work session.
  ///
  /// @return The updated WorkSession with a 'paused' status.
  /// @throws Exception If the API request fails or there is no active session.
  Future<WorkSession> pauseSession() async {
    final response = await _apiClient.post('/work-sessions/pause');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Resumes a currently paused work session.
  ///
  /// @return The updated WorkSession with an 'active' status.
  /// @throws Exception If the API request fails or the session is not paused.
  Future<WorkSession> resumeSession() async {
    final response = await _apiClient.post('/work-sessions/resume');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Ends the current work session.
  ///
  /// @return The completed WorkSession.
  /// @throws Exception If the API request fails or there is no session to end.
  Future<WorkSession> endSession() async {
    final response = await _apiClient.post('/work-sessions/end');
    return WorkSession.fromJson(response['data'] as Map<String, dynamic>);
  }
}