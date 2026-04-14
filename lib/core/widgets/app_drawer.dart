// Ficheiro: lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/tickets/repositories/ticket_repository.dart';
import '../../features/notifications/repositories/notification_repository.dart';
import '../../features/tags/repositories/tag_repository.dart';
import '../../features/activity_logs/repositories/activity_log_repository.dart';
import '../../features/users/repositories/user_repository.dart';
import '../../features/announcements/repositories/announcement_repository.dart';

import '../../features/auth/ui/login_screen.dart';
import '../../features/tickets/ui/ticket_list_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/users/ui/user_management_screen.dart';
import '../../features/users/viewmodels/user_management_viewmodel.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/tags/ui/tag_management_screen.dart';
import '../../features/activity_logs/ui/activity_log_screen.dart';
import '../../features/work_sessions/ui/components/work_session_timer_widget.dart';
import '../../features/work_sessions/ui/work_session_report_screen.dart';

import '../../features/teams/ui/screens/team_screen.dart';
import '../../features/teams/ui/screens/admin_team_management_screen.dart';
import '../../features/vacations/ui/screens/vacation_list_screen.dart';
import '../../features/vacations/ui/screens/vacation_calendar_screen.dart';
import '../../features/announcements/ui/announcements_screen.dart';
import '../../features/announcements/viewmodels/announcement_viewmodel.dart';

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
  String _userId = '';
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
          _userId = data['id']?.toString() ?? '';
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
      debugPrint('Could not load notifications count.');
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
          
          if (_userRole == 'supporter')
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: WorkSessionTimerWidget(),
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
                  icon: Icons.campaign_rounded,
                  title: 'Announcements',
                  route: 'Announcements',
                  onTap: () => _navigateTo('Announcements', AnnouncementsScreen(
                    viewModel: AnnouncementViewModel(
                      repository: AnnouncementRepository(apiClient: widget.authRepository.apiClient),
                      profileRepository: widget.profileRepository,
                    ),
                    authRepository: widget.authRepository,
                    ticketRepository: widget.ticketRepository,
                    profileRepository: widget.profileRepository,
                  )),
                ),

                if (_userRole != 'admin')
                  _buildNavItem(
                    icon: Icons.confirmation_number_rounded,
                    title: 'Tickets',
                    route: 'Tickets',
                    onTap: () => _navigateTo('Tickets', TicketListScreen(
                      authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                    )),
                  ),

                if (_userRole == 'supporter') ...[
                  _buildNavItem(
                    icon: Icons.people_outline_rounded,
                    title: 'My Team',
                    route: 'MyTeam',
                    onTap: () => _navigateTo('MyTeam', TeamScreen(drawer: widget)), 
                  ),
                  _buildNavItem(
                    icon: Icons.beach_access_outlined,
                    title: 'My Vacations',
                    route: 'MyVacations',
                    onTap: () => _navigateTo('MyVacations', VacationListScreen(userId: _userId, drawer: widget)), 
                  ),
                ],
                  
                _buildNavItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
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
                
                if (_userRole == 'admin' || _userRole == 'supporter') ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
                    child: Text('Management', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ),

                  if (_userRole == 'admin') ...[
                    _buildNavItem(
                      icon: Icons.group_work_outlined,
                      title: 'Team Management',
                      route: 'ManageTeams',
                      onTap: () => _navigateTo('ManageTeams', AdminTeamManagementScreen(drawer: widget)), 
                    ),
                    _buildNavItem(
                      icon: Icons.beach_access_rounded,
                      title: 'Global Vacations',
                      route: 'ManageVacations',
                      onTap: () => _navigateTo('ManageVacations', VacationCalendarScreen(userId: _userId, drawer: widget)), 
                    ),
                  ],
                  
                  _buildNavItem(
                    icon: Icons.history_toggle_off_rounded,
                    title: 'Work Sessions',
                    route: 'WorkSessions',
                    onTap: () => _navigateTo('WorkSessions', WorkSessionReportScreen(
                      authRepository: widget.authRepository, ticketRepository: widget.ticketRepository, profileRepository: widget.profileRepository,
                    )),
                  ),

                  _buildNavItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Users',
                    route: 'Users',
                    onTap: () => _navigateTo('Users', UserManagementScreen(
                      viewModel: UserManagementViewModel(
                        userRepository: UserRepository(apiClient: widget.authRepository.apiClient),
                        profileRepository: widget.profileRepository,
                      ),
                      authRepository: widget.authRepository,
                      ticketRepository: widget.ticketRepository,
                      profileRepository: widget.profileRepository,
                    )),
                  ),
                  _buildNavItem(
                    icon: Icons.label_rounded,
                    title: 'Tag Management',
                    route: 'Tags',
                    onTap: () => _navigateTo('Tags', TagManagementScreen(
                      repository: TagRepository(apiClient: widget.authRepository.apiClient),
                      authRepository: widget.authRepository,
                      ticketRepository: widget.ticketRepository,
                      profileRepository: widget.profileRepository,
                    )),
                  ),
                  
                  if (_userRole == 'admin') ...[
                    _buildNavItem(
                      icon: Icons.history_rounded,
                      title: 'Activity Logs',
                      route: 'Logs',
                      onTap: () => _navigateTo('Logs', ActivityLogScreen(
                        repository: ActivityLogRepository(apiClient: widget.authRepository.apiClient),
                        authRepository: widget.authRepository,
                        ticketRepository: widget.ticketRepository,
                        profileRepository: widget.profileRepository,
                      )),
                    ),
                  ],
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

  Widget _buildNavItem({required IconData icon, required String title, required String route, required VoidCallback onTap, Widget? trailing}) {
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