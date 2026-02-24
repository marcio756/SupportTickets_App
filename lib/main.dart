import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
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
  final authRepository = AuthRepository(apiClient, prefs);
  final ticketRepository = TicketRepository(apiClient);

  runApp(
    SupportTicketsApp(
      authRepository: authRepository,
      ticketRepository: ticketRepository,
      prefs: prefs,
    ),
  );
}

/// The root widget of the application.
/// It dictates the global theme and initial routing logic based on authentication state.
class SupportTicketsApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final SharedPreferences prefs;

  const SupportTicketsApp({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the user is already authenticated
    final hasToken = prefs.getString(ApiClient.tokenKey) != null && 
                     prefs.getString(ApiClient.tokenKey)!.isNotEmpty;

    return MaterialApp(
      title: 'Support Tickets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: hasToken
          ? DashboardScreen(
              authRepository: authRepository,
              ticketRepository: ticketRepository,
            )
          : LoginScreen(
              authRepository: authRepository,
              ticketRepository: ticketRepository,
            ),
    );
  }
}