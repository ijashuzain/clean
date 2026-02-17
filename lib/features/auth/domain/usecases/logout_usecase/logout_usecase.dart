import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logout_usecase.g.dart';

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(authRepository: ref.watch(authRepositoryProvider));
}

class LogoutUseCase implements UseCaseNoParams<void> {
  final AuthRepository authRepository;

  LogoutUseCase({required this.authRepository});

  @override
  Future<Result<void>> call() async {
    return authRepository.logout();
  }
}
