import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([ApiClient, SharedPreferences])
void main() {
  late AuthRepository authRepository;
  late MockApiClient mockApiClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApiClient = MockApiClient();
    mockPrefs = MockSharedPreferences();
    // Using named parameters for the updated constructor
    authRepository = AuthRepository(apiClient: mockApiClient, prefs: mockPrefs);
  });

  group('AuthRepository Tests', () {
    test('Should return response map and save token when login is successful', () async {
      // Arrange
      const token = 'fake_jwt_token';
      final mockResponse = {
        'status': 'Success',
        'data': {'token': token, 'user': {}}
      };
      
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      final result = await authRepository.login('test@test.com', 'password');

      // Assert
      // Agora verificamos se o resultado é o Map esperado, e não apenas um "true"
      expect(result, equals(mockResponse));
      expect(result['data']['token'], token);
      
      verify(mockApiClient.post('/login', data: {
        'email': 'test@test.com', 
        'password': 'password',
        'device_name': 'mobile_app'
      })).called(1);
      verify(mockPrefs.setString(ApiClient.tokenKey, token)).called(1);
    });

    test('Should return error map and not save token when API fails', () async {
      // Arrange
      final mockResponse = {'message': 'Invalid credentials'};
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await authRepository.login('test@test.com', 'wrongpassword');

      // Assert
      // Verificamos se devolve o erro da API em vez de um "false"
      expect(result, equals(mockResponse));
      verifyNever(mockPrefs.setString(any, any));
    });

    test('Should clear local token on logout regardless of API success', () async {
      // Arrange
      when(mockApiClient.post(any)).thenAnswer((_) async => {});
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);

      // Act
      await authRepository.logout();

      // Assert
      verify(mockApiClient.post('/logout')).called(1);
      verify(mockPrefs.remove(ApiClient.tokenKey)).called(1);
    });
  });
}