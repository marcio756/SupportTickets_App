import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'features/profile/repositories/profile_repository.dart';
import 'features/tickets/repositories/ticket_repository.dart';

/// Application entry point. Ensures all global dependencies are initialized
/// before the widget tree is mounted.
void main() async {
  // Required to interact with the Flutter engine before runApp is called
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Dependencies
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  
  // Initialize Architecture Layers
  final apiClient = ApiClient(dio, prefs);
  
  // Initialize Theme Controller globally
  ThemeController().initialize(prefs);
  
  // Injecting dependencies using named parameters as defined in our refactored repositories
  final authRepository = AuthRepository(apiClient: apiClient, prefs: prefs);
  final ticketRepository = TicketRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);

  runApp(
    SupportTicketsApp(
      authRepository: authRepository,
      ticketRepository: ticketRepository,
      profileRepository: profileRepository,
      prefs: prefs,
    ),
  );
}

/// The root widget of the application.
/// It dictates the global theme and initial routing logic based on authentication state.
class SupportTicketsApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Check if the user is already authenticated
    final hasToken = prefs.getString(ApiClient.tokenKey) != null && 
                     prefs.getString(ApiClient.tokenKey)!.isNotEmpty;

    // ListenableBuilder listens to theme changes and rebuilds the app instantly
    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, _) {
        return MaterialApp(
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
                  authRepository: authRepository,
                  ticketRepository: ticketRepository,
                  profileRepository: profileRepository,
                )
              : LoginScreen(
                  authRepository: authRepository,
                  ticketRepository: ticketRepository,
                  profileRepository: profileRepository,
                ),
        );
      }
    );
  }
}