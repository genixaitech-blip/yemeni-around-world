import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppConfig {
  static const environment = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'io.supabase.yemeniworld://login-callback/',
  );

  static bool get hasSupabase {
    final uri = Uri.tryParse(supabaseUrl);
    return uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('your-');
  }

  static Future<void> initialize() async {
    if (!hasSupabase) return;
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }
}
