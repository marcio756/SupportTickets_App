import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supporttickets_app/core/widgets/custom_text_field.dart';
import 'package:supporttickets_app/core/widgets/primary_button.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

// Generates the mock classes for the dependencies
@GenerateMocks([AuthRepository, TicketRepository])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTicketRepository mockTicketRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTicketRepository = MockTicketRepository();
  });

  /// Standardizes the creation of the widget under test with injected mocks.
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginScreen(
        authRepository: mockAuthRepository,
        ticketRepository: mockTicketRepository,
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
      // Arrange
      final completer = Completer<bool>();
      
      // We stub the login to be controlled by the completer
      when(mockAuthRepository.login(any, any)).thenAnswer((_) => completer.future);
      
      // IMPORTANT: Since login success triggers navigation to Dashboard,
      // and Dashboard calls getTickets on initState, we must stub it here.
      when(mockTicketRepository.getTickets()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(CustomTextField).first, 'admin@test.com');
      await tester.enterText(find.byType(CustomTextField).last, 'password123');
      
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump(); 

      // Assert loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Finish the async login
      completer.complete(true);
      
      // pumpAndSettle handles the navigation animation and the Dashboard's initState
      await tester.pumpAndSettle();

      // Final Assertions
      verify(mockAuthRepository.login('admin@test.com', 'password123')).called(1);
      verify(mockTicketRepository.getTickets()).called(1);
    });
  });
}