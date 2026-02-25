import 'package:flutter/material.dart';
import '../viewmodels/ticket_list_viewmodel.dart';

/// Bottom sheet component containing the filter options for the ticket list.
/// Separates UI filtering concerns from the main Dashboard screen.
class TicketFiltersBottomSheet extends StatelessWidget {
  final TicketListViewModel viewModel;

  const TicketFiltersBottomSheet({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Tickets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      viewModel.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Status Filter
              DropdownButtonFormField<String>(
                // CORREÇÃO: Utilização de initialValue em vez do depreciado value
                initialValue: viewModel.statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                ],
                onChanged: (value) => viewModel.setStatusFilter(value),
              ),
              const SizedBox(height: 16),

              // Assignee Filter (Only visible if the user is a supporter / has customers)
              if (viewModel.customers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    // CORREÇÃO: Utilização de initialValue em vez do depreciado value
                    initialValue: viewModel.assigneeFilter,
                    decoration: InputDecoration(
                      labelText: 'Assigned To',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Anyone')),
                      DropdownMenuItem(value: 'me', child: Text('Assigned to Me')),
                      DropdownMenuItem(value: 'unassigned', child: Text('Unassigned')),
                    ],
                    onChanged: (value) => viewModel.setAssigneeFilter(value),
                  ),
                ),

              // Customer Filter (Only visible if the user is a supporter)
              if (viewModel.customers.isNotEmpty)
                DropdownButtonFormField<int>(
                  // CORREÇÃO: Utilização de initialValue em vez do depreciado value
                  initialValue: viewModel.customerFilter,
                  decoration: InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('All Customers')),
                    ...viewModel.customers.map((customer) {
                      return DropdownMenuItem<int>(
                        value: customer['id'] as int,
                        child: Text(customer['name'] as String),
                      );
                    }),
                  ],
                  onChanged: (value) => viewModel.setCustomerFilter(value),
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  viewModel.loadTickets();
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 16), // SafeArea padding
            ],
          ),
        );
      }
    );
  }
}