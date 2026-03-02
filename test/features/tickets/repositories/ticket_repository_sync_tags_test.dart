import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> put(String path, {dynamic data, dynamic options}) {
    return super.noSuchMethod(
      Invocation.method(#put, [path], {#data: data, #options: options}),
      returnValue: Future.value(<String, dynamic>{}),
    ) as Future<Map<String, dynamic>>;
  }
}

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

      // Mocks generic API Client PUT request using named parameters
      when(mockApiClient.put(any ?? '', data: anyNamed('data')))
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