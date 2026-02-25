import 'package:flutter/material.dart';
import '../../profile/repositories/profile_repository.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';
import '../repositories/ticket_repository.dart';
import 'components/message_bubble.dart';
import 'components/ticket_chat_input.dart';
import 'components/ticket_status_badge.dart';

/// Screen displaying the conversation and management options for a specific ticket.
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
  final ScrollController _scrollController = ScrollController();
  
  int? _currentUserId;
  bool _isLoadingUser = true;
  List<TicketMessage> _messages = [];
  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches the current logged-in user to set context, then loads the chat.
  Future<void> _initializeData() async {
    try {
      final profile = await widget.profileRepository.getProfile();
      // Adjust based on your actual /me payload structure (e.g., profile['data']['id'])
      final userData = profile.containsKey('data') ? profile['data'] : profile;
      
      if (mounted) {
        setState(() {
          _currentUserId = userData['id'] as int?;
          _isLoadingUser = false;
        });
        _loadMessages();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
        _showError('Failed to load user session.');
      }
    }
  }

  /// Fetches the ticket messages from the API.
  Future<void> _loadMessages() async {
    if (_currentUserId == null) return;

    setState(() => _isLoadingMessages = true);
    try {
      final messages = await widget.ticketRepository.getTicketMessages(
        widget.ticket.id, 
        _currentUserId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
        _showError('Failed to load messages.');
      }
    }
  }

  /// Sends the typed message to the API and updates the UI locally for speed.
  Future<void> _handleSendMessage(String text) async {
    if (_currentUserId == null) return;

    try {
      final newMessage = await widget.ticketRepository.sendMessage(
        widget.ticket.id, 
        text, 
        _currentUserId,
      );
      
      if (mounted) {
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    } catch (e) {
      _showError('Failed to send message: ${e.toString()}');
      rethrow; // Propagate error so the Input component stops its loading state
    }
  }

  /// Displays an error snackbar.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Scrolls the chat list to the newest message.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _buildChatList(),
                ),
                TicketChatInput(
                  onSendMessage: _handleSendMessage,
                ),
              ],
            ),
    );
  }

  Widget _buildChatList() {
    if (_isLoadingMessages && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('No messages yet. Say hello!', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return MessageBubble(message: _messages[index]);
        },
      ),
    );
  }
}