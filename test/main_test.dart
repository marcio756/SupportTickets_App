import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/main.dart';
import 'package:supporttickets_app/features/auth/ui/login_screen.dart';
import 'package:supporttickets_app/features/dashboard/ui/dashboard_screen.dart';

@GenerateMocks([AuthRepository, TicketRepository, ProfileRepository])
import 'main_test.mocks.dart';

// Create a Dummy API Client to fulfill the getter requirements on the AuthRepository Mock
class DummyApiClient extends Fake implements ApiClient {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTicketRepository mockTicketRepository;
  late MockProfileRepository mockProfileRepository;
  late DummyApiClient dummyApiClient;

  // Iniciar o SetupGlobal da framework de testes com a biblioteca oficial do Firebase
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Instala um fake Firebase channel oficial compatível com o Pigeon
    setupFirebaseCoreMocks(); 
    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTicketRepository = MockTicketRepository();
    mockProfileRepository = MockProfileRepository();
    dummyApiClient = DummyApiClient();
    
    // Fulfill the missing dependency required by AppDrawer
    when(mockAuthRepository.apiClient).thenReturn(dummyApiClient);
  });

  group('SupportTicketsApp Routing Tests', () {
    testWidgets('Should render LoginScreen when token is absent', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(SupportTicketsApp(
        authRepository: mockAuthRepository,
        ticketRepository: mockTicketRepository,
        profileRepository: mockProfileRepository,
        prefs: prefs,
      ));

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Should render DashboardScreen when token is present', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({ApiClient.tokenKey: 'fake_token_123'});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(SupportTicketsApp(
        authRepository: mockAuthRepository,
        ticketRepository: mockTicketRepository,
        profileRepository: mockProfileRepository,
        prefs: prefs,
      ));

      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}