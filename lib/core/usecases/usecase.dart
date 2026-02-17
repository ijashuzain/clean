// lib/core/usecases/usecase.dart
import 'package:logit/core/utils/result/result.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

abstract class UseCaseNoParams<T> {
  Future<Result<T>> call();
}
