import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/notifications/repositories/notification_repository.dart';

@GenerateMocks([ApiClient])
import 'notification_repository_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late NotificationRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = NotificationRepository(apiClient: mockApiClient);
  });

  group('NotificationRepository -', () {
    test('getNotifications deve extrair a lista corretamente de uma resposta paginada do Laravel', () async {
      // Arrange: Simula a resposta do Laravel usando a Trait ApiResponser e paginate()
      final mockResponse = {
        'status': 'Success',
        'message': 'Notificações carregadas com sucesso.',
        'data': {
          'current_page': 1,
          'data': [
            {
              'id': '123e4567-e89b-12d3-a456-426614174000',
              'type': 'App\\Notifications\\TicketNotification',
              'data': {'ticket_id': 1, 'message': 'Novo ticket atribuído'},
              'read_at': null,
              'created_at': '2026-02-26T10:00:00.000000Z'
            }
          ],
          'total': 1,
        }
      };

      when(mockApiClient.get('/notifications')).thenAnswer((_) async => mockResponse);

      // Act
      final notifications = await repository.getNotifications();

      // Assert
      expect(notifications.length, 1);
      expect(notifications.first.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(notifications.first.isRead, false);
      expect(notifications.first.data['ticket_id'], 1);
      
      verify(mockApiClient.get('/notifications')).called(1);
    });

    test('markAsRead deve chamar o endpoint correto da API', () async {
      // Arrange
      const notificationId = 'test-id';
      when(mockApiClient.patch('/notifications/$notificationId/read'))
          .thenAnswer((_) async => {'status': 'success'});

      // Act
      await repository.markAsRead(notificationId);

      // Assert
      verify(mockApiClient.patch('/notifications/$notificationId/read')).called(1);
    });

    test('markAllAsRead deve chamar o endpoint correto da API', () async {
      // Arrange
      when(mockApiClient.post('/notifications/mark-all-read'))
          .thenAnswer((_) async => {'status': 'success'});

      // Act
      await repository.markAllAsRead();

      // Assert
      verify(mockApiClient.post('/notifications/mark-all-read')).called(1);
    });
  });
}