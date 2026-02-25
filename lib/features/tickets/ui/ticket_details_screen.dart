import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../viewmodels/ticket_details_viewmodel.dart';
import 'components/message_bubble.dart';
import 'components/ticket_chat_input.dart';
import 'components/ticket_status_badge.dart';

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
    
    // Initialize data fetch
    _viewModel.initialize().then((_) {
      _scrollToBottom();
    });

    // Add listener to automatically scroll down when new messages arrive
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
      // Adding a slight delay to ensure UI has built the new items
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
          // Observes only the ticket status changes
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
                      child: const Text('Try Again'),
                    )
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Ticket Subject/Description Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viewModel.ticket.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // Removed the dead null check since description is non-nullable in Dart model
                      _viewModel.ticket.description,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              
              // Chat List
              Expanded(
                child: _viewModel.messages.isEmpty
                    ? const Center(child: Text('No messages yet. Start the conversation!'))
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
                onSendMessage: (text) async {
                  await _viewModel.sendMessage(text);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}