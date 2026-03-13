import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supporttickets_app/features/vacations/viewmodels/vacation_request_viewmodel.dart';

/// The screen where a user can select dates to request a new vacation.
/// Connects to VacationRequestViewModel to handle state and API submission.
class VacationRequestScreen extends StatelessWidget {
  const VacationRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Vacation'),
      ),
      body: Consumer<VacationRequestViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select the period you want to take off.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24.0),
                
                // Start Date Picker
                _buildDateSelector(
                  context: context,
                  label: 'Start Date',
                  selectedDate: viewModel.startDate,
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
                const SizedBox(height: 16.0),
                
                // End Date Picker
                _buildDateSelector(
                  context: context,
                  label: 'End Date',
                  selectedDate: viewModel.endDate,
                  onTap: () => _selectDate(context, isStartDate: false),
                ),
                const SizedBox(height: 32.0),

                // Error Message Display
                if (viewModel.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),

                const Spacer(),

                // Submit Button
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final success = await viewModel.submitRequest();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vacation request submitted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop(true); // Return true to signal a refresh is needed
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text('Submit Request'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Helper method to render a visually consistent date selection box.
  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    final dateText = selectedDate != null
        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
        : 'Tap to select...';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  /// Opens the native Flutter date picker dialog.
  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final viewModel = context.read<VacationRequestViewModel>();
    final initialDate = isStartDate 
        ? (viewModel.startDate ?? DateTime.now()) 
        : (viewModel.endDate ?? viewModel.startDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(), // Prevent booking in the past
      lastDate: DateTime(DateTime.now().year + 2), // Allow booking up to 2 years in advance
    );

    if (picked != null) {
      if (isStartDate) {
        viewModel.setStartDate(picked);
      } else {
        viewModel.setEndDate(picked);
      }
    }
  }
}