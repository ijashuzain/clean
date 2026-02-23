import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/utils/error_message_formatter.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:logit/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource authLocalDataSource;
  final AuthRemoteDataSource? authRemoteDataSource;

  AuthRepositoryImpl({
    required this.authLocalDataSource,
    this.authRemoteDataSource,
  });

  @override
  Future<Result<AppUser>> login(String email, String password) async {
    try {
      final remote = authRemoteDataSource;
      if (remote != null && remote.isAvailable) {
        final response = await remote.login(email, password);
        return Result.success(response);
      }

      final localResponse = await authLocalDataSource.login(email, password);
      return Result.success(localResponse.toEntity());
    } catch (e) {
      return Result.failure(
        Failure.clientFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to login. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<AppUser>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final remote = authRemoteDataSource;
      if (remote != null && remote.isAvailable) {
        final response = await remote.signup(name, email, password);
        return Result.success(response);
      }

      final localResponse = await authLocalDataSource.signup(
        name,
        email,
        password,
      );
      return Result.success(localResponse.toEntity());
    } catch (e) {
      return Result.failure(
        Failure.clientFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to create account. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<AppUser?>> currentUser() async {
    try {
      final remote = authRemoteDataSource;
      if (remote != null && remote.isAvailable) {
        final response = await remote.getCurrentUser();
        return Result.success(response);
      }

      final localResponse = await authLocalDataSource.getCurrentUser();
      return Result.success(localResponse?.toEntity());
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to restore session.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasPin() async {
    try {
      final response = await authLocalDataSource.hasPin();
      return Result.success(response);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Could not check PIN state.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<void>> setPin(String pin) async {
    try {
      await authLocalDataSource.setPin(pin);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.clientFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to save PIN.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verifyPin(String pin) async {
    try {
      final response = await authLocalDataSource.verifyPin(pin);
      return Result.success(response);
    } catch (e) {
      return Result.failure(
        Failure.clientFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to verify PIN.',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final remote = authRemoteDataSource;
      if (remote != null && remote.isAvailable) {
        await remote.logout();
      }
      await authLocalDataSource.logout();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: ErrorMessageFormatter.format(
            e,
            fallback: 'Unable to logout. Please try again.',
          ),
        ),
      );
    }
  }
}
