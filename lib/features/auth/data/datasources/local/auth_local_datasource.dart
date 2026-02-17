import 'package:logit/features/auth/data/models/user_model/user_model.dart';
import 'package:logit/core/constants/hive_keys.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'auth_local_datasource.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl();
}

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String name, String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<dynamic> _box = Hive.box<dynamic>(HiveBoxNames.auth);

  @override
  Future<UserModel> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final passwordHash = _hash(password);

    final users = _readUsers();
    final index = users.indexWhere(
      (user) =>
          user.email.toLowerCase() == normalizedEmail &&
          user.password == passwordHash,
    );

    if (index < 0) {
      throw Exception('Invalid email or password');
    }

    final user = users[index];
    await _box.put(HiveAuthKeys.currentUserId, user.id);
    return user;
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers();
    final hasExisting = users.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );
    if (hasExisting) {
      throw Exception('Account already exists for this email');
    }

    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'LogIt User' : name.trim(),
      email: normalizedEmail,
      password: _hash(password),
    );

    final updatedUsers = [...users, user];
    await _box.put(
      HiveAuthKeys.users,
      updatedUsers.map((item) => item.toJson()).toList(growable: false),
    );
    await _box.put(HiveAuthKeys.currentUserId, user.id);
    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUserId = _box.get(HiveAuthKeys.currentUserId) as String?;
    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }

    final users = _readUsers();
    for (final user in users) {
      if (user.id == currentUserId) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _box.delete(HiveAuthKeys.currentUserId);
  }

  List<UserModel> _readUsers() {
    final rawUsers =
        (_box.get(HiveAuthKeys.users, defaultValue: <dynamic>[])
            as List<dynamic>);
    return rawUsers
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(UserModel.fromJson)
        .toList(growable: false);
  }

  String _hash(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}
