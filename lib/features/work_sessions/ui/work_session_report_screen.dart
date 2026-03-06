import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../repositories/work_session_repository.dart';
import '../viewmodels/work_session_report_viewmodel.dart';

/// Screen responsible for displaying the work session history and reports.
/// Accessible at any time regardless of the user's active work session state.
class WorkSessionReportScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const WorkSessionReportScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<WorkSessionReportScreen> createState() => _WorkSessionReportScreenState();
}

class _WorkSessionReportScreenState extends State<WorkSessionReportScreen> {
  late final WorkSessionReportViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();
  String _userRole = 'supporter';

  @override
  void initState() {
    super.initState();
    _viewModel = WorkSessionReportViewModel(
      repository: WorkSessionRepository(apiClient: widget.authRepository.apiClient),
    );
    _checkRoleAndLoad();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _viewModel.loadMore();
      }
    });
  }

  Future<void> _checkRoleAndLoad() async {
    try {
      final profile = await widget.profileRepository.getProfile();
      final data = profile.containsKey('data') ? profile['data'] : profile;
      if (mounted) {
        setState(() => _userRole = data['role'] ?? 'supporter');
      }
    } catch (_) {}
    _viewModel.loadReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _viewModel.setFilters(userId: _viewModel.selectedUserId, date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Sessions Report', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Clear Filters',
            onPressed: _viewModel.clearFilters,
          )
        ],
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'WorkSessions',
      ),
      // The guard was removed here. The screen is now directly accessible.
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _viewModel.loadReports,
            child: Column(
              children: [
                _buildSummaryCard(colorScheme),
                _buildFilters(colorScheme),
                Expanded(
                  child: _viewModel.sessions.isEmpty
                      ? const Center(child: Text('No sessions found for the given filters.'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: _viewModel.sessions.length + (_viewModel.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _viewModel.sessions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildSessionCard(_viewModel.sessions[index], colorScheme);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Worked Time', style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${_viewModel.summary['total_hours']}h ${_viewModel.summary['total_minutes']}m',
                style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(Icons.access_time_filled, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (_userRole == 'admin' && _viewModel.usersList.isNotEmpty) ...[
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _viewModel.selectedUserId,
                decoration: InputDecoration(
                  labelText: 'User',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Users')),
                  ..._viewModel.usersList.map((u) => DropdownMenuItem(
                        value: u['id'].toString(),
                        child: Text(u['name'].toString()),
                      )),
                ],
                onChanged: (val) => _viewModel.setFilters(userId: val, date: _viewModel.selectedDate),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _viewModel.selectedDate != null 
                          ? "${_viewModel.selectedDate!.day}/${_viewModel.selectedDate!.month}/${_viewModel.selectedDate!.year}"
                          : "Any",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, ColorScheme colorScheme) {
    final bool isCompleted = session['status'] == 'completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(session['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (session['status'] as String).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: isCompleted ? Colors.green.shade800 : Colors.blue.shade800
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_userRole == 'admin' && session['user'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(session['user']['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start - End', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${session['started_at']} - ${session['ended_at'] ?? 'Ongoing'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      session['total_time_formatted'] ?? '-', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 16)
                    ),
                  ],
                ),
              ],
            ),
            if ((session['pauses_count'] ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.pause_circle_outline, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${session['pauses_count']} pauses recorded', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}