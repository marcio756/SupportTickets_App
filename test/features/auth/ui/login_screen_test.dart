import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

@GenerateMocks([AuthRepository, TicketRepository, ProfileRepository])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockTicketRepository mockTicketRepo;
  late MockProfileRepository mockProfileRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockTicketRepo = MockTicketRepository();
    mockProfileRepo = MockProfileRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginScreen(
        authRepository: mockAuthRepo,
        ticketRepository: mockTicketRepo,
        profileRepository: mockProfileRepo,
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('Should display all necessary UI components', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Checking new UI texts based on recent UI refactor
      expect(find.text('Support Tickets'), findsOneWidget);
      expect(find.text('Inicie sessão na sua conta'), findsOneWidget);
      
      // We expect two native Flutter TextFields (Email and Password)
      expect(find.byType(TextField), findsNWidgets(2));
      
      // We expect the native ElevatedButton text
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('Should show validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap login button without entering data
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Verify the snackbar message from LoginViewModel
      expect(find.text('Por favor, preencha o e-mail e a palavra-passe.'), findsOneWidget);
      verifyNever(mockAuthRepo.login(any, any));
    });

    testWidgets('Should call repository and show loading state on valid submission', (tester) async {
      // Use a Completer to freeze the async operation and check the intermediate loading state
      final completer = Completer<bool>();
      when(mockAuthRepo.login('admin@test.com', 'password')).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);
      
      // Enter email
      await tester.enterText(textFields.at(0), 'admin@test.com');
      // Enter password
      await tester.enterText(textFields.at(1), 'password');

      // Tap login
      await tester.tap(find.text('Entrar'));
      
      // Trigger a single frame rebuild to show the CircularProgressIndicator
      await tester.pump();
      
      // Assert that the loading indicator is visible while waiting for the repository
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Resolve the future to simulate the API responding
      completer.complete(true);
      
      // Process all remaining animations and navigations
      await tester.pumpAndSettle();
      
      verify(mockAuthRepo.login('admin@test.com', 'password')).called(1);
    });
  });
}