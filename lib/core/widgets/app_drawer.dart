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
  String _userName = 'Loading...';
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
          _userName = data['name'] ?? 'User';
          _userEmail = data['email'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _userName = 'User');
    }
  }

  /// Logs out the user and clears the navigation stack completely.
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await widget.authRepository.logout();
    } catch (e) {
      debugPrint('Logout failed on API, forcing local cleanup: $e');
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

  /// Reusable method to create identical instances of this Drawer for different routes.
  /// * @param newRoute The route name for the new drawer instance.
  Widget _buildSelfDrawer(String newRoute) {
    return AppDrawer(
      authRepository: widget.authRepository,
      ticketRepository: widget.ticketRepository,
      profileRepository: widget.profileRepository,
      currentRoute: newRoute,
    );
  }

  /// Handles internal navigation. Closes drawer if already on route.
  void _navigateTo(String route, Widget screen) {
    if (widget.currentRoute == route) {
      Navigator.pop(context);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName, 
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)
            ),
            accountEmail: Text(
              _userEmail, 
              style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8))
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.onPrimary,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 24, color: colorScheme.primary),
              ),
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: 'Dashboard',
                  onTap: () => _navigateTo(
                    'Dashboard', 
                    PlaceholderScreen(title: 'Dashboard', drawer: _buildSelfDrawer('Dashboard'))
                  ),
                ),
                _buildNavItem(
                  icon: Icons.confirmation_number_rounded,
                  title: 'Tickets',
                  route: 'Tickets',
                  onTap: () => _navigateTo(
                    'Tickets', 
                    DashboardScreen(
                      authRepository: widget.authRepository,
                      ticketRepository: widget.ticketRepository,
                      profileRepository: widget.profileRepository,
                    )
                  ),
                ),
                _buildNavItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  route: 'Users',
                  onTap: () => _navigateTo(
                    'Users', 
                    PlaceholderScreen(title: 'Users', drawer: _buildSelfDrawer('Users'))
                  ),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  route: 'Profile',
                  onTap: () => _navigateTo(
                    'Profile', 
                    PlaceholderScreen(title: 'Profile', drawer: _buildSelfDrawer('Profile'))
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListenableBuilder(
            listenable: ThemeController(),
            builder: (context, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(themeMode ? Icons.dark_mode : Icons.light_mode),
                value: ThemeController().isDarkMode,
                onChanged: (value) => ThemeController().toggleTheme(),
              );
            }
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: colorScheme.error),
            title: Text('Logout', style: TextStyle(color: colorScheme.error)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Helper to generate visually consistent list items for navigation.
  Widget _buildNavItem({
    required IconData icon, 
    required String title, 
    required String route, 
    required VoidCallback onTap
  }) {
    final isSelected = widget.currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        )
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
    );
  }
}