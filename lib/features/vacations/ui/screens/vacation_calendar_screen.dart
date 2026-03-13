import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/vacation_viewmodel.dart';
import '../../models/vacation_request.dart';

/// Displays a unified calendar view mapping out approved vacations across the team.
class VacationCalendarScreen extends StatefulWidget {
  final String userId;

  const VacationCalendarScreen({super.key, required this.userId});

  @override
  State<VacationCalendarScreen> createState() => _VacationCalendarScreenState();
}

class _VacationCalendarScreenState extends State<VacationCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Dispatch the fetch command immediately after the widget is inserted into the tree.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Férias'),
      ),
      body: Consumer<VacationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar calendário: ${viewModel.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Column(
            children: [
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

  /// Renders the list of vacations specific to the currently selected calendar day.
  Widget _buildEventList(List<VacationRequest> allVacations) {
    final selectedEvents = _selectedDay == null 
        ? <VacationRequest>[] 
        : _getVacationsForDay(_selectedDay!, allVacations);

    if (selectedEvents.isEmpty) {
      return const Center(child: Text('Sem férias marcadas para este dia.'));
    }

    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return ListTile(
          leading: const Icon(Icons.beach_access, color: Colors.blue),
          title: Text('Utilizador: ${event.userId}'),
          subtitle: Text('Estado: ${event.status.name} | Dias: ${event.totalDays}'),
        );
      },
    );
  }
}