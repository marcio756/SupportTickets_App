// Ficheiro: lib/features/announcements/ui/announcements_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/announcement_viewmodel.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Screen to view global announcements and allow admins/supporters to send emails.
/// Features a premium design with Skeleton Screens.
class AnnouncementsScreen extends StatefulWidget {
  final AnnouncementViewModel viewModel;
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const AnnouncementsScreen({
    super.key,
    required this.viewModel,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadAnnouncements(reset: true);
    });
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CreateAnnouncementSheet(viewModel: widget.viewModel),
      ),
    );
  }

  IconData _getIconForAudience(String audience) {
    if (audience == 'all_customers') return Icons.public_rounded;
    return Icons.people_alt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Email Announcements', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => widget.viewModel.loadAnnouncements(reset: true),
          ),
        ],
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Announcements',
      ),
      floatingActionButton: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.canCreate) {
            return FloatingActionButton.extended(
              onPressed: _showCreateBottomSheet,
              icon: const Icon(Icons.send_rounded),
              label: const Text('New Notice'),
              elevation: 4,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading && widget.viewModel.announcements.isEmpty) {
            return _buildSkeletonList();
          }

          if (widget.viewModel.errorMessage != null && widget.viewModel.announcements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.error.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      widget.viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => widget.viewModel.loadAnnouncements(reset: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    )
                  ],
                ),
              ),
            );
          }

          if (widget.viewModel.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forward_to_inbox_rounded, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No notices sent yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your email announcements will appear here.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.viewModel.loadAnnouncements(reset: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!widget.viewModel.isLoadingMore &&
                    widget.viewModel.hasMore &&
                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  widget.viewModel.loadAnnouncements();
                  return true;
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: widget.viewModel.announcements.length + (widget.viewModel.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == widget.viewModel.announcements.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final ann = widget.viewModel.announcements[index];
                  final isGlobal = ann.targetAudience == 'all_customers';
                  final formattedDate = DateFormat('MMM dd, yyyy • HH:mm').format(ann.createdAt.toLocal());

                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: colorScheme.primary, width: 6)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ann.subject,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_getIconForAudience(ann.targetAudience), size: 14, color: colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          isGlobal ? 'ALL CUSTOMERS' : 'SPECIFIC',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ann.message,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 200, height: 20, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
                  Container(width: 60, height: 24, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12))),
                ],
              ),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 14, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 8),
              Container(width: 250, height: 14, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
              const Spacer(),
              Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
            ],
          ),
        );
      },
    );
  }
}

class _CreateAnnouncementSheet extends StatefulWidget {
  final AnnouncementViewModel viewModel;

  const _CreateAnnouncementSheet({required this.viewModel});

  @override
  State<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  
  String _targetAudience = 'all_customers';
  final List<int> _selectedCustomerIds = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Atrasar a chamada para o próximo frame de build para evitar exceções do Flutter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadCustomers(reset: true);
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.loadCustomers(reset: true, search: query);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_targetAudience == 'specific_customers' && _selectedCustomerIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione pelo menos um cliente.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final success = await widget.viewModel.createAnnouncement(
        _subjectCtrl.text.trim(),
        _messageCtrl.text.trim(),
        _targetAudience,
        _selectedCustomerIds,
      );
      
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anúncio publicado e emails na fila de envio!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Agora o erro que causava a "falha silenciosa" será apresentado no ecrã.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.viewModel.errorMessage ?? 'Ocorreu um erro ao enviar os emails.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.send_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              const Text(
                'Enviar Anúncio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _subjectCtrl,
                      hintText: 'Assunto do Email',
                      validator: (v) => v!.trim().isEmpty ? 'O assunto é obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _targetAudience,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        labelText: 'Seleção de Destinatários',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all_customers', child: Text('Todos os Clientes')),
                        DropdownMenuItem(value: 'specific_customers', child: Text('Clientes Específicos')),
                      ],
                      onChanged: (v) => setState(() => _targetAudience = v!),
                    ),
                    if (_targetAudience == 'specific_customers') ...[
                      const SizedBox(height: 16),
                      Text('Selecione os Clientes:', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      // Barra de pesquisa
                      TextFormField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar nome ou email...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista paginada
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListenableBuilder(
                          listenable: widget.viewModel,
                          builder: (context, _) {
                            if (widget.viewModel.isCustomersLoading && widget.viewModel.customers.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            if (widget.viewModel.customers.isEmpty) {
                              return Center(
                                child: Text('Nenhum cliente encontrado.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                              );
                            }

                            return NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!widget.viewModel.isCustomersLoadingMore &&
                                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                                  widget.viewModel.loadCustomers();
                                  return true;
                                }
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: widget.viewModel.customers.length + (widget.viewModel.isCustomersLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == widget.viewModel.customers.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                                    );
                                  }

                                  final customer = widget.viewModel.customers[index];
                                  final id = customer['id'] as int;
                                  final isSelected = _selectedCustomerIds.contains(id);
                                  
                                  return CheckboxListTile(
                                    title: Text(customer['name'] ?? 'Desconhecido', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    subtitle: Text(customer['email'] ?? '', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                    value: isSelected,
                                    activeColor: colorScheme.primary,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedCustomerIds.add(id);
                                        } else {
                                          _selectedCustomerIds.remove(id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _messageCtrl,
                      hintText: 'Corpo da Mensagem',
                      maxLines: 5,
                      validator: (v) => v!.trim().isEmpty ? 'A mensagem não pode estar vazia' : null,
                    ),
                    SizedBox(height: viewInsets > 0 ? viewInsets + 20 : 0),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.viewModel.isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: widget.viewModel.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enviar Emails', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          )
        ],
      ),
    );
  }
}