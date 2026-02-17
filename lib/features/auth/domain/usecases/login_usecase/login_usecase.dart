import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_usecase.g.dart';

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository: authRepository);
}

class LoginUseCase implements UseCase<AppUser, LoginParams> {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  @override
  Future<Result<AppUser>> call(LoginParams params) async {
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
    return authRepository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
