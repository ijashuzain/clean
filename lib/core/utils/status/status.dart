import 'package:freezed_annotation/freezed_annotation.dart';

part 'status.freezed.dart';

@freezed
abstract class Status with _$Status {
  const Status._();

  const factory Status.initial() = StatusInitial;
  const factory Status.loading() = StatusLoading;
  const factory Status.success({dynamic data}) = StatusSuccess;
  const factory Status.failure(String errorMessage) = StatusFailure;

  dynamic get data {
    return maybeWhen(success: (data) => data, orElse: () => null);
  }

  bool get isLoading => this is StatusLoading;

  String get errorMessage {
    return maybeWhen(failure: (message) => message, orElse: () => '');
  }
}
