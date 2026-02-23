import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasPinUseCaseProvider = Provider<HasPinUseCase>((ref) {
  return HasPinUseCase(authRepository: ref.watch(authRepositoryProvider));
});

class HasPinUseCase implements UseCaseNoParams<bool> {
  final AuthRepository authRepository;

  HasPinUseCase({required this.authRepository});

  @override
  Future<Result<bool>> call() {
    return authRepository.hasPin();
  }
}
