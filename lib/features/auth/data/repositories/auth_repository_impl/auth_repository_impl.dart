import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImpl({required this.authLocalDataSource});

  @override
  Future<Result<AppUser>> login(String email, String password) async {
    try {
      final response = await authLocalDataSource.login(email, password);
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.failure(Failure.clientFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await authLocalDataSource.signup(name, email, password);
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.failure(Failure.clientFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AppUser?>> currentUser() async {
    try {
      final response = await authLocalDataSource.getCurrentUser();
      return Result.success(response?.toEntity());
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await authLocalDataSource.logout();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }
}
