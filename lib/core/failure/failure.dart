import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.clientFailure({
    @Default('Something went wrong. Please try again later.') String message,
    int? statusCode,
  }) = ClientFailure;

  // Generic server error (500, etc)
  const factory Failure.serverFailure({
    @Default('An unexpected server error occurred.') String message,
  }) = ServerFailure;

  // Internet connection issues
  const factory Failure.networkFailure({
    @Default('No internet connection. Please check your settings.')
    String message,
  }) = NetworkFailure;

  // Local database issues (Hive/SQFlite)
  const factory Failure.cacheFailure({
    @Default('Could not access local data.') String message,
  }) = CacheFailure;

  // Specific Auth issues
  const factory Failure.authFailure({required String message}) = AuthFailure;

  // Validation issues (e.g., email format)
  const factory Failure.validationFailure({required String message}) =
      ValidationFailure;
}
