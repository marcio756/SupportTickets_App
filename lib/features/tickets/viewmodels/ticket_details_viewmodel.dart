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
  bool _isUpdatingStatus = false;
  bool _isClaiming = false; // Novo estado para o botão de reivindicar
  String? _errorMessage;
  int? _currentUserId;
  String? _currentUserRole;

  /// Initializes the ViewModel with necessary repositories and the initial ticket.
  TicketDetailsViewModel({
    required this.ticketRepository,
    required this.profileRepository,
    required this.ticket,
  });

  List<TicketMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isClaiming => _isClaiming;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;
  
  /// Determines if the current authenticated user has a supporter role.
  bool get isSupporter => _currentUserRole == 'supporter';

  /// Initializes the view model by fetching the current user's profile and then the ticket messages.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profileResponse = await profileRepository.getProfile();
      
      final profileData = profileResponse.containsKey('data') 
          ? profileResponse['data'] 
          : profileResponse;
      
      if (profileData != null) {
        if (profileData['id'] != null) {
          _currentUserId = int.tryParse(profileData['id'].toString());
        }
        if (profileData['role'] != null) {
          _currentUserRole = profileData['role'].toString();
        }
      }

      await loadMessages();
    } catch (e) {
      _errorMessage = 'Failed to initialize chat: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    try {
      _messages = await ticketRepository.getTicketMessages(ticket.id, _currentUserId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String? messageText, {File? attachment}) async {
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

  Future<void> updateStatus(String newStatus) async {
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await ticketRepository.updateTicketStatus(ticket.id, newStatus);
      ticket = updatedTicket;
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isUpdatingStatus = false;
      notifyListeners();
    }
  }

  /// Claims the ticket for the current supporter
  Future<void> claimTicket() async {
    _isClaiming = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Passa um mapa vazio pois o endpoint apenas exige o ID no URL
      final response = await ticketRepository.assignTicket(ticket.id, {});
      
      // Atualiza o ticket atual com os dados devolvidos (que agora incluem o assignee)
      final updatedData = response.containsKey('data') ? response['data'] : response;
      ticket = Ticket.fromJson(updatedData as Map<String, dynamic>);
      
    } catch (e) {
      _errorMessage = 'Falha ao reivindicar: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isClaiming = false;
      notifyListeners();
    }
  }
}