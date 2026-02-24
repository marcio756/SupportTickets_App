import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';
import '../repositories/ticket_repository.dart';
import 'components/message_bubble.dart';
import 'components/ticket_status_badge.dart';

/// Screen displaying the conversation and management options for a specific ticket.
class TicketDetailsScreen extends StatefulWidget {
  final Ticket ticket;
  final TicketRepository ticketRepository;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
    required this.ticketRepository,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Hardcoded for now, in Phase 6 we will get this from an AuthProvider/State
  final int _currentUserId = 1; 
  
  late Future<List<TicketMessage>> _messagesFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messagesFuture = widget.ticketRepository.getTicketMessages(
        widget.ticket.id, 
        _currentUserId,
      );
    });
  }

  /// Sends the typed message to the API and refreshes the view.
  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await widget.ticketRepository.sendMessage(
        widget.ticket.id, 
        text, 
        _currentUserId,
      );
      _messageController.clear();
      _loadMessages(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ticket.title, style: const TextStyle(fontSize: 16)),
            Text('#${widget.ticket.id}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: TicketStatusBadge(status: widget.ticket.status)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<TicketMessage>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data ?? [];
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: messages[index]),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your reply...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                maxLines: null,
              ),
            ),
            IconButton(
              icon: _isSending 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}