import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  return VerifyPinUseCase(authRepository: ref.watch(authRepositoryProvider));
});

class VerifyPinUseCase implements UseCase<bool, VerifyPinParams> {
  final AuthRepository authRepository;

  VerifyPinUseCase({required this.authRepository});

  @override
  Future<Result<bool>> call(VerifyPinParams params) {
    return authRepository.verifyPin(params.pin);
  }
}

class VerifyPinParams {
  final String pin;

  VerifyPinParams({required this.pin});
}
