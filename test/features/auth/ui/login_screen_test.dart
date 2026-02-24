import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supporttickets_app/core/widgets/custom_text_field.dart';
import 'package:supporttickets_app/core/widgets/primary_button.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart'; // Add this

// Generates the mock file
@GenerateMocks([AuthRepository, TicketRepository]) // Add TicketRepository here
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTicketRepository mockTicketRepository; // Add this

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTicketRepository = MockTicketRepository(); // Add this
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginScreen(
        authRepository: mockAuthRepository,
        ticketRepository: mockTicketRepository, // Inject the mock here
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('Should display all necessary UI components', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Welcome to SupportTickets'), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('Should show validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      verifyNever(mockAuthRepository.login(any, any));
    });

    testWidgets('Should call repository and show loading state on valid submission', (tester) async {
      final completer = Completer<bool>();
      when(mockAuthRepository.login(any, any)).thenAnswer((_) => completer.future);
      
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(CustomTextField).first, 'admin@test.com');
      await tester.enterText(find.byType(CustomTextField).last, 'password123');
      
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump(); 

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(true);
      await tester.pumpAndSettle();

      verify(mockAuthRepository.login('admin@test.com', 'password123')).called(1);
    });
  });
}