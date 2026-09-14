import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';

class AppAuthController extends StateNotifier<bool> {
  AppAuthController(this._client) : super(_client?.auth.currentSession != null) {
    _subscription = _client?.auth.onAuthStateChange.listen((event) {
      state = event.session != null;
    });
  }

  final SupabaseClient? _client;
  StreamSubscription<AuthState>? _subscription;

  bool get isDemo => _client == null;

  Future<void> sendOtp({String? phone, String? email}) async {
    if (_client == null) {
      state = true;
      return;
    }
    await _client.auth.signInWithOtp(
      phone: phone,
      email: email,
      emailRedirectTo: email == null ? null : AppConfig.authRedirectUrl,
      shouldCreateUser: true,
    );
  }

  Future<void> verifyPhoneOtp({required String phone, required String token}) async {
    if (_client == null) {
      state = true;
      return;
    }
    await _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    if (_client == null) {
      state = true;
      return;
    }
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: AppConfig.authRedirectUrl,
    );
  }

  Future<void> signOut() async {
    if (_client != null) await _client.auth.signOut();
    state = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
