import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supporttickets_app/features/auth/repositories/auth_repository.dart';
import 'package:supporttickets_app/features/auth/viewmodels/login_viewmodel.dart';

@GenerateMocks([AuthRepository])
import 'login_viewmodel_test.mocks.dart';

void main() {
  late LoginViewModel viewModel;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    viewModel = LoginViewModel(authRepository: mockRepo);
  });

  group('LoginViewModel Tests', () {
    test('Should return error when fields are empty', () async {
      // Act
      await viewModel.login('', ' ');

      // Assert
      expect(viewModel.errorMessage, 'Por favor, preencha o e-mail e a palavra-passe.');
      expect(viewModel.isSuccess, isFalse);
      verifyNever(mockRepo.login(any, any));
    });

    test('Should authenticate successfully', () async {
      // Arrange
      when(mockRepo.login('admin@test.com', 'password')).thenAnswer((_) async => true);

      // Act
      await viewModel.login('admin@test.com', 'password');

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isSuccess, isTrue);
      expect(viewModel.errorMessage, isNull);
      verify(mockRepo.login('admin@test.com', 'password')).called(1);
    });

    test('Should show invalid credentials error', () async {
      // Arrange
      when(mockRepo.login('user@test.com', 'wrong')).thenAnswer((_) async => false);

      // Act
      await viewModel.login('user@test.com', 'wrong');

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isSuccess, isFalse);
      expect(viewModel.errorMessage, 'Credenciais inválidas. Tente novamente.');
    });
  });
}