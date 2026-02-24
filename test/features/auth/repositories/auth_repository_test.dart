import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';

// Generates the mock file for ApiClient and SharedPreferences
import 'auth_repository_test.mocks.dart';

@GenerateMocks([ApiClient, SharedPreferences])
void main() {
  late AuthRepository authRepository;
  late MockApiClient mockApiClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApiClient = MockApiClient();
    mockPrefs = MockSharedPreferences();
    authRepository = AuthRepository(mockApiClient, mockPrefs);
  });

  group('AuthRepository Tests', () {
  test('Should return true and save token when login is successful', () async {
    // Arrange
    when(mockApiClient.post(any, data: anyNamed('data')))
        .thenAnswer((_) async => {'token': 'fake_token'});

    // Act
    final result = await authRepository.login('test@test.com', 'password');

    // Assert
    expect(result, isTrue);
    // VERIFICAÇÃO ATUALIZADA:
    verify(mockApiClient.post('/login', data: {
      'email': 'test@test.com', 
      'password': 'password',
      'device_name': 'mobile_app',
    })).called(1);
  });

    test('Should return false when API does not return a token', () async {
      // Arrange
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => {'message': 'Invalid credentials'});

      // Act
      final result = await authRepository.login('test@test.com', 'wrongpassword');

      // Assert
      expect(result, isFalse);
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