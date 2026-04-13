// Ficheiro: lib/features/profile/repositories/profile_repository.dart
import '../../../core/network/api_client.dart';

/// Repository responsible for handling user profile data and account settings.
class ProfileRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the ProfileRepository.
  ///
  /// The [apiClient] parameter is required for network communication.
  ProfileRepository({required this.apiClient});

  /// Retrieves the authenticated user's profile information.
  ///
  /// Returns a [Map] containing the user data.
  Future<Map<String, dynamic>> getProfile() async {
    return await apiClient.get('/me');
  }

  /// Updates the authenticated user's profile information.
  ///
  /// [data] A map containing the profile fields to update.
  /// Returns a [Map] containing the updated user data.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await apiClient.put('/me', data: data);
  }

  /// Updates the authenticated user's password.
  ///
  /// Requires the current password for verification and the new password data.
  Future<void> updatePassword(Map<String, dynamic> passwordData) async {
    await apiClient.put('/me/password', data: passwordData);
  }

  /// Deletes the authenticated user's account permanently.
  ///
  /// Depending on the backend implementation, it might require sending the current
  /// password in the [data] map for security validation before deletion.
  Future<void> deleteAccount({Map<String, dynamic>? data}) async {
    await apiClient.delete('/me', data: data);
  }

  // --- Two-Factor Authentication Endpoints ---

  /// Enables 2FA for the current user.
  /// Standard Laravel Fortify protocol requires a POST to enable, 
  /// followed by GET requests to retrieve the SVG and Secret Key.
  Future<Map<String, dynamic>> enableTwoFactor() async {
    // 1. Activa o 2FA (Apenas devolve 200 OK sem payload)
    await apiClient.post('/user/two-factor-authentication');
    
    // 2. Vai buscar os recursos gerados
    final qrResponse = await apiClient.get('/user/two-factor-qr-code');
    final secretResponse = await apiClient.get('/user/two-factor-secret-key');
    
    // Extrai com segurança as propriedades da resposta
    final qrData = qrResponse is Map && qrResponse.containsKey('svg') ? qrResponse['svg'] : null;
    final secretData = secretResponse is Map && secretResponse.containsKey('secretKey') ? secretResponse['secretKey'] : null;

    return {
      'svg': qrData,
      'secretKey': secretData,
    };
  }

  /// Confirms 2FA activation using the OTP code from the authenticator app.
  Future<Map<String, dynamic>> confirmTwoFactor(String code) async {
    return await apiClient.post('/user/confirmed-two-factor-authentication', data: {
      'code': code,
    });
  }

  /// Disables 2FA for the current user.
  Future<void> disableTwoFactor() async {
    await apiClient.delete('/user/two-factor-authentication');
  }

  /// Retrieves the recovery codes for 2FA.
  Future<Map<String, dynamic>> getRecoveryCodes() async {
    return await apiClient.get('/user/two-factor-recovery-codes');
  }

  /// Regenerates a new set of 2FA recovery codes.
  Future<Map<String, dynamic>> regenerateRecoveryCodes() async {
    return await apiClient.post('/user/two-factor-recovery-codes');
  }
}