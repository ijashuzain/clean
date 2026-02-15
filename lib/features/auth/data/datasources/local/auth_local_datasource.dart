import 'package:clean_sample/features/auth/data/models/user_model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_local_datasource.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl();
}

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String email, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = UserModel(id: '1', email: 'email', name: 'name', password: 'password');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signup(String email, String password) async {
    try {
      final response = UserModel(id: '1', email: 'email', name: 'name', password: 'password');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
