import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// ViewModel responsible for managing the state and logic of a specific ticket's details.
class TicketDetailsViewModel extends ChangeNotifier {
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  
  /// The current ticket being viewed.
  Ticket ticket;

  List<TicketMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int? _currentUserId;

  /// Initializes the ViewModel with necessary repositories and the initial ticket.
  TicketDetailsViewModel({
    required this.ticketRepository,
    required this.profileRepository,
    required this.ticket,
  });

  List<TicketMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;

  /// Initializes the view model by fetching the current user's profile and then the ticket messages.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch current user profile to determine 'isFromMe' for messages
      final profileResponse = await profileRepository.getProfile();
      
      // Robust extraction: Handle standard Laravel 'data' wrapper if present
      final profileData = profileResponse.containsKey('data') 
          ? profileResponse['data'] 
          : profileResponse;
      
      // Safely parse the ID, handling both Int and String types from the API
      if (profileData != null && profileData['id'] != null) {
        _currentUserId = int.tryParse(profileData['id'].toString());
      }

      // 2. Fetch the messages for this ticket
      await loadMessages();
    } catch (e) {
      _errorMessage = 'Failed to initialize chat: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the latest messages for the current ticket.
  Future<void> loadMessages() async {
    try {
      _messages = await ticketRepository.getTicketMessages(ticket.id, _currentUserId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }

  /// Sends a new message (text and/or attachment) to the ticket thread.
  ///
  /// [messageText] The optional text content of the message.
  /// [attachment] The optional file attachment.
  /// Returns a boolean indicating success.
  Future<bool> sendMessage(String? messageText, {File? attachment}) async {
    // Prevent sending completely empty messages
    if ((messageText == null || messageText.trim().isEmpty) && attachment == null) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMessage = await ticketRepository.sendMessage(
        ticket.id, 
        messageText, 
        userId: _currentUserId,
        attachment: attachment,
      );
      
      // Append the new message to the list to update the UI instantly
      _messages.add(newMessage);
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates the status of the ticket.
  Future<void> updateStatus(String newStatus) async {
    try {
      final updatedTicket = await ticketRepository.updateTicketStatus(ticket.id, newStatus);
      ticket = updatedTicket;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }
}