import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

/// Repository responsible for handling user authentication operations.
class AuthRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;
  
  /// Local storage for persisting the authentication token.
  final SharedPreferences prefs;

  /// Initializes the AuthRepository.
  ///
  /// Requires both [apiClient] for network and [prefs] for token storage.
  AuthRepository({required this.apiClient, required this.prefs});

  /// Authenticates a user with the provided credentials.
  ///
  /// Returns [true] if successful and saves the token, [false] otherwise.
  Future<bool> login(String email, String password) async {
    final Map<String, dynamic> response = await apiClient.post(
      '/login', 
      data: {
        'email': email,
        'password': password,
        'device_name': 'mobile_app', // Typically required by Laravel Sanctum
      }
    );

    // Extract data wrapper if it exists
    final data = response.containsKey('data') ? response['data'] : response;
    
    if (data != null && data.containsKey('token')) {
      // Save the token locally to persist the session
      await prefs.setString(ApiClient.tokenKey, data['token']);
      return true;
    }
    
    return false;
  }

  /// Logs out the current authenticated user and invalidates the session.
  ///
  /// Clears the token from local storage regardless of API success.
  Future<void> logout() async {
    try {
      await apiClient.post('/logout');
    } finally {
      // Ensure the local session is always destroyed
      await prefs.remove(ApiClient.tokenKey);
    }
  }
}