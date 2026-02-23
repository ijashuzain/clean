import 'package:logit/core/supabase/supabase_initializer.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

abstract class AuthRemoteDataSource {
  bool get isAvailable;
  String? get currentUserId;
  Future<AppUser> login(String email, String password);
  Future<AppUser> signup(String name, String email, String password);
  Future<AppUser?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  bool get isAvailable => SupabaseInitializer.isInitialized;

  @override
  String? get currentUserId => _client?.auth.currentUser?.id;

  SupabaseClient? get _client {
    if (!SupabaseInitializer.isInitialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final client = _client;
    if (client == null) {
      throw Exception(SupabaseInitializer.missingConfigMessage);
    }

    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Unable to login. Please try again.');
    }
    return _toAppUser(user, fallbackEmail: email.trim());
  }

  @override
  Future<AppUser> signup(String name, String email, String password) async {
    final client = _client;
    if (client == null) {
      throw Exception(SupabaseInitializer.missingConfigMessage);
    }

    final trimmedName = name.trim();
    final normalizedEmail = email.trim();

    final response = await client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: <String, dynamic>{'name': trimmedName},
    );

    User? user = response.user;
    if (user == null) {
      throw Exception('Unable to create account. Please try again.');
    }

    if (response.session == null) {
      final loginResponse = await client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      user = loginResponse.user ?? user;
    }

    return _toAppUser(
      user,
      fallbackName: trimmedName,
      fallbackEmail: normalizedEmail,
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final client = _client;
    if (client == null) {
      return null;
    }
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return _toAppUser(user);
  }

  @override
  Future<void> logout() async {
    final client = _client;
    if (client == null) {
      return;
    }
    await client.auth.signOut();
  }

  AppUser _toAppUser(
    User user, {
    String fallbackName = '',
    String fallbackEmail = '',
  }) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final metadataName = (metadata['name'] as String?)?.trim() ?? '';
    final email = user.email?.trim() ?? fallbackEmail;
    return AppUser(
      id: user.id,
      email: email,
      name: metadataName.isNotEmpty
          ? metadataName
          : (fallbackName.isNotEmpty ? fallbackName : 'LogIt User'),
    );
  }
}
