import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

/// Repository responsible for handling all authentication-related data operations.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const String tokenKey = 'auth_token';

  AuthRepository(this._apiClient, this._prefs);

  /// Authenticates a user and sends the required device_name for Laravel Sanctum.
  Future<bool> login(String email, String password) async {
    final response = await _apiClient.post(
      '/login',
      data: {
        'email': email,
        'password': password,
        'device_name': 'mobile_app',
      },
    );

    if (response.containsKey('token')) {
      await _prefs.setString(tokenKey, response['token']);
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (e) {
      // Ignore network errors during logout
    } finally {
      await _prefs.remove(tokenKey);
    }
  }
}