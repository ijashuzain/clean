
import 'package:clean_sample/core/failure/failure.dart';
import 'package:clean_sample/core/utils/result/result.dart';
import 'package:clean_sample/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';
import 'package:clean_sample/features/auth/domain/repositories/auth_repository.dart';
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

  AuthRepositoryImpl({
    required this.authLocalDataSource,
  });

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
  Future<Result<AppUser>> signup(String email, String password) async {
    try {
      final response = await authLocalDataSource.signup(email, password);
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.failure(Failure.clientFailure(message: e.toString()));
    }
  }
}