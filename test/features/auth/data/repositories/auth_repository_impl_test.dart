import 'package:clean_sample/core/failure/failure.dart';
import 'package:clean_sample/core/utils/result/result.dart';
import 'package:clean_sample/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:clean_sample/features/auth/data/models/user_model/user_model.dart';
import 'package:clean_sample/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthLocalDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(authLocalDataSource: mockAuthLocalDataSource);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tUserModel = UserModel(id: '1', email: tEmail, name: 'Test User', password: tPassword);
  final tAppUser = tUserModel.toEntity();

  group('login', () {
    test('should return AppUser when call to local datasource is successful', () async {
      // arrange
      when(mockAuthLocalDataSource.login(tEmail, tPassword)).thenAnswer((_) async => tUserModel);
      // act
      final result = await repository.login(tEmail, tPassword);
      // assert
      verify(mockAuthLocalDataSource.login(tEmail, tPassword));
      expect(result, Result.success(tAppUser));
    });

    test('should return Failure when call to local datasource throws an exception', () async {
      // arrange
      when(mockAuthLocalDataSource.login(tEmail, tPassword)).thenThrow(Exception('Login failed'));
      // act
      final result = await repository.login(tEmail, tPassword);
      // assert
      verify(mockAuthLocalDataSource.login(tEmail, tPassword));
      // We expect a Failure.clientFailure with the exception message
      // exact matching might depend on Failure implementation, checking type and message
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (failure) {
          expect(failure, isA<Failure>());
          // Basic check if message contains generic exception info or specific string
          expect(failure.message, contains('Login failed'));
        },
      );
    });
  });
}
