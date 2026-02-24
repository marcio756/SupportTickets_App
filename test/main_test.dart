import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/dashboard/ui/dashboard_screen.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart'; // Add this
import 'package:supporttickets_app/main.dart';

@GenerateMocks([AuthRepository, SharedPreferences, TicketRepository]) // Add TicketRepository here
import 'main_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSharedPreferences mockPrefs;
  late MockTicketRepository mockTicketRepository; // Add this

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockPrefs = MockSharedPreferences();
    mockTicketRepository = MockTicketRepository(); // Add this
  });

  group('SupportTicketsApp Routing Tests', () {
    testWidgets('Should render LoginScreen when no token is present', (tester) async {
      when(mockPrefs.getString(ApiClient.tokenKey)).thenReturn(null);

      await tester.pumpWidget(
        SupportTicketsApp(
          authRepository: mockAuthRepository,
          ticketRepository: mockTicketRepository, // Inject here
          prefs: mockPrefs,
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('Should render DashboardScreen when token is present', (tester) async {
      when(mockPrefs.getString(ApiClient.tokenKey)).thenReturn('valid_token_123');
      // Mock the getTickets call because DashboardScreen calls it on initState
      when(mockTicketRepository.getTickets()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        SupportTicketsApp(
          authRepository: mockAuthRepository,
          ticketRepository: mockTicketRepository, // Inject here
          prefs: mockPrefs,
        ),
      );

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}