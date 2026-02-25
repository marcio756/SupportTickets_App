import 'package:flutter/material.dart';
import '../repositories/ticket_repository.dart';
import '../viewmodels/ticket_create_viewmodel.dart';

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
    super.dispose();
  }

  void _onViewModelChange() {
    if (_viewModel.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket criado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } else if (_viewModel.errorMessage != null && !_viewModel.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage!), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _viewModel.createTicket(_titleController.text, _descriptionController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Novo Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Descreva o seu problema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_viewModel.isLoadingCustomers)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_viewModel.customers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<int>(
                        initialValue: _viewModel.selectedCustomerId,
                        decoration: InputDecoration(
                          labelText: 'Selecione o Cliente (Atribuição do Ticket)',
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
                        },
                        validator: (value) {
                          if (value == null) return 'Por favor, selecione um cliente.';
                          return null;
                        },
                      ),
                    ),

                  TextFormField(
                    controller: _titleController,
                    enabled: !_viewModel.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Título do Problema',
                      hintText: 'Ex: Erro ao aceder à conta',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor, insira um título.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_viewModel.isLoading,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Descrição Detalhada',
                      hintText: 'Explique o que aconteceu passo a passo...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor, insira a descrição.';
                      return null;
                    },
                  ),
                  const Spacer(),
                  
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
                      child: _viewModel.isLoading
                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                          : const Text('Enviar Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}