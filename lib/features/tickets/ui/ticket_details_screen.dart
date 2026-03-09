import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../viewmodels/ticket_details_viewmodel.dart';
import 'components/message_bubble.dart';
import 'components/message_bubble_skeleton.dart';
import 'components/ticket_chat_input.dart';
import 'components/ticket_status_badge.dart';
import 'components/ticket_status_dropdown.dart';
import 'components/support_time_display.dart';
import 'components/ticket_tags_dialog.dart';
import '../../../core/widgets/progress_illusion_bar.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Ticket ticket;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late final TicketDetailsViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = TicketDetailsViewModel(
      ticketRepository: widget.ticketRepository,
      profileRepository: widget.profileRepository,
      ticket: widget.ticket,
    );
    
    _viewModel.initialize().then((_) {
      _scrollToBottom();
    });

    _viewModel.addListener(() {
      if (!_viewModel.isSending && _viewModel.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TicketTagsDialog(
          availableTags: _viewModel.availableTags,
          currentTags: _viewModel.ticket.tags,
          onSave: (List<int> selectedIds) async {
            final success = await _viewModel.syncTicketTags(selectedIds);
            if (!success && context.mounted && _viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_viewModel.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Ticket #${widget.ticket.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 1,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final bool isTicketInProgress = _viewModel.ticket.status == 'in_progress';
              final bool ticketHasAssignee = _viewModel.ticket.assigneeId != null;
              final bool isAssignedToMe = ticketHasAssignee && _viewModel.ticket.assigneeId == _viewModel.currentUserId;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAssignedToMe && isTicketInProgress)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SupportTimeDisplay(supportTime: _viewModel.ticket.supportTime ?? '--:--:--'),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: TicketStatusBadge(status: _viewModel.ticket.status),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              // Renders a fast illusion bar while background operations are resolving optimistically
              if (_viewModel.isUpdatingStatus || _viewModel.isClaiming) {
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
          if (_viewModel.errorMessage != null && _viewModel.messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 50),
                    const SizedBox(height: 16),
                    Text(_viewModel.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _viewModel.initialize,
                      child: const Text('Tentar Novamente'),
                    )
                  ],
                ),
              ),
            );
          }

          final bool isTicketInProgress = _viewModel.ticket.status == 'in_progress';
          final bool ticketHasAssignee = _viewModel.ticket.assigneeId != null;
          final bool isAssignedToMe = ticketHasAssignee && _viewModel.ticket.assigneeId == _viewModel.currentUserId;

          return Column(
            children: [
              Container(
                color: colorScheme.surface,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      _viewModel.ticket.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      'Clique para ver detalhes e opções',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top: 0),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _viewModel.ticket.description,
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                      ),
                      
                      const SizedBox(height: 16),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 8),

                      // Tags Display & Edit Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.label_outline, size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _viewModel.ticket.tags.isEmpty 
                                ? Text(
                                    'Nenhuma tag associada', 
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontStyle: FontStyle.italic)
                                  )
                                : Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: _viewModel.ticket.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: colorScheme.primaryContainer,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          tag['name']?.toString() ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          if (_viewModel.isSupporter)
                            IconButton(
                              icon: Icon(Icons.edit_note, color: colorScheme.primary),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Gerir Tags',
                              onPressed: () => _showTagsDialog(context),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildUserInfoRow(
                        Icons.person, 
                        'Cliente', 
                        _viewModel.ticket.customerName ?? 'Desconhecido', 
                        colorScheme.onSurfaceVariant
                      ),

                      if (ticketHasAssignee)
                        _buildUserInfoRow(
                          Icons.support_agent, 
                          'Suporte', 
                          isAssignedToMe ? '${_viewModel.ticket.assigneeName!} (Tu)' : _viewModel.ticket.assigneeName!, 
                          colorScheme.primary
                        )
                      else if (_viewModel.isSupporter) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            icon: _viewModel.isClaiming 
                                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                                : const Icon(Icons.pan_tool, size: 18),
                            label: const Text('Reivindicar Ticket'),
                            onPressed: _viewModel.isClaiming ? null : _viewModel.claimTicket,
                          ),
                        ),
                      ],

                      if (_viewModel.isSupporter) ...[
                        const SizedBox(height: 12),
                        Divider(color: colorScheme.outlineVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Alterar Estado do Ticket:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        TicketStatusDropdown(
                          currentStatus: _viewModel.ticket.status,
                          isLoading: false, // UI Optimista: a dropdown não precisa bloquear
                          onStatusChanged: (newStatus) {
                            _viewModel.updateStatus(newStatus);
                          },
                        ),
                        const SizedBox(height: 8),
                      ]
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: _viewModel.isLoading 
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (context, index) => MessageBubbleSkeleton(isSender: index % 2 == 0),
                      )
                    : _viewModel.messages.isEmpty
                        ? Center(child: Text('Ainda não há mensagens. Comece a conversa!', style: TextStyle(color: colorScheme.onSurfaceVariant)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _viewModel.messages.length,
                            itemBuilder: (context, index) {
                              final message = _viewModel.messages[index];
                              return Opacity(
                                opacity: message.id < 0 ? 0.6 : 1.0, // Temporary optimistic state
                                child: MessageBubble(message: message),
                              );
                            },
                          ),
              ),

              TicketChatInput(
                isSending: false, // Optimistic UI: input always unlocked
                isEnabled: isTicketInProgress,
                onSendMessage: (text, attachment) async {
                  final success = await _viewModel.sendMessage(text, attachment: attachment);
                  
                  if (!success && mounted && _viewModel.errorMessage != null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_viewModel.errorMessage!),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}