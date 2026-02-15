import 'package:clean_sample/core/failure/failure.dart';
import 'package:clean_sample/core/utils/result/result.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';
import 'package:clean_sample/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_sample/features/auth/domain/usecases/login_usecase/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    provideDummy<Result<AppUser>>(const Result.success(AppUser()));
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(authRepository: mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tUser = AppUser(id: '1', email: tEmail, name: 'Test User');
  final tParams = LoginParams(email: tEmail, password: tPassword);

  test('should get user from the repository when email is valid', () async {
    // arrange
    when(mockAuthRepository.login(tEmail, tPassword)).thenAnswer((_) async => const Result.success(tUser));
    // act
    final result = await usecase(tParams);
    // assert
    expect(result, const Result.success(tUser));
    verify(mockAuthRepository.login(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ValidationFailure when email is invalid', () async {
    // arrange
    final tInvalidParams = LoginParams(email: 'invalid-email', password: tPassword);
    // act
    final result = await usecase(tInvalidParams);
    // assert
    result.when(
      success: (_) => fail('Expected failure'),
      failure: (failure) {
        expect(failure.message, 'Invalid email address');
      },
    );
    verifyZeroInteractions(mockAuthRepository);
  });
}
