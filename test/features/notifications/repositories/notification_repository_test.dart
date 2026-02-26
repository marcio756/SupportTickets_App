import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/notifications/repositories/notification_repository.dart';

@GenerateMocks([ApiClient])
import 'notification_repository_test.mocks.dart';

void main() {
  late NotificationRepository repository;
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
    repository = NotificationRepository(apiClient: mockClient);
  });

  group('NotificationRepository Tests', () {
    test('Should parse a list of notifications correctly', () async {
      // Arrange
      final mockData = {
        'data': [
          {
            'id': 'uuid-1234',
            'type': 'App\\Notifications\\TicketUpdated',
            'data': {'ticket_id': 1, 'message': 'Ticket updated'},
            'read_at': null,
            'created_at': '2026-02-24T10:00:00Z'
          }
        ]
      };

      when(mockClient.get(any)).thenAnswer((_) async => mockData);

      // Act
      final notifications = await repository.getNotifications();

      // Assert
      expect(notifications.length, 1);
      expect(notifications.first.id, 'uuid-1234');
      expect(notifications.first.isRead, false);
      expect(notifications.first.data['ticket_id'], 1);
      verify(mockClient.get('/notifications')).called(1);
    });

    test('Should execute marking all as read successfully', () async {
      // Arrange
      when(mockClient.post(any)).thenAnswer((_) async => {'status': 'Success'});

      // Act - We just await the void function
      await repository.markAllAsRead();

      // Assert - We verify that the client was called properly
      verify(mockClient.post('/notifications/mark-all-read')).called(1);
    });

    test('Should execute marking a specific notification as read', () async {
      // Arrange
      when(mockClient.patch(any)).thenAnswer((_) async => {'message': 'Notification marked as read'});

      // Act - We just await the void function
      await repository.markAsRead('uuid-1234');

      // Assert - We verify that the client was called properly
      verify(mockClient.patch('/notifications/uuid-1234/read')).called(1);
    });
  });
}