import 'package:flutter/material.dart';
import '../repositories/ticket_repository.dart';
import '../viewmodels/ticket_create_viewmodel.dart';
import '../../../core/widgets/form_field_skeleton.dart';
import '../../../core/widgets/progress_illusion_bar.dart';

/// Screen responsible for creating a new support ticket.
class TicketCreateScreen extends StatefulWidget {
  final TicketRepository ticketRepository;

  const TicketCreateScreen({
    super.key,
    required this.ticketRepository,
  });

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  late final TicketCreateViewModel _viewModel;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = TicketCreateViewModel(ticketRepository: widget.ticketRepository);
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (_viewModel.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket created successfully!'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else if (_viewModel.errorMessage != null && !_viewModel.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage!), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    }
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _viewModel.createTicket(
        _titleController.text, 
        _descriptionController.text,
        senderEmail: _emailController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const ProgressIllusionBar(isComplete: false);
              }
              return const SizedBox(height: 4.0);
            },
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Describe your issue',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: colorScheme.onSurface
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Uses Skeleton Loader for graceful loading experience
                    if (_viewModel.isLoadingCustomers)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: FormFieldSkeleton(),
                      )
                    else if (_viewModel.customers.isNotEmpty)
                      Column(
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: _viewModel.selectedCustomerId,
                            decoration: InputDecoration(
                              labelText: 'Select Customer',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                            ),
                            items: _viewModel.customers.map((customer) {
                              return DropdownMenuItem<int>(
                                value: customer['id'] as int,
                                child: Text(customer['name'] as String),
                              );
                            }).toList(),
                            onChanged: _viewModel.isLoading ? null : (value) {
                              _viewModel.setSelectedCustomer(value);
                              // Clear email when choosing a customer to avoid conflict
                              _emailController.clear();
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_viewModel.isLoading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'External Email Address',
                              hintText: 'user@example.com (Unregistered)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                            ),
                            onChanged: (value) {
                              // Reset Dropdown if user starts typing an email
                              if (value.isNotEmpty && _viewModel.selectedCustomerId != null) {
                                _viewModel.setSelectedCustomer(null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                
                    TextFormField(
                      controller: _titleController,
                      enabled: !_viewModel.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Issue Title',
                        hintText: 'e.g., Cannot access account',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter a title.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_viewModel.isLoading,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Detailed Description',
                        hintText: 'Explain the issue step by step...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter a description.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Ticket', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}