import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

// Generates the mock file for ApiClient
import 'ticket_repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late TicketRepository ticketRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    ticketRepository = TicketRepository(mockApiClient);
  });

  group('TicketRepository Tests', () {
    test('Should fetch and parse a list of tickets successfully', () async {
      // Arrange
      final mockApiResponse = {
        'data': [
          {
            'id': 1,
            'title': 'Server Down',
            'description': 'The main server is not responding.',
            'status': 'open',
            'created_at': '2026-02-24T10:00:00.000Z'
          },
          {
            'id': 2,
            'title': 'Billing Issue',
            'description': 'I was overcharged.',
            'status': 'closed',
            'created_at': '2026-02-23T15:30:00.000Z'
          }
        ]
      };

      when(mockApiClient.get(any)).thenAnswer((_) async => mockApiResponse);

      // Act
      final result = await ticketRepository.getTickets();

      // Assert
      expect(result, isA<List<Ticket>>());
      expect(result.length, equals(2));
      expect(result.first.title, equals('Server Down'));
      expect(result.first.status, equals('open'));
      expect(result.last.id, equals(2));
      
      verify(mockApiClient.get('/tickets')).called(1);
    });

    test('Should return an empty list when API response has no data', () async {
      // Arrange
      final mockApiResponse = {'data': []};
      when(mockApiClient.get(any)).thenAnswer((_) async => mockApiResponse);

      // Act
      final result = await ticketRepository.getTickets();

      // Assert
      expect(result, isEmpty);
    });

    test('Should throw an exception if the API client throws an exception', () async {
      // Arrange
      when(mockApiClient.get(any)).thenThrow(Exception('Server unreachable'));

      // Act & Assert
      expect(
        () => ticketRepository.getTickets(),
        throwsA(isA<Exception>()),
      );
    });
  });
}