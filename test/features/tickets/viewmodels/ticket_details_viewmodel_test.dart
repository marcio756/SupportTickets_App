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
    test('initialize fetches profile and messages successfully', () async {
      // Arrange
      when(mockProfileRepo.getProfile()).thenAnswer((_) async => {'id': 10});
      when(mockTicketRepo.getTicketMessages(1, 10)).thenAnswer((_) async => [
        TicketMessage(id: 1, message: 'Hello', userName: 'Admin', createdAt: DateTime.now(), isFromMe: false)
      ]);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.currentUserId, 10);
      expect(viewModel.messages.length, 1);
      expect(viewModel.isLoading, isFalse);
      verify(mockProfileRepo.getProfile()).called(1);
      verify(mockTicketRepo.getTicketMessages(1, 10)).called(1);
    });

    test('sendMessage successfully adds message to list', () async {
      // Arrange
      final newMessage = TicketMessage(
        id: 2, message: 'Replying', userName: 'Me', createdAt: DateTime.now(), isFromMe: true
      );
      
      when(mockProfileRepo.getProfile()).thenAnswer((_) async => {'id': 10});
      when(mockTicketRepo.getTicketMessages(any, any)).thenAnswer((_) async => []);
      when(mockTicketRepo.sendMessage(1, 'Replying', 10)).thenAnswer((_) async => newMessage);

      await viewModel.initialize(); // Set user ID

      // Act
      final result = await viewModel.sendMessage('Replying');

      // Assert
      expect(result, isTrue);
      expect(viewModel.messages.length, 1);
      expect(viewModel.messages.first.message, 'Replying');
      expect(viewModel.isSending, isFalse);
    });
  });
}