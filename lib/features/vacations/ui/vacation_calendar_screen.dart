import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';
import 'package:supporttickets_app/features/vacations/ui/components/team_vacation_section.dart';
import 'package:supporttickets_app/features/vacations/ui/vacation_request_screen.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_calendar_viewmodel.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_request_viewmodel.dart';

/// The main screen displaying the global vacation calendar.
/// Orchestrates the loading states and renders the hierarchical list of teams.
class VacationCalendarScreen extends StatefulWidget {
  const VacationCalendarScreen({super.key});

  @override
  State<VacationCalendarScreen> createState() => _VacationCalendarScreenState();
}

class _VacationCalendarScreenState extends State<VacationCalendarScreen> {
  final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    /**
     * Schedules the data fetch immediately after the first frame renders.
     * This avoids calling Provider methods directly during the build phase.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacationCalendarViewModel>().loadCalendar(_currentYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacation Calendar $_currentYear'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VacationCalendarViewModel>().loadCalendar(_currentYear);
            },
            tooltip: 'Refresh Calendar',
          ),
        ],
      ),
      body: Consumer<VacationCalendarViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(context, viewModel);
          }

          if (viewModel.teams.isEmpty) {
            return const Center(child: Text('No vacation records found for this year.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadCalendar(_currentYear),
            child: ListView.builder(
              itemCount: viewModel.teams.length,
              itemBuilder: (context, index) {
                final team = viewModel.teams[index];
                return TeamVacationSection(team: team);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /**
           * Navigates to the request screen while injecting its specific ViewModel.
           * Waits for the result to determine if a successful booking occurred, 
           * triggering a background refresh of the calendar data to maintain consistency.
           */
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (context) => VacationRequestViewModel(
                  repository: context.read<VacationRepository>(),
                ),
                child: const VacationRequestScreen(),
              ),
            ),
          );

          if (result == true && context.mounted) {
            context.read<VacationCalendarViewModel>().loadCalendar(_currentYear);
          }
        },
        tooltip: 'Request Vacation',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Renders a fallback UI when the network request fails, allowing the user to retry.
  /// Keeps the user engaged instead of showing a blank screen on network drops.
  Widget _buildErrorState(BuildContext context, VacationCalendarViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48.0, color: Colors.redAccent),
            const SizedBox(height: 16.0),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadCalendar(_currentYear),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}