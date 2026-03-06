import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

// Agora usamos a geração correta do Mockito para evitar erros do tipo Null Safety ou Argument Matchers
@GenerateMocks([ApiClient])
import 'ticket_repository_sync_tags_test.mocks.dart';

void main() {
  late TicketRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = TicketRepository(apiClient: mockApiClient);
  });

  group('TicketRepository - syncTags', () {
    test('deve chamar a API com os IDs corretos via PUT e retornar o Ticket atualizado com as novas tags', () async {
      final ticketId = 1;
      final tagIds = [2, 3];
      final mockResponse = {
        'data': {
          'id': 1,
          'title': 'Erro no Login',
          'tags': [
            {'id': 2, 'name': 'Bug'},
            {'id': 3, 'name': 'Urgente'}
          ]
        }
      };

      // Mocks generic API Client PUT request correctly
      when(mockApiClient.put(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.syncTags(ticketId, tagIds);

      expect(result, isA<Ticket>());
      expect(result.id, 1);
      expect(result.tags.length, 2);
      expect(result.tags.first['name'], 'Bug');
      verify(mockApiClient.put('/tickets/$ticketId/tags', data: {'tags': tagIds})).called(1);
    });
  });
}