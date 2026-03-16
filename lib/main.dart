import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

import 'core/network/api_client.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'features/profile/repositories/profile_repository.dart';
import 'features/tickets/repositories/ticket_repository.dart';
import 'features/work_sessions/repositories/work_session_repository.dart';
import 'features/work_sessions/viewmodels/work_session_viewmodel.dart';

import 'features/teams/repositories/team_repository.dart';
import 'features/teams/viewmodels/team_viewmodel.dart';
import 'features/vacations/repositories/vacation_repository.dart';
import 'features/vacations/viewmodels/vacation_viewmodel.dart';

// Novo import necessário para a injeção global do Perfil
import 'features/profile/viewmodels/profile_viewmodel.dart';

/// Application entry point. Ensures all global dependencies are initialized
/// before the widget tree is mounted.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  
  final apiClient = ApiClient(dio, prefs);
  
  ThemeController().initialize(prefs);
  
  // Initialize Repositories
  final authRepository = AuthRepository(apiClient: apiClient, prefs: prefs);
  final ticketRepository = TicketRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);
  final workSessionRepository = WorkSessionRepository(apiClient: apiClient);
  
  final teamRepository = TeamRepository(apiClient: apiClient);
  final vacationRepository = VacationRepository(apiClient: apiClient);

  runApp(
    // We inject the ViewModels at the root of the app using MultiProvider
    // so they persist across route changes and drawer toggles.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WorkSessionViewModel(repository: workSessionRepository)..loadCurrentSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => TeamViewModel(repository: teamRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => VacationViewModel(repository: vacationRepository),
        ),
        // Injeção do ProfileViewModel a nível global. 
        // A chamada loadProfileData() garante que os dados do utilizador (como o teamId) são logo colocados em cache.
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(profileRepository: profileRepository)..loadProfileData(),
        ),
      ],
      child: SupportTicketsApp(
        authRepository: authRepository,
        ticketRepository: ticketRepository,
        profileRepository: profileRepository,
        prefs: prefs,
      ),
    ),
  );
}

/// The root widget of the application.
/// Converted to StatefulWidget to manage global navigation and the authentication stream.
class SupportTicketsApp extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  final SharedPreferences prefs;

  const SupportTicketsApp({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
    required this.prefs,
  });

  @override
  State<SupportTicketsApp> createState() => _SupportTicketsAppState();
}

class _SupportTicketsAppState extends State<SupportTicketsApp> {
  /// Global navigator key allows us to perform navigation outside of standard UI flows
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late StreamSubscription<bool> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to global unauthenticated events (like 401 Token Expired)
    _authSubscription = ApiClient.unauthenticatedStream.stream.listen((isUnauthenticated) {
      if (isUnauthenticated) {
        _forceLogoutRedirect();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  /// Clears the backstack and securely redirects the user to the login screen
  void _forceLogoutRedirect() {
    if (_navigatorKey.currentState != null) {
      _navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            authRepository: widget.authRepository,
            ticketRepository: widget.ticketRepository,
            profileRepository: widget.profileRepository,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = widget.prefs.getString(ApiClient.tokenKey) != null && 
                     widget.prefs.getString(ApiClient.tokenKey)!.isNotEmpty;

    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey, // Bind the global navigator key
          title: 'Support Tickets',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController().themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: hasToken
              ? DashboardScreen(
                  authRepository: widget.authRepository,
                  ticketRepository: widget.ticketRepository,
                  profileRepository: widget.profileRepository,
                )
              : LoginScreen(
                  authRepository: widget.authRepository,
                  ticketRepository: widget.ticketRepository,
                  profileRepository: widget.profileRepository,
                ),
        );
      }
    );
  }
}