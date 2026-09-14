import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final signedIn = ref.watch(signedInProvider);
    final user = ref.watch(supabaseClientProvider)?.auth.currentUser;
    final displayName = (user?.userMetadata?['display_name'] as String?) ?? user?.email ?? user?.phone ?? t.text('مستخدم يمني', 'Yemeni user');
    return Scaffold(
      appBar: AppBar(title: Text(t.text('حسابي', 'Account'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
        if (signedIn)
          Row(children: [const CircleAvatar(radius: 30, backgroundColor: AppColors.mint, child: Icon(Icons.person, size: 30, color: AppColors.forest)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(displayName, style: Theme.of(context).textTheme.titleLarge), Text(t.text('حساب مستخدم', 'Personal account'))])), IconButton(tooltip: t.text('تعديل الحساب', 'Edit account'), onPressed: () => _info(context, t.text('تعديل الحساب', 'Edit account'), t.text('يمكن تعديل الاسم والصورة بعد ربط المصادقة والتخزين.', 'Name and avatar editing activates after auth and storage are connected.')), icon: const Icon(Icons.edit_outlined))])
        else
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(t.text('استفد من كل المزايا', 'Unlock every feature'), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)), const SizedBox(height: 6), Text(t.text('سجّل لنشر طلب والتواصل وإدارة صفحاتك.', 'Sign in to post, message and manage your pages.'), style: const TextStyle(color: Color(0xFFCAD5CE))), const SizedBox(height: 14), FilledButton(onPressed: () => context.push('/auth'), child: Text(t.text('تسجيل الدخول', 'Sign in')))])),
        const SizedBox(height: 24),
        _AccountItem(icon: Icons.storefront_outlined, title: t.text('منشآتي وصفحاتي', 'My businesses and pages'), onTap: () {
          if (!signedIn) { context.push('/auth'); return; }
          _info(context, t.text('منشآتي وصفحاتي', 'My businesses and pages'), t.text('لا توجد صفحات مملوكة بعد. يمكنك إضافة منشأة من زر الإضافة.', 'No owned pages yet. Add a business from the Add button.'));
        }),
        _AccountItem(icon: Icons.verified_outlined, title: t.text('التوثيق واستلام صفحة', 'Verification and claim profile'), onTap: () => _info(context, t.text('التوثيق واستلام الصفحة', 'Verification and profile claims'), t.text('ارفع إثبات الملكية بعد ربط التخزين. الطلبات محمية ولا تظهر مستنداتها للعامة.', 'Upload ownership evidence after storage is connected. Documents remain private.'))),
        _AccountItem(icon: Icons.chat_bubble_outline, title: t.text('المحادثات', 'Messages'), onTap: () => context.push(signedIn ? '/chat' : '/auth')),
        _AccountItem(icon: Icons.notifications_outlined, title: t.text('تفضيلات الإشعارات', 'Notification preferences'), onTap: () => _preferences(context)),
        _AccountItem(icon: Icons.language, title: t.text('اللغة', 'Language'), trailing: t.ar ? 'العربية' : 'English', onTap: () => ref.read(localeProvider.notifier).state = Locale(t.ar ? 'en' : 'ar')),
        _AccountItem(icon: Icons.shield_outlined, title: t.text('الخصوصية والأمان', 'Privacy and security'), onTap: () => _info(context, t.text('الخصوصية والأمان', 'Privacy and security'), t.text('الموقع اختياري، ولا نعرض الموقع الدقيق للأفراد. يمكنك طلب حذف الحساب والبيانات من هنا بعد الربط.', 'Location is optional and exact personal locations stay private. Account and data deletion will be available here.'))),
        _AccountItem(icon: Icons.help_outline, title: t.text('المساعدة والدعم', 'Help and support'), onTap: () => _info(context, t.text('المساعدة والدعم', 'Help and support'), 'support@yemeniworld.app')),
        if (signedIn) ...[const Divider(height: 30), TextButton(onPressed: () async => ref.read(authControllerProvider.notifier).signOut(), child: Text(t.text('تسجيل الخروج', 'Sign out'), style: const TextStyle(color: AppColors.coral)))],
      ]),
    );
  }


  void _info(BuildContext context, String title, String body) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10), Text(body, style: Theme.of(context).textTheme.bodyLarge)])));

  void _preferences(BuildContext context) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => const _PreferencesSheet());
}

class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();
  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  bool requests = true;
  bool messages = true;
  bool nearby = false;
  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(t.text('تفضيلات الإشعارات', 'Notification preferences'), style: Theme.of(context).textTheme.titleLarge),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.text('طلبات مناسبة لخدماتي', 'Matching service requests')), value: requests, onChanged: (value) => setState(() => requests = value)),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.text('الرسائل وتحديثات العروض', 'Messages and offer updates')), value: messages, onChanged: (value) => setState(() => messages = value)),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.text('عروض قريبة مني', 'Nearby promotions')), value: nearby, onChanged: (value) => setState(() => nearby = value)),
      FilledButton(onPressed: () => Navigator.pop(context), child: Text(t.text('حفظ', 'Save'))),
    ]));
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({required this.icon, required this.title, required this.onTap, this.trailing});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailing;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: AppColors.forest), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailing != null) Text(trailing!, style: Theme.of(context).textTheme.bodyMedium), const Icon(Icons.chevron_right)]), onTap: onTap);
}
