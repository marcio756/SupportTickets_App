import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/tickets/ui/components/ticket_chat_input.dart';

void main() {
  group('TicketChatInput Component Tests', () {
    testWidgets('Should not fire onSendMessage when input is empty', (WidgetTester tester) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TicketChatInput(
              onSendMessage: (text) async {
                callbackFired = true;
              },
            ),
          ),
        ),
      );

      final sendButton = find.byType(IconButton);
      await tester.tap(sendButton);
      await tester.pump();

      expect(callbackFired, isFalse, reason: 'Callback should not fire on empty text.');
    });

    testWidgets('Should fire onSendMessage and clear text on success', (WidgetTester tester) async {
      String sentText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TicketChatInput(
              onSendMessage: (text) async {
                sentText = text;
              },
            ),
          ),
        ),
      );

      // Type text
      await tester.enterText(find.byType(TextField), 'Hello Support');
      await tester.pump();

      // Tap Send
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(sentText, 'Hello Support');
      
      // Verify field is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });
}