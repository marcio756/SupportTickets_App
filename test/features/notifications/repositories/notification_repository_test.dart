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
    repository = NotificationRepository(mockClient);
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

    test('Should return true when marking all as read successfully', () async {
      // Arrange
      when(mockClient.post(any)).thenAnswer((_) async => {'status': 'Success'});

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result, true);
      verify(mockClient.post('/notifications/mark-all-read')).called(1);
    });

    test('Should return true when marking a specific notification as read', () async {
      // Arrange
      when(mockClient.patch(any)).thenAnswer((_) async => {'message': 'Notification marked as read'});

      // Act
      final result = await repository.markAsRead('uuid-1234');

      // Assert
      expect(result, true);
      verify(mockClient.patch('/notifications/uuid-1234/read')).called(1);
    });
  });
}