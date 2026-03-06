import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/users/models/user_model.dart';
import 'package:supporttickets_app/features/users/repositories/user_repository.dart';
import 'package:supporttickets_app/features/users/viewmodels/user_management_viewmodel.dart';

@GenerateMocks([UserRepository])
import 'user_management_viewmodel_test.mocks.dart';

void main() {
  late UserManagementViewModel viewModel;
  late MockUserRepository mockUserRepository;

  final dummyUser = UserModel(id: 1, name: 'John Doe', email: 'john@example.com', role: 'customer');

  setUp(() {
    mockUserRepository = MockUserRepository();
    viewModel = UserManagementViewModel(userRepository: mockUserRepository);
  });

  group('UserManagementViewModel Logic Formulation', () {
    test('initial state should be empty and not loading', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.users, isEmpty);
    });

    test('loadUsers populates the user list on success', () async {
      when(mockUserRepository.getUsers())
          .thenAnswer((_) async => [dummyUser]);

      await viewModel.loadUsers();

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.users.length, 1);
      expect(viewModel.users.first.name, 'John Doe');
      verify(mockUserRepository.getUsers()).called(1);
    });

    test('createUser adds a new user to the top of the list', () async {
      final newUser = UserModel(id: 2, name: 'Jane Doe', email: 'jane@example.com', role: 'supporter');
      
      when(mockUserRepository.createUser(any))
          .thenAnswer((_) async => newUser);

      await viewModel.createUser({
        'name': 'Jane Doe',
        'email': 'jane@example.com',
        'password': 'password',
        'role': 'supporter',
      });

      expect(viewModel.isLoading, false);
      expect(viewModel.users.first.id, 2);
    });

    test('deleteUser removes the user from the list', () async {
      // Setup initial state
      when(mockUserRepository.getUsers()).thenAnswer((_) async => [dummyUser]);
      await viewModel.loadUsers();
      
      when(mockUserRepository.deleteUser(1)).thenAnswer((_) async => {});

      await viewModel.deleteUser(1);

      expect(viewModel.isLoading, false);
      expect(viewModel.users, isEmpty);
    });
  });
}