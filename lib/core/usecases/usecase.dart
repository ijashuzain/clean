// lib/core/usecases/usecase.dart
import 'package:clean_sample/core/utils/result/result.dart';

// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}