import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login(String email, String password);
  Future<Result<AppUser>> signup(String name, String email, String password);
  Future<Result<AppUser?>> currentUser();
  Future<Result<bool>> hasPin();
  Future<Result<void>> setPin(String pin);
  Future<Result<bool>> verifyPin(String pin);
  Future<Result<void>> logout();
}
