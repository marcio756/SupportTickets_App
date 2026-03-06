import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/users/repositories/user_repository.dart';

@GenerateMocks([ApiClient])
import 'user_repository_discovery_test.mocks.dart';

void main() {
  late UserRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserRepository(apiClient: mockApiClient);
  });

  group('UserRepository - Discovery Endpoints', () {
    final mockResponse = {
      'data': [
        {'id': 1, 'name': 'John Customer', 'email': 'john@test.com'},
        {'id': 2, 'name': 'Mary Customer', 'email': 'mary@test.com'},
      ]
    };

    test('getCustomers requests the correct endpoint and returns simplified user list', () async {
      when(mockApiClient.get('/customers', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getCustomers();

      expect(result.length, equals(2));
      expect(result.first['name'], equals('John Customer'));
      verify(mockApiClient.get('/customers')).called(1);
    });

    test('getSupporters requests the correct endpoint and returns simplified user list', () async {
      when(mockApiClient.get('/supporters', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getSupporters();

      expect(result.length, equals(2));
      expect(result.first['email'], equals('john@test.com'));
      verify(mockApiClient.get('/supporters')).called(1);
    });

    test('Returns empty list when discovery API returns null data', () async {
      when(mockApiClient.get('/customers', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => {'data': null});

      final result = await repository.getCustomers();

      expect(result, isEmpty);
    });
  });
}