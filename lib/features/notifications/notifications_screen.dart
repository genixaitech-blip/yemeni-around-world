import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool unreadOnly = false;
  final read = <int>{};
  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final items = [
      (Icons.local_offer_outlined, t.text('وصلك عرض جديد', 'New offer received'), t.text('قدمت أروى عرضًا على طلب التصوير.', 'Arwa submitted an offer on your photography request.'), 'الآن'),
      (Icons.chat_bubble_outline, t.text('رسالة جديدة', 'New message'), t.text('لدي نماذج أعمال إضافية أرسلها لك.', 'I have more work samples to share.'), t.text('منذ 12 دقيقة', '12 min ago')),
      (Icons.verified_outlined, t.text('تم توثيق الصفحة', 'Page verified'), t.text('أصبحت صفحة باب اليمن موثقة.', 'Bab Al Yemen is now verified.'), t.text('أمس', 'Yesterday')),
    ];
    final visible = List.generate(items.length, (index) => index).where((index) => !unreadOnly || !read.contains(index)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t.text('الإشعارات', 'Notifications')), actions: [TextButton(onPressed: () => setState(() => read.addAll(List.generate(items.length, (i) => i))), child: Text(t.text('قراءة الكل', 'Read all')))]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(children: [FilterChip(label: Text(t.text('غير المقروءة فقط', 'Unread only')), selected: unreadOnly, onSelected: (value) => setState(() => unreadOnly = value)), const Spacer(), Text('${visible.length}', style: Theme.of(context).textTheme.bodyMedium)])),
        const Divider(height: 1),
        Expanded(child: visible.isEmpty ? Center(child: Text(t.text('لا توجد إشعارات جديدة', 'No new notifications'))) : ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: visible.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, position) {
          final index = visible[position];
          final item = items[index];
          final isRead = read.contains(index);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: CircleAvatar(backgroundColor: isRead ? const Color(0xFFF0F1EF) : AppColors.mint, child: Icon(item.$1, color: isRead ? AppColors.muted : AppColors.forest)),
            title: Text(item.$2, style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.w900)),
            subtitle: Text('${item.$3}\n${item.$4}'),
            isThreeLine: true,
            onTap: () => setState(() => read.add(index)),
          );
        })),
      ]),
    );
  }
}
