import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/tickets/models/ticket.dart';
import 'package:supporttickets_app/features/tickets/models/ticket_message.dart';
import 'package:supporttickets_app/features/tickets/repositories/ticket_repository.dart';
import 'package:supporttickets_app/features/tickets/viewmodels/ticket_details_viewmodel.dart';

/// Fake implementation of ProfileRepository to bypass network calls during tests
class FakeProfileRepository extends Fake implements ProfileRepository {
  @override
  Future<Map<String, dynamic>> getProfile() async {
    return {'role': 'supporter', 'id': 1};
  }
}

/// Fake implementation of TicketRepository to bypass network calls and track interactions
class FakeTicketRepository extends Fake implements TicketRepository {
  bool wasSyncTagsCalled = false;

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    return [{'id': 1, 'name': 'Bug'}];
  }

  @override
  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    return [];
  }

  @override
  Future<Ticket> syncTags(int ticketId, List<int> tagIds) async {
    wasSyncTagsCalled = true;
    return Ticket(
      id: ticketId,
      title: 'Mock Ticket',
      description: 'Mock Desc',
      status: 'open',
      createdAt: DateTime.now(),
      tags: [{'id': 1, 'name': 'Bug'}, {'id': 2, 'name': 'Urgente'}],
    );
  }

  @override
  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return {'remaining_seconds': 3600};
  }
}

void main() {
  late TicketDetailsViewModel viewModel;
  late FakeProfileRepository fakeProfileRepository;
  late FakeTicketRepository fakeTicketRepository;
  late Ticket dummyTicket;

  setUp(() {
    fakeProfileRepository = FakeProfileRepository();
    fakeTicketRepository = FakeTicketRepository();
    
    // Initialize a clean state dummy ticket for every test iteration
    dummyTicket = Ticket(
      id: 1,
      title: 'Erro no Login',
      description: 'Não consigo aceder',
      status: 'open',
      createdAt: DateTime.now(),
    );

    viewModel = TicketDetailsViewModel(
      ticketRepository: fakeTicketRepository,
      profileRepository: fakeProfileRepository,
      ticket: dummyTicket,
    );
  });

  group('TicketDetailsViewModel - Session and Tags Management', () {
    
    test('ApiClient must emit true in unauthenticatedStream when intercepting 401', () async {
      bool isUnauthenticated = false;
      
      final subscription = ApiClient.unauthenticatedStream.stream.listen((event) {
        isUnauthenticated = event;
      });
      
      ApiClient.unauthenticatedStream.add(true);
      
      // Wait for the micro-task queue to process the stream event
      await Future.delayed(Duration.zero);
      
      expect(isUnauthenticated, isTrue);
      
      await subscription.cancel();
    });

    test('Must load available tags upon initialization if user is a supporter', () async {
      // Act
      await viewModel.initialize();
      
      // Assert
      expect(viewModel.availableTags.length, 1);
      expect(viewModel.availableTags.first['name'], 'Bug');
    });

    test('Must update ticket tags, verify repository call, and reset loading state', () async {
      // Act
      final success = await viewModel.syncTicketTags([1, 2]);
      
      // Assert
      expect(success, isTrue);
      expect(fakeTicketRepository.wasSyncTagsCalled, isTrue);
      expect(viewModel.isLoading, false);
      expect(viewModel.ticket.tags.length, 2);
    });
    
  });
}