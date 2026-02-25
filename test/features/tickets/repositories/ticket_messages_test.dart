import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

@GenerateMocks([ApiClient])
import 'ticket_messages_test.mocks.dart';

void main() {
  late TicketRepository repository;
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
    repository = TicketRepository(apiClient: mockClient);
  });

  group('Ticket Messages Repository Tests', () {
    test('Should parse ticket messages correctly from API', () async {
      // Arrange - Simulating the full Ticket object response with nested 'user'/'sender' object
      final mockData = {
        'data': {
          'id': 1,
          'title': 'Test Ticket',
          'messages': [
            {
              'id': 1, 
              'message': 'Hello', 
              'sender': {
                'id': 1,
                'name': 'Admin'
              }, 
              'created_at': '2026-02-24T12:00:00Z'
            }
          ]
        }
      };

      when(mockClient.get(any)).thenAnswer((_) async => mockData);

      // Act
      final messages = await repository.getTicketMessages(1, 1);

      // Assert
      expect(messages.length, 1);
      expect(messages.first.message, 'Hello');
      expect(messages.first.userName, 'Admin');
      expect(messages.first.isFromMe, true);
      verify(mockClient.get('/tickets/1')).called(1);
    });

    test('Should send message successfully', () async {
      // Arrange - Must mimic the new Backend behavior where the whole Ticket Resource is returned
      final mockResponse = {
        'data': {
          'id': 1, 
          'title': 'Test Ticket',
          'messages': [
            {
              'id': 2, 
              'message': 'Replying...', 
              'sender': {
                'id': 1,
                'name': 'Me'
              }, 
              'created_at': '2026-02-24T12:05:00Z'
            }
          ]
        }
      };

      when(mockClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.sendMessage(1, 'Replying...', 1);

      // Assert
      expect(result.message, 'Replying...');
      expect(result.userName, 'Me');
      expect(result.isFromMe, true);
      verify(mockClient.post('/tickets/1/messages', data: {'message': 'Replying...'})).called(1);
    });
  });
}