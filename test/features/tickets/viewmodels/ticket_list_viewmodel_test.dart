import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/viewmodels/ticket_list_viewmodel.dart';

// Generates the mock class for TicketRepository
@GenerateMocks([TicketRepository])
import 'ticket_list_viewmodel_test.mocks.dart';

void main() {
  late TicketListViewModel viewModel;
  late MockTicketRepository mockRepository;

  setUp(() {
    mockRepository = MockTicketRepository();
    viewModel = TicketListViewModel(ticketRepository: mockRepository);
  });

  group('TicketListViewModel Tests', () {
    test('Should verify initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.tickets.isEmpty, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('Should load tickets successfully and update state', () async {
      // Arrange
      final mockTickets = [
        Ticket(id: 1, title: 'Test', description: 'Test', status: 'open', createdAt: DateTime.now())
      ];
      when(mockRepository.getTickets()).thenAnswer((_) async => mockTickets);

      // Act
      // We don't await immediately so we can check the loading state mid-flight if needed,
      // but for standard testing we await the whole operation.
      await viewModel.loadTickets();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.tickets.length, 1);
      expect(viewModel.errorMessage, isNull);
      verify(mockRepository.getTickets()).called(1);
    });

    test('Should handle errors correctly when loading fails', () async {
      // Arrange
      when(mockRepository.getTickets()).thenThrow(Exception('Network Error'));

      // Act
      await viewModel.loadTickets();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.tickets.isEmpty, true);
      expect(viewModel.errorMessage, 'Network Error');
    });
  });
}