// lib/core/utils/result.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logit/core/failure/failure.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;
}
