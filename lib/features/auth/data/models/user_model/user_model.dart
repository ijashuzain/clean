import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required String password,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  AppUser toEntity() => AppUser(id: id, email: email, name: name);
}
