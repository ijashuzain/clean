import 'package:clean_sample/core/failure/failure.dart';
import 'package:clean_sample/core/usecases/usecase.dart';
import 'package:clean_sample/core/utils/result/result.dart';
import 'package:clean_sample/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';
import 'package:clean_sample/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_usecase.g.dart';

@riverpod
SignupUseCase signupUseCase(Ref ref) {
  return SignupUseCase(authRepository: ref.watch(authRepositoryProvider));
}

class SignupUseCase implements UseCase<AppUser, SingupParams> {
  final AuthRepository authRepository;

  SignupUseCase({required this.authRepository});

  @override
  Future<Result<AppUser>> call(SingupParams params) async {
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Result.failure(Failure.validationFailure(message: 'Invalid email address'));
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Result.failure(Failure.validationFailure(message: 'Password must be at least 6 characters'));
    }
    return authRepository.signup(params.email, params.password);
  }
}

class SingupParams {
  final String email;
  final String password;

  SingupParams({required this.email, required this.password});
}
