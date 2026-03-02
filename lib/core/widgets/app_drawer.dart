import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/tickets/repositories/ticket_repository.dart';
import '../../features/notifications/repositories/notification_repository.dart';
import '../../features/tags/repositories/tag_repository.dart';
import '../../features/activity_logs/repositories/activity_log_repository.dart';

import '../../features/auth/ui/login_screen.dart';
import '../../features/tickets/ui/ticket_list_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/users/ui/user_management_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/tags/ui/tag_management_screen.dart';
import '../../features/activity_logs/ui/components/activity_log_screen.dart';

import '../theme/theme_controller.dart';

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
  String _userRole = ''; 
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUnreadNotificationsCount();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.profileRepository.getProfile();
      final data = profile.containsKey('data') ? profile['data'] : profile;
      if (mounted && data != null) {
        setState(() {
          _userName = data['name'] ?? 'User';
          _userEmail = data['email'] ?? '';
          _userRole = data['role'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _userName = 'User');
    }
  }

  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final notificationRepo = NotificationRepository(apiClient: widget.authRepository.apiClient);
      final notifications = await notificationRepo.getNotifications();
      
      final unreadCount = notifications.where((n) => !n.isRead).length;
      
      if (mounted) {
        setState(() {
          _unreadNotifications = unreadCount;
        });
      }
    } catch (e) {
      debugPrint('Não foi possível carregar o contador de notificações.');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await widget.authRepository.logout();
    } catch (e) {
      debugPrint('Logout failed on API: $e');
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

  void _navigateTo(String route, Widget screen) {
    if (widget.currentRoute == route) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
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
          InkWell(
            onTap: () => _navigateTo('Profile', ProfileScreen(
              authRepository: widget.authRepository,
              ticketRepository: widget.ticketRepository,
              profileRepository: widget.profileRepository,
            )),
            child: UserAccountsDrawerHeader(
              accountName: Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
              accountEmail: Text(_userEmail, style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8))),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colorScheme.onPrimary,
                child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: TextStyle(fontSize: 24, color: colorScheme.primary)),
              ),
              decoration: BoxDecoration(color: colorScheme.primary),
              margin: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: 'Dashboard',
                  onTap: () => _navigateTo('Dashboard', DashboardScreen(
                    authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                  )),
                ),
                _buildNavItem(
                  icon: Icons.confirmation_number_rounded,
                  title: 'Tickets',
                  route: 'Tickets',
                  onTap: () => _navigateTo('Tickets', TicketListScreen(
                    authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                  )),
                ),
                _buildNavItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificações',
                  route: 'Notifications',
                  trailing: _unreadNotifications > 0 ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: TextStyle(color: colorScheme.onError, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ) : null,
                  onTap: () => _navigateTo('Notifications', NotificationsScreen(
                    authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                  )),
                ),
                if (_userRole != 'customer' && _userRole.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
                    child: Text('Administração', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ),
                  _buildNavItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Utilizadores',
                    route: 'Users',
                    onTap: () => _navigateTo('Users', UserManagementScreen(
                      authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                    )),
                  ),
                  _buildNavItem(
                    icon: Icons.label_rounded,
                    title: 'Gestão de Tags',
                    route: 'Tags',
                    onTap: () => _navigateTo('Tags', TagManagementScreen(
                      repository: TagRepository(apiClient: widget.authRepository.apiClient),
                    )),
                  ),
                  _buildNavItem(
                    icon: Icons.history_rounded,
                    title: 'Logs de Atividade',
                    route: 'Logs',
                    onTap: () => _navigateTo('Logs', ActivityLogScreen(
                      repository: ActivityLogRepository(apiClient: widget.authRepository.apiClient),
                    )),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          ListenableBuilder(
            listenable: ThemeController(),
            builder: (context, _) => SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: Icon(themeMode ? Icons.dark_mode : Icons.light_mode),
              value: ThemeController().isDarkMode,
              onChanged: (value) => ThemeController().toggleTheme(),
            )
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

  Widget _buildNavItem({
    required IconData icon, 
    required String title, 
    required String route, 
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isSelected = widget.currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? colorScheme.primary : colorScheme.onSurface)),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
      trailing: trailing,
    );
  }
}