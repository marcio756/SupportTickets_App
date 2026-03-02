import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

@GenerateMocks([AuthRepository, TicketRepository, ProfileRepository])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTicketRepository mockTicketRepository;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTicketRepository = MockTicketRepository();
    mockProfileRepository = MockProfileRepository();
  });

  Widget createLoginScreen() {
    return MaterialApp(
      home: LoginScreen(
        authRepository: mockAuthRepository,
        ticketRepository: mockTicketRepository,
        profileRepository: mockProfileRepository,
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('Should display all necessary UI components', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('Support Tickets'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Should show validation errors when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Changed from 'Entrar' to 'Login'
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your email and password.'), findsOneWidget);
    });

    testWidgets('Should call repository and show loading state on valid submission', (WidgetTester tester) async {
      when(mockAuthRepository.login('admin@test.com', 'password123'))
          .thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 500)));

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextField).first, 'admin@test.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Changed from 'Entrar' to 'Login'
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockAuthRepository.login('admin@test.com', 'password123')).called(1);
    });
  });
}