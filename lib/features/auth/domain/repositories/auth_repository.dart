import 'package:clean_sample/core/utils/result/result.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login(String email, String password);
  Future<Result<AppUser>> signup(String email, String password);
}