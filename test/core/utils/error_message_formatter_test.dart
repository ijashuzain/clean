import 'dart:async';
import 'dart:io';

import 'package:logit/core/utils/error_message_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorMessageFormatter.format', () {
    test('maps auth invalid credentials to user friendly message', () {
      final message = ErrorMessageFormatter.format(
        const AuthException('Invalid login credentials'),
      );

      expect(message, 'Invalid email or password.');
    });

    test('maps auth email not confirmed to user friendly message', () {
      final message = ErrorMessageFormatter.format(
        const AuthException('Email not confirmed'),
      );

      expect(message, 'Please confirm your email before logging in.');
    });

    test('formats postgrest message', () {
      final message = ErrorMessageFormatter.format(
        const PostgrestException(
          message: 'duplicate key value violates unique',
        ),
      );

      expect(message, 'Duplicate key value violates unique.');
    });

    test('maps socket exception to no internet message', () {
      final message = ErrorMessageFormatter.format(
        const SocketException('Failed host lookup'),
      );

      expect(message, 'No internet connection. Please check your settings.');
    });

    test('maps timeout exception to timeout message', () {
      final message = ErrorMessageFormatter.format(
        TimeoutException('operation timed out'),
      );

      expect(message, 'Request timed out. Please try again.');
    });

    test('normalizes generic exception and strips prefix', () {
      final message = ErrorMessageFormatter.format(
        Exception('server unavailable'),
      );

      expect(message, 'Server unavailable.');
    });
  });
}
