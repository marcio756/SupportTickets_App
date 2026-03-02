import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/models/ticket_message.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/viewmodels/ticket_details_viewmodel.dart';

@GenerateMocks([TicketRepository, ProfileRepository])
import 'ticket_details_viewmodel_test.mocks.dart';

void main() {
  late TicketDetailsViewModel viewModel;
  late MockTicketRepository mockTicketRepo;
  late MockProfileRepository mockProfileRepo;
  late Ticket initialTicket;

  setUp(() {
    mockTicketRepo = MockTicketRepository();
    mockProfileRepo = MockProfileRepository();
    initialTicket = Ticket(
      id: 1, 
      title: 'Fix Bug', 
      description: 'System crashing', 
      status: 'open', 
      createdAt: DateTime.now(),
    );

    viewModel = TicketDetailsViewModel(
      ticketRepository: mockTicketRepo,
      profileRepository: mockProfileRepo,
      ticket: initialTicket,
    );
  });

  group('TicketDetailsViewModel Tests', () {
    test('initialize fetches profile and correctly assigns supporter role', () async {
      // Mock the exact expected network responses
      when(mockProfileRepo.getProfile()).thenAnswer((_) async => {
        'data': { // Make sure this matches the API response structure expected by the ViewModel
          'id': 10,
          'role': 'supporter'
        }
      });
      // Accept any arguments for flexibility, test logic elsewhere
      when(mockTicketRepo.getTicketMessages(any, any)).thenAnswer((_) async => [
        TicketMessage(id: 1, message: 'Hello', userName: 'Admin', createdAt: DateTime.now(), isFromMe: false)
      ]);
      when(mockTicketRepo.getTags()).thenAnswer((_) async => []);

      await viewModel.initialize();

      expect(viewModel.currentUserId, 10);
      expect(viewModel.isSupporter, isTrue); 
      expect(viewModel.messages.length, 1);
      expect(viewModel.isLoading, isFalse);
    });

    test('sendMessage successfully adds message to list', () async {
      final newMessage = TicketMessage(
        id: 2, message: 'Replying', userName: 'Me', createdAt: DateTime.now(), isFromMe: true
      );
      
      when(mockProfileRepo.getProfile()).thenAnswer((_) async => {
        'data': {
          'id': 10, 'role': 'customer'
        }
      });
      when(mockTicketRepo.getTicketMessages(any, any)).thenAnswer((_) async => []);
      when(mockTicketRepo.sendMessage(any, any, userId: anyNamed('userId'))).thenAnswer((_) async => newMessage);

      await viewModel.initialize(); 

      final result = await viewModel.sendMessage('Replying');

      expect(result, isTrue);
      expect(viewModel.isSupporter, isFalse);
      expect(viewModel.messages.length, 1);
      expect(viewModel.messages.first.message, 'Replying');
      expect(viewModel.isSending, isFalse);
    });
  });
}