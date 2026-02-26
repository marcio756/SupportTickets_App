import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/users/ui/components/user_card.dart';

void main() {
  group('UserCard Widget Tests', () {
    testWidgets('Displays correct user information and triggers callbacks', (WidgetTester tester) async {
      final mockUser = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'support'
      };

      bool editPressed = false;
      bool deletePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              userMock: mockUser,
              onEdit: () => editPressed = true,
              onDelete: () => deletePressed = true,
            ),
          ),
        ),
      );

      // Verify text elements are rendered
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('SUPPORT'), findsOneWidget); // role is upper-cased in UI

      // Tap Edit
      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editPressed, isTrue);

      // Tap Delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deletePressed, isTrue);
    });
  });
}