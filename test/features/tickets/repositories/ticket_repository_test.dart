import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/models/ticket_message.dart';

// Generates the mock class for ApiClient
@GenerateMocks([ApiClient])
import 'ticket_repository_test.mocks.dart';

void main() {
  late TicketRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = TicketRepository(apiClient: mockApiClient);
  });

  group('TicketRepository', () {
    test('getTickets returns a list of tickets on success', () async {
      // Arrange
      final mockResponse = {
        'data': [
          {
            'id': 1, 
            'title': 'Test Ticket', 
            'description': 'Description',
            'status': 'open',
            'created_at': '2023-01-01T12:00:00Z'
          }
        ],
      };
      
      when(mockApiClient.get('/tickets'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getTickets();

      // Assert
      expect(result, isA<List<Ticket>>());
      expect(result.first.id, 1);
      expect(result.first.title, 'Test Ticket');
      verify(mockApiClient.get('/tickets')).called(1);
    });

    test('createTicket successfully sends data and returns created ticket', () async {
      // Arrange
      final title = 'New Problem';
      final description = 'Description here';
      final mockResponse = {
        'data': {
          'id': 2, 
          'title': title,
          'description': description,
          'status': 'open',
          'created_at': '2023-01-01T12:00:00Z'
        }
      };
      
      when(mockApiClient.post('/tickets', data: {'title': title, 'description': description}))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.createTicket(title, description);

      // Assert
      expect(result, isA<Ticket>());
      expect(result.id, 2);
      expect(result.title, title);
      verify(mockApiClient.post('/tickets', data: {'title': title, 'description': description})).called(1);
    });

    test('updateTicketStatus successfully patches the status and returns ticket', () async {
      // Arrange
      final ticketId = 1;
      final newStatus = 'closed';
      final mockResponse = {
        'data': {
          'id': 1, 
          'title': 'Test',
          'description': 'Test',
          'status': 'closed',
          'created_at': '2023-01-01T12:00:00Z'
        }
      };

      when(mockApiClient.patch('/tickets/$ticketId/status', data: {'status': newStatus}))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.updateTicketStatus(ticketId, newStatus);

      // Assert
      expect(result, isA<Ticket>());
      expect(result.status, 'closed');
      verify(mockApiClient.patch('/tickets/$ticketId/status', data: {'status': newStatus})).called(1);
    });

    test('sendMessage successfully posts a new message and returns it', () async {
      // Arrange
      final ticketId = 1;
      final message = 'Hello, this is a test message.';
      // Updated to match the new nested JSON structure expected by TicketMessage.fromJson
      final mockResponse = {
        'data': {
          'id': 10, 
          'ticket_id': 1, 
          'message': message,
          'user': {
            'id': 5,
            'name': 'Agent John'
          },
          'created_at': '2023-01-01T12:00:00Z'
        }
      };

      when(mockApiClient.post('/tickets/$ticketId/messages', data: {'message': message}))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.sendMessage(ticketId, message, 5);

      // Assert
      expect(result, isA<TicketMessage>());
      expect(result.message, message);
      expect(result.userName, 'Agent John');
      expect(result.isFromMe, isTrue); // Should be true because user.id (5) matches passed userId (5)
      verify(mockApiClient.post('/tickets/$ticketId/messages', data: {'message': message})).called(1);
    });
  });
}