import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorMessageFormatter {
  static String format(
    Object error, {
    String fallback = 'Something went wrong. Please try again later.',
  }) {
    if (error is AuthException) {
      return _normalizeAuthMessage(error.message, fallback: fallback);
    }
    if (error is PostgrestException) {
      return _normalize(_extractMessage(error.message), fallback: fallback);
    }
    if (error is SocketException) {
      return 'No internet connection. Please check your settings.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    final raw = error.toString().trim();
    if (raw.isEmpty) {
      return fallback;
    }
    return _normalize(_extractMessage(raw), fallback: fallback);
  }

  static String _normalizeAuthMessage(String raw, {required String fallback}) {
    final extracted = _extractMessage(raw);
    final message = extracted.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('signup is disabled')) {
      return 'Sign up is currently disabled.';
    }
    if (message.contains('network request failed') ||
        message.contains('failed to fetch')) {
      return 'No internet connection. Please check your settings.';
    }
    if (message.contains('token has expired')) {
      return 'Your session has expired. Please login again.';
    }

    return _normalize(extracted, fallback: fallback);
  }

  static String _extractMessage(String raw) {
    var value = raw.trim();
    final messageField = RegExp(r'message:\s*([^,\)]+)').firstMatch(value);
    if (messageField != null) {
      value = messageField.group(1)?.trim() ?? value;
    }
    if (value.startsWith('Exception:')) {
      value = value.substring('Exception:'.length).trim();
    }
    return value;
  }

  static String _normalize(String value, {required String fallback}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    final sentence = trimmed[0].toUpperCase() + trimmed.substring(1);
    if (sentence.endsWith('.')) {
      return sentence;
    }
    return '$sentence.';
  }
}
