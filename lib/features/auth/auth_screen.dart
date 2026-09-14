import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/app_config.dart';
import '../../core/locale_controller.dart';
import '../../data/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool phone = true;
  bool otpSent = false;
  bool loading = false;
  final controller = TextEditingController();
  final otpController = TextEditingController();
  @override
  void dispose() { controller.dispose(); otpController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 30), children: [
        Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(8)), child: const Text('ي', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
        const SizedBox(height: 24),
        Text(t.text('مرحبًا بك', 'Welcome'), style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(t.text('سجّل عند الحاجة للنشر أو الحفظ أو التواصل. يبقى التصفح متاحًا للضيف.', 'Sign in to post, save, or message. Browsing remains open to guests.'), style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 28),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [ButtonSegment(value: true, label: Text(t.text('رقم الهاتف', 'Phone'))), ButtonSegment(value: false, label: Text(t.text('البريد', 'Email')))],
          selected: {phone},
          onSelectionChanged: (value) => setState(() => phone = value.first),
        ),
        const SizedBox(height: 16),
        TextField(controller: controller, keyboardType: phone ? TextInputType.phone : TextInputType.emailAddress, decoration: InputDecoration(prefixText: phone ? '+967  ' : null, labelText: phone ? t.text('رقم الهاتف', 'Phone number') : t.text('البريد الإلكتروني', 'Email address'))),
        if (phone && otpSent) ...[
          const SizedBox(height: 12),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: t.text('رمز التحقق', 'Verification code')),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton(
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(phone
                  ? (otpSent ? t.text('تأكيد الرمز', 'Verify code') : t.text('إرسال رمز التحقق', 'Send verification code'))
                  : t.text('إرسال رابط الدخول', 'Send sign-in link')),
        ),
        const SizedBox(height: 22),
        Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(t.text('أو', 'or'))), const Expanded(child: Divider())]),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: loading ? null : () => _socialSignIn(OAuthProvider.google), icon: const Icon(Icons.g_mobiledata, size: 28), label: Text(t.text('المتابعة عبر Google', 'Continue with Google'))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: loading ? null : () => _socialSignIn(OAuthProvider.apple), icon: const Icon(Icons.apple), label: Text(t.text('المتابعة عبر Apple', 'Continue with Apple'))),
        if (!AppConfig.hasSupabase) ...[
          const SizedBox(height: 14),
          Text(
            t.text('وضع تجريبي: أضف إعدادات Supabase لتفعيل تسجيل الدخول الحقيقي.', 'Demo mode: add Supabase settings to enable live sign-in.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 18),
        Text(t.text('بالمتابعة أنت توافق على الشروط وسياسة الخصوصية.', 'By continuing, you agree to the Terms and Privacy Policy.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      ])),
    );
  }

  Future<void> _submit() async {
    final t = T(context);
    final value = controller.text.trim();
    if (value.isEmpty) {
      _message(phone ? t.text('أدخل رقم الهاتف', 'Enter your phone number') : t.text('أدخل البريد الإلكتروني', 'Enter your email address'));
      return;
    }
    setState(() => loading = true);
    try {
      final auth = ref.read(authControllerProvider.notifier);
      if (phone && otpSent && AppConfig.hasSupabase) {
        await auth.verifyPhoneOtp(phone: _phoneNumber(value), token: otpController.text.trim());
        if (mounted) context.go('/account');
        return;
      }
      await auth.sendOtp(phone: phone ? _phoneNumber(value) : null, email: phone ? null : value);
      if (!mounted) return;
      if (!AppConfig.hasSupabase) {
        context.go('/account');
      } else if (phone) {
        setState(() => otpSent = true);
        _message(t.text('أرسلنا رمز التحقق إلى هاتفك.', 'We sent a verification code to your phone.'));
      } else {
        _message(t.text('أرسلنا رابط تسجيل الدخول إلى بريدك.', 'We sent a sign-in link to your email.'));
      }
    } catch (error) {
      if (mounted) _message(t.text('تعذر تسجيل الدخول: $error', 'Could not sign in: $error'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _socialSignIn(OAuthProvider provider) async {
    setState(() => loading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithOAuth(provider);
      if (mounted && !AppConfig.hasSupabase) context.go('/account');
    } catch (error) {
      if (mounted) _message(T(context).text('تعذر فتح تسجيل الدخول: $error', 'Could not open sign-in: $error'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _phoneNumber(String value) {
    final compact = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (compact.startsWith('+')) return compact;
    return '+967${compact.replaceFirst(RegExp(r'^0+'), '')}';
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
