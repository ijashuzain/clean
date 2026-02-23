import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/data/repositories/auth_repository_impl/auth_repository_impl.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final setPinUseCaseProvider = Provider<SetPinUseCase>((ref) {
  return SetPinUseCase(authRepository: ref.watch(authRepositoryProvider));
});

class SetPinUseCase implements UseCase<void, SetPinParams> {
  final AuthRepository authRepository;

  SetPinUseCase({required this.authRepository});

  @override
  Future<Result<void>> call(SetPinParams params) {
    return authRepository.setPin(params.pin);
  }
}

class SetPinParams {
  final String pin;

  SetPinParams({required this.pin});
}
