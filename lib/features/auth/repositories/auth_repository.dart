import '../../../core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository responsible for handling authentication processes.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  /// Initializes the AuthRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  /// [_prefs] Local storage for saving the authentication token.
  AuthRepository(this._apiClient, this._prefs);

  /// Authenticates a user and saves the token locally.
  ///
  /// [email] The user's email address.
  /// [password] The user's password.
  /// Returns true if authentication is successful.
  Future<bool> login(String email, String password) async {
    final response = await _apiClient.post('/login', data: {
      'email': email,
      'password': password,
      'device_name': 'mobile_app',
    });

    // Handle responses wrapped in a 'data' object (common in ApiResponser traits)
    final responseData = response.containsKey('data') ? response['data'] : response;

    if (responseData != null && responseData is Map && responseData.containsKey('token')) {
      await _prefs.setString(ApiClient.tokenKey, responseData['token']);
      return true;
    }
    
    return false;
  }

  /// Logs out the currently authenticated user and clears local session.
  Future<void> logout() async {
    await _apiClient.post('/logout');
    await _prefs.remove(ApiClient.tokenKey);
  }
}