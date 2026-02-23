import 'package:logit/gen/enviro.gen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInitializer {
  static final String _url = Enviro.supabaseUrl;
  static final String _anonKey = Enviro.supabaseKey;
  static bool _isInitialized = false;

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;
  static bool get isInitialized => _isInitialized;

  static String get missingConfigMessage =>
      'Supabase is not configured. Provide SUPABASE_URL and '
      'SUPABASE_ANON_KEY with --dart-define.';

  static Future<void> initialize() async {
    if (!isConfigured || _isInitialized) {
      return;
    }
    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _isInitialized = true;
  }
}
