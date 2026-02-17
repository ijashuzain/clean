import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
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
    if (params.name.trim().isEmpty) {
      return Result.failure(
        Failure.validationFailure(message: 'Name is required'),
      );
    }

    if (params.email.isEmpty || !params.email.contains('@')) {
      return Result.failure(
        Failure.validationFailure(message: 'Invalid email address'),
      );
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password must be at least 6 characters',
        ),
      );
    }
    return authRepository.signup(params.name, params.email, params.password);
  }
}

class SingupParams {
  final String name;
  final String email;
  final String password;

  SingupParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
