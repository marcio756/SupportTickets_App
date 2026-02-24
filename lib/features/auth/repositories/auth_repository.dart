import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

/// Repository responsible for handling all authentication-related data operations.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  /// Authenticates a user with the provided credentials.
  Future<bool> login(String email, String password) async {
    final response = await _apiClient.post(
      '/login',
      data: {
        'email': email, 
        'password': password,
        'device_name': 'mobile_app'
      },
    );

    // CORREÇÃO: A tua API Laravel usa o ApiResponser, que coloca o payload dentro 
    // de um objeto chamado 'data'. Temos de procurar o token lá dentro.
    if (response.containsKey('data') && response['data'] != null) {
      final responseData = response['data'] as Map<String, dynamic>;
      if (responseData.containsKey('token')) {
        await _prefs.setString(ApiClient.tokenKey, responseData['token']);
        return true;
      }
    }
    
    return false;
  }

  /// Logs out the current user by clearing local data and notifying the server.
  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (e) {
      // Ignore network errors during logout
    } finally {
      await _prefs.remove(ApiClient.tokenKey);
    }
  }
}