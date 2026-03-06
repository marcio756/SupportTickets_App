import 'dart:async';
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

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      // Validamos usando a string exata que o LoginViewModel retorna na tua App
      expect(find.text('Por favor, preencha o e-mail e a palavra-passe.'), findsOneWidget);
    });

    testWidgets('Should call repository and show loading state on valid submission', (WidgetTester tester) async {
      // Alterado de Completer<bool> para Completer<Map<String, dynamic>> para bater certo com a assinatura atual
      final completer = Completer<Map<String, dynamic>>();
      when(mockAuthRepository.login('admin@test.com', 'password123'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextField).first, 'admin@test.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.text('Login'));
      // Pump apenas 1 frame sem aguardar a conclusão
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockAuthRepository.login('admin@test.com', 'password123')).called(1);

      // Limpeza do completer com um Map de sucesso simulado
      completer.complete({'status': 'Success', 'data': {'token': 'fake_token'}});
    });
  });
}