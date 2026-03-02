import 'package:flutter/material.dart';
import '../viewmodels/ticket_list_viewmodel.dart';

/// Bottom sheet component for filtering the ticket list.
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Tickets',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.onSurface
                      ),
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
                
                DropdownButtonFormField<String>(
                  initialValue: viewModel.statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

                if (viewModel.customers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      initialValue: viewModel.assigneeFilter,
                      decoration: InputDecoration(
                        labelText: 'Assigned To',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Anyone')),
                        DropdownMenuItem(value: 'me', child: Text('Assigned to Me')),
                        DropdownMenuItem(value: 'unassigned', child: Text('Unassigned')),
                      ],
                      onChanged: (value) => viewModel.setAssigneeFilter(value),
                    ),
                  ),

                if (viewModel.customers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<int>(
                      initialValue: viewModel.customerFilter,
                      decoration: InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  ),

                if (viewModel.tags.isNotEmpty)
                  DropdownButtonFormField<int>(
                    initialValue: viewModel.tagFilter,
                    decoration: InputDecoration(
                      labelText: 'Tag',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('All Tags')),
                      ...viewModel.tags.map((tag) {
                        return DropdownMenuItem<int>(
                          value: tag['id'] as int,
                          child: Text(tag['name'] as String),
                        );
                      }),
                    ],
                    onChanged: (value) => viewModel.setTagFilter(value),
                  ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    viewModel.loadTickets();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Apply Filters', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
                const SizedBox(height: 16), 
              ],
            ),
          ),
        );
      }
    );
  }
}