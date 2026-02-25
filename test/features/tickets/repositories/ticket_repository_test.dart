import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/models/ticket_message.dart';

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
      
      when(mockApiClient.get('/tickets')).thenAnswer((_) async => mockResponse);

      final result = await repository.getTickets();

      expect(result, isA<List<Ticket>>());
      expect(result.first.id, 1);
      expect(result.first.title, 'Test Ticket');
      verify(mockApiClient.get('/tickets')).called(1);
    });

    test('createTicket successfully sends data and returns created ticket', () async {
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
      
      // Payload updated: 'message' instead of 'description'
      when(mockApiClient.post('/tickets', data: {'title': title, 'message': description}))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.createTicket(title, description);

      expect(result, isA<Ticket>());
      expect(result.id, 2);
      expect(result.title, title);
      verify(mockApiClient.post('/tickets', data: {'title': title, 'message': description})).called(1);
    });

    test('updateTicketStatus successfully patches the status and returns ticket', () async {
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

      final result = await repository.updateTicketStatus(ticketId, newStatus);

      expect(result, isA<Ticket>());
      expect(result.status, 'closed');
      verify(mockApiClient.patch('/tickets/$ticketId/status', data: {'status': newStatus})).called(1);
    });

    test('sendMessage successfully posts a new message and returns it', () async {
      final ticketId = 1;
      final messageText = 'Hello, this is a test message.';
      
      // Adapted to full ticket resource returning messages array
      final mockResponse = {
        'data': {
          'id': 1, 
          'messages': [
            {
              'id': 10, 
              'ticket_id': 1, 
              'message': messageText,
              'sender': {
                'id': 5,
                'name': 'Agent John'
              },
              'created_at': '2023-01-01T12:00:00Z'
            }
          ]
        }
      };

      when(mockApiClient.post('/tickets/$ticketId/messages', data: {'message': messageText}))
          .thenAnswer((_) async => mockResponse);

      // Fix: Changed positional parameter to named parameter userId: 5
      final result = await repository.sendMessage(ticketId, messageText, userId: 5);

      expect(result, isA<TicketMessage>());
      expect(result.message, messageText);
      expect(result.userName, 'Agent John');
      expect(result.isFromMe, isTrue);
      verify(mockApiClient.post('/tickets/$ticketId/messages', data: {'message': messageText})).called(1);
    });
  });
}