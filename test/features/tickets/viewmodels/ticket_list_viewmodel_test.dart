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

    // Stub getCustomers to prevent unhandled MissingStubError in the constructor
    // since the ViewModel automatically calls _loadCustomers() upon initialization.
    when(mockRepository.getCustomers()).thenAnswer((_) async => []);

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
      
      // Match the named parameter 'filters' using anyNamed
      when(mockRepository.getTickets(filters: anyNamed('filters')))
          .thenAnswer((_) async => mockTickets);

      // Act
      await viewModel.loadTickets();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.tickets.length, 1);
      expect(viewModel.errorMessage, isNull);
      
      // Verify using the same named matcher
      verify(mockRepository.getTickets(filters: anyNamed('filters'))).called(1);
    });

    test('Should handle errors correctly when loading fails', () async {
      // Arrange
      // Match the named parameter 'filters' using anyNamed
      when(mockRepository.getTickets(filters: anyNamed('filters')))
          .thenThrow(Exception('Network Error'));

      // Act
      await viewModel.loadTickets();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.tickets.isEmpty, true);
      expect(viewModel.errorMessage, 'Network Error');
    });
  });
}