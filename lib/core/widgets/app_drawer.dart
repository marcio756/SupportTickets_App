import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/tickets/repositories/ticket_repository.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../theme/theme_controller.dart';
import 'placeholder_screen.dart';

/// Main navigation Sidebar (Drawer) of the application.
class AppDrawer extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  
  /// Identifies the current active route to highlight it visually.
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
    required this.currentRoute,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'A carregar...';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Fetches the user profile gracefully to populate the Drawer Header.
  Future<void> _loadProfile() async {
    try {
      final profile = await widget.profileRepository.getProfile();
      final data = profile.containsKey('data') ? profile['data'] : profile;
      if (mounted && data != null) {
        setState(() {
          _userName = data['name'] ?? 'Utilizador';
          _userEmail = data['email'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _userName = 'Utilizador');
    }
  }

  /// Logs out the user and clears the navigation stack completely.
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await widget.authRepository.logout();
    } catch (e) {
      debugPrint('Logout falhou na API, forçando localmente: $e');
    } finally {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
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
  }

  /// Reusable method to create identical instances of this Drawer 
  /// for generic placeholder screens.
  Widget _buildSelfDrawer(String newRoute) {
    return AppDrawer(
      authRepository: widget.authRepository,
      ticketRepository: widget.ticketRepository,
      profileRepository: widget.profileRepository,
      currentRoute: newRoute,
    );
  }

  /// Handles internal navigation. Closes drawer if already on route,
  /// otherwise uses pushReplacement to prevent heavy backstacks.
  void _navigateTo(String route, Widget screen) {
    if (widget.currentRoute == route) {
      Navigator.pop(context); // Just close the drawer
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ThemeController().isDarkMode;

    return Drawer(
      child: Column(
        children: [
          // Header with Avatar and User Info
          UserAccountsDrawerHeader(
            accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(_userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.blueAccent),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: 'Dashboard',
                  onTap: () => _navigateTo('Dashboard', PlaceholderScreen(title: 'Dashboard', drawer: _buildSelfDrawer('Dashboard'))),
                ),
                _buildNavItem(
                  icon: Icons.confirmation_number_rounded,
                  title: 'Tickets',
                  route: 'Tickets',
                  // Tickets is currently mapped to our DashboardScreen logic
                  onTap: () => _navigateTo('Tickets', DashboardScreen(
                    authRepository: widget.authRepository,
                    ticketRepository: widget.ticketRepository,
                    profileRepository: widget.profileRepository,
                  )),
                ),
                _buildNavItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  route: 'Users',
                  onTap: () => _navigateTo('Users', PlaceholderScreen(title: 'Users', drawer: _buildSelfDrawer('Users'))),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  route: 'Profile',
                  onTap: () => _navigateTo('Profile', PlaceholderScreen(title: 'Profile', drawer: _buildSelfDrawer('Profile'))),
                ),
              ],
            ),
          ),

          const Divider(),

          // Theme Switcher & Logout (Footer Area)
          ListenableBuilder(
            listenable: ThemeController(),
            builder: (context, _) {
              return SwitchListTile(
                title: const Text('Modo Escuro'),
                secondary: Icon(themeMode ? Icons.dark_mode : Icons.light_mode),
                value: ThemeController().isDarkMode,
                onChanged: (value) => ThemeController().toggleTheme(),
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Terminar Sessão', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Helper to generate visually consistent list items
  Widget _buildNavItem({required IconData icon, required String title, required String route, required VoidCallback onTap}) {
    final isSelected = widget.currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : null),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blueAccent : null,
        )
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}