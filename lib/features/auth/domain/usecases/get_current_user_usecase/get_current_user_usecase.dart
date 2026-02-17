import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_current_user_usecase.g.dart';

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
}

class GetCurrentUserUseCase implements UseCaseNoParams<AppUser?> {
  final AuthRepository authRepository;

  GetCurrentUserUseCase({required this.authRepository});

  @override
  Future<Result<AppUser?>> call() async {
    return authRepository.currentUser();
  }
}
