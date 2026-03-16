import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/vacation_viewmodel.dart';
import '../../models/vacation_request.dart';

/// Displays a unified calendar view mapping out approved vacations across the team.
class VacationCalendarScreen extends StatefulWidget {
  final String userId;
  final Widget drawer; // Injeção do menu lateral

  const VacationCalendarScreen({super.key, required this.userId, required this.drawer});

  @override
  State<VacationCalendarScreen> createState() => _VacationCalendarScreenState();
}

class _VacationCalendarScreenState extends State<VacationCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VacationViewModel>(context, listen: false)
          .loadVacations(widget.userId);
    });
  }

  /// Extracts approved vacation days from the global list to map onto the calendar UI.
  List<VacationRequest> _getVacationsForDay(DateTime day, List<VacationRequest> allVacations) {
    return allVacations.where((vacation) {
      if (vacation.status != VacationStatus.approved) return false;
      
      final isAfterOrSameStart = day.isAfter(vacation.startDate) || isSameDay(day, vacation.startDate);
      final isBeforeOrSameEnd = day.isBefore(vacation.endDate) || isSameDay(day, vacation.endDate);
      
      return isAfterOrSameStart && isBeforeOrSameEnd;
    }).toList();
  }

  /// Calculates the total approved vacation days for the current year to enforce the 22-day limit visually.
  int _calculateUsedDays(List<VacationRequest> allVacations) {
    final currentYear = DateTime.now().year;
    int usedDays = 0;
    for (var vacation in allVacations) {
      if (vacation.status == VacationStatus.approved && vacation.startDate.year == currentYear) {
        usedDays += vacation.totalDays;
      }
    }
    return usedDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacation Calendar'),
      ),
      drawer: widget.drawer, // Ativa o botão Hamburger do menu
      body: Consumer<VacationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Text(
                'Error loading calendar: ${viewModel.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final usedDays = _calculateUsedDays(viewModel.vacations);
          final remainingDays = 22 - usedDays;

          return Column(
            children: [
              _buildVacationCounters(usedDays, remainingDays),
              TableCalendar<VacationRequest>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getVacationsForDay(day, viewModel.vacations),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: _buildEventList(viewModel.vacations),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the top visual counter for used and remaining vacation days.
  Widget _buildVacationCounters(int usedDays, int remainingDays) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCounterCard('Used Days', usedDays.toString(), Colors.orange),
          _buildCounterCard('Remaining', remainingDays.toString(), Colors.green),
          _buildCounterCard('Total Limit', '22', Colors.blue),
        ],
      ),
    );
  }

  /// Helper to build a single counter card.
  Widget _buildCounterCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2), // Correção do deprecated withOpacity
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// Renders the list of vacations specific to the currently selected calendar day.
  Widget _buildEventList(List<VacationRequest> allVacations) {
    final selectedEvents = _selectedDay == null 
        ? <VacationRequest>[] 
        : _getVacationsForDay(_selectedDay!, allVacations);

    if (selectedEvents.isEmpty) {
      return const Center(child: Text('No vacations scheduled for this day.'));
    }

    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return ListTile(
          leading: const Icon(Icons.beach_access, color: Colors.blue),
          title: Text('User: ${event.userId}'),
          subtitle: Text('Status: ${event.status.name} | Days: ${event.totalDays}'),
        );
      },
    );
  }
}