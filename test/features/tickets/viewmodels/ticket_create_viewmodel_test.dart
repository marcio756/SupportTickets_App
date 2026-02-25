import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/viewmodels/ticket_create_viewmodel.dart';

@GenerateMocks([TicketRepository])
import 'ticket_create_viewmodel_test.mocks.dart';

void main() {
  late TicketCreateViewModel viewModel;
  late MockTicketRepository mockRepository;

  setUp(() {
    mockRepository = MockTicketRepository();
    viewModel = TicketCreateViewModel(ticketRepository: mockRepository);
  });

  group('TicketCreateViewModel Tests', () {
    test('Should return error when fields are empty', () async {
      // Act
      await viewModel.createTicket('', '   ');

      // Assert
      expect(viewModel.errorMessage, 'O título e a descrição são obrigatórios.');
      expect(viewModel.isSuccess, isFalse);
      verifyNever(mockRepository.createTicket(any, any));
    });

    test('Should create ticket successfully and set isSuccess to true', () async {
      // Arrange
      final mockTicket = Ticket(
        id: 1, title: 'Bug', description: 'Desc', status: 'open', createdAt: DateTime.now()
      );
      when(mockRepository.createTicket('Bug', 'Desc')).thenAnswer((_) async => mockTicket);

      // Act
      await viewModel.createTicket('Bug', 'Desc');

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isSuccess, isTrue);
      expect(viewModel.errorMessage, isNull);
      verify(mockRepository.createTicket('Bug', 'Desc')).called(1);
    });

    test('Should handle API errors gracefully', () async {
      // Arrange
      when(mockRepository.createTicket(any, any)).thenThrow(Exception('Server Offline'));

      // Act
      await viewModel.createTicket('Title', 'Desc');

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isSuccess, isFalse);
      expect(viewModel.errorMessage, contains('Server Offline'));
    });
  });
}