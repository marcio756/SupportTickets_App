import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../viewmodels/ticket_details_viewmodel.dart';
import 'components/message_bubble.dart';
import 'components/ticket_chat_input.dart';
import 'components/ticket_status_badge.dart';
import 'components/ticket_status_dropdown.dart';

/// Screen displaying the details and conversation thread of a specific ticket.
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

  /// Helper to render User info cleanly
  Widget _buildUserInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Ticket #${widget.ticket.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: TicketStatusBadge(status: _viewModel.ticket.status),
                ),
              );
            }
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null && _viewModel.messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                    const SizedBox(height: 16),
                    Text(_viewModel.errorMessage!, textAlign: TextAlign.center),
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
          
          // Helper bools to make rendering logic easier to read
          final bool ticketHasAssignee = _viewModel.ticket.assigneeId != null;
          final bool isAssignedToMe = ticketHasAssignee && _viewModel.ticket.assigneeId == _viewModel.currentUserId;

          return Column(
            children: [
              // Minimized Collapsible Header (ExpansionTile)
              Container(
                color: Colors.white,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      _viewModel.ticket.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Clique para ver detalhes e opções',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top: 0),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _viewModel.ticket.description,
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Informação do Dono do Ticket (Cliente)
                      _buildUserInfoRow(
                        Icons.person, 
                        'Cliente', 
                        _viewModel.ticket.customerName ?? 'Desconhecido', 
                        Colors.grey.shade600
                      ),

                      // Informação do Suporte ou Botão de Reivindicar
                      if (ticketHasAssignee)
                        _buildUserInfoRow(
                          Icons.support_agent, 
                          'Suporte', 
                          isAssignedToMe ? '${_viewModel.ticket.assigneeName!} (Tu)' : _viewModel.ticket.assigneeName!, 
                          Colors.blueAccent
                        )
                      else if (_viewModel.isSupporter) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            icon: _viewModel.isClaiming 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.pan_tool, size: 18),
                            label: const Text('Reivindicar Ticket'),
                            onPressed: _viewModel.isClaiming ? null : _viewModel.claimTicket,
                          ),
                        ),
                      ],

                      // Dropdown de Alteração de Estado (Apenas para Suportes)
                      if (_viewModel.isSupporter) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Alterar Estado do Ticket:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TicketStatusDropdown(
                          currentStatus: _viewModel.ticket.status,
                          isLoading: _viewModel.isUpdatingStatus,
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
              
              // Chat List
              Expanded(
                child: _viewModel.messages.isEmpty
                    ? const Center(child: Text('Ainda não há mensagens. Comece a conversa!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _viewModel.messages.length,
                        itemBuilder: (context, index) {
                          final message = _viewModel.messages[index];
                          return MessageBubble(message: message);
                        },
                      ),
              ),

              // Chat Input Area
              TicketChatInput(
                isSending: _viewModel.isSending,
                isEnabled: isTicketInProgress,
                onSendMessage: (text, attachment) async {
                  await _viewModel.sendMessage(text, attachment: attachment);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}