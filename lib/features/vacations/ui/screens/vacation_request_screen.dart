import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vacation_request.dart';
import '../../viewmodels/vacation_viewmodel.dart';
import '../../utils/date_validator.dart';
import 'package:intl/intl.dart';

/// Form screen dedicated to constructing and submitting a new vacation request payload.
class VacationRequestScreen extends StatefulWidget {
  final String userId;
  final String teamId;

  // teamId defaults to a placeholder for now, assuming it will be retrieved from the Auth/User state context.
  const VacationRequestScreen({super.key, required this.userId, this.teamId = 'team_1'});

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _validationError;

  /// Invokes the native date picker and resolves the state mutation safely.
  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart 
        ? (_startDate ?? DateTime.now()) 
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date to maintain chronological integrity
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
        _validationError = DateValidator.validateVacationDates(_startDate, _endDate);
      });
    }
  }

  Future<void> _submitForm() async {
    final error = DateValidator.validateVacationDates(_startDate, _endDate);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    final totalDays = _endDate!.difference(_startDate!).inDays + 1;

    final request = VacationRequest(
      userId: widget.userId,
      teamId: widget.teamId,
      startDate: _startDate!,
      endDate: _endDate!,
      totalDays: totalDays,
      status: VacationStatus.pending,
    );

    final success = await Provider.of<VacationViewModel>(context, listen: false)
        .submitRequest(request);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido de férias submetido com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isLoading = context.watch<VacationViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pedido de Férias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_validationError != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.red.shade100,
                child: Text(
                  _validationError!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ListTile(
              title: const Text('Data de Início'),
              subtitle: Text(_startDate == null ? 'Selecionar' : dateFormat.format(_startDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data de Fim'),
              subtitle: Text(_endDate == null ? 'Selecionar' : dateFormat.format(_endDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: false),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submeter Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}