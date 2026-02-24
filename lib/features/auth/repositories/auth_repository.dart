import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

/// Repository responsible for handling all authentication-related data operations.
/// It abstracts the API calls and local token storage from the UI layer.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  /// Initializes the repository with required dependencies.
  ///
  /// [_apiClient] The network client for HTTP requests.
  /// [_prefs] Local storage for saving the authentication token.
  AuthRepository(this._apiClient, this._prefs);

  /// Authenticates a user with the provided credentials.
  ///
  /// [email] The user's registered email.
  /// [password] The user's secret password.
  /// Returns a boolean indicating whether the login was successful.
  Future<bool> login(String email, String password) async {
    // Dispatch login request to the backend
    final response = await _apiClient.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    // Verify if the API returned an authentication token
    if (response.containsKey('token')) {
      // Persist the token locally for future authenticated requests
      await _prefs.setString(ApiClient.tokenKey, response['token']);
      return true;
    }
    
    return false;
  }

  /// Logs out the current user by clearing local data and notifying the server.
  Future<void> logout() async {
    try {
      // Attempt to invalidate the token on the server side
      await _apiClient.post('/logout');
    } catch (e) {
      // Even if the server request fails (e.g., no internet), 
      // we must proceed to clear the local token
    } finally {
      // Destroy local session
      await _prefs.remove(ApiClient.tokenKey);
    }
  }
}