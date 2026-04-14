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
import 'features/profile/viewmodels/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  final apiClient = ApiClient(dio, prefs);
  
  ThemeController().initialize(prefs);
  
  // Repositories initialization
  final authRepository = AuthRepository(apiClient: apiClient, prefs: prefs);
  final ticketRepository = TicketRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);
  final workSessionRepository = WorkSessionRepository(apiClient: apiClient);
  final teamRepository = TeamRepository(apiClient: apiClient);
  final vacationRepository = VacationRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        // Global Repository Injection
        Provider.value(value: authRepository),
        Provider.value(value: ticketRepository),
        Provider.value(value: profileRepository),
        Provider.value(value: workSessionRepository),
        Provider.value(value: teamRepository),
        Provider.value(value: vacationRepository),
        Provider.value(value: prefs),

        // Global ViewModel Injection
        ChangeNotifierProvider(
          create: (_) => WorkSessionViewModel(repository: workSessionRepository)..loadCurrentSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => TeamViewModel(repository: teamRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => VacationViewModel(repository: vacationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(profileRepository: profileRepository)..loadProfileData(),
        ),
      ],
      child: const SupportTicketsApp(),
    ),
  );
}

class SupportTicketsApp extends StatefulWidget {
  const SupportTicketsApp({super.key});

  @override
  State<SupportTicketsApp> createState() => _SupportTicketsAppState();
}

class _SupportTicketsAppState extends State<SupportTicketsApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late StreamSubscription<bool> _authSubscription;

  @override
  void initState() {
    super.initState();
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

  void _forceLogoutRedirect() {
    if (_navigatorKey.currentState != null) {
      // Ler as instâncias injetadas para satisfazer os construtores atuais dos ecrãs
      final authRepo = context.read<AuthRepository>();
      final ticketRepo = context.read<TicketRepository>();
      final profileRepo = context.read<ProfileRepository>();

      _navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            authRepository: authRepo,
            ticketRepository: ticketRepo,
            profileRepository: profileRepo,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing SharedPreferences via Provider instead of widget field
    final prefs = context.read<SharedPreferences>();
    final hasToken = prefs.getString(ApiClient.tokenKey) != null && 
                     prefs.getString(ApiClient.tokenKey)!.isNotEmpty;

    // Ler as instâncias injetadas para satisfazer os construtores atuais dos ecrãs
    final authRepo = context.read<AuthRepository>();
    final ticketRepo = context.read<TicketRepository>();
    final profileRepo = context.read<ProfileRepository>();

    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Support Tickets',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController().themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: hasToken 
              ? DashboardScreen(
                  authRepository: authRepo,
                  ticketRepository: ticketRepo,
                  profileRepository: profileRepo,
                ) 
              : LoginScreen(
                  authRepository: authRepo,
                  ticketRepository: ticketRepo,
                  profileRepository: profileRepo,
                ),
        );
      }
    );
  }
}