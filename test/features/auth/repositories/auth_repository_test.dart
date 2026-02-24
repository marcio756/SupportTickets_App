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
    authRepository = AuthRepository(mockApiClient, mockPrefs);
  });

  group('AuthRepository Tests', () {
    test('Should return true and save token when login is successful', () async {
      // Arrange - Simulating the Laravel ApiResponser structure
      const token = 'fake_jwt_token';
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => {
                'status': 'Success',
                'data': {'token': token, 'user': {}}
              });
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      final result = await authRepository.login('test@test.com', 'password');

      // Assert
      expect(result, isTrue);
      verify(mockApiClient.post('/login', data: {
        'email': 'test@test.com', 
        'password': 'password',
        'device_name': 'mobile_app'
      })).called(1);
      verify(mockPrefs.setString(ApiClient.tokenKey, token)).called(1);
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