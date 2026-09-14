import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('تفاصيل الطلب', 'Request details'))),
      body: ref.watch(requestsProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (requests) {
          ServiceRequest? request;
          for (final item in requests) { if (item.id == id) request = item; }
          if (request == null) return Center(child: Text(t.text('الطلب غير موجود', 'Request not found')));
          return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 30), children: [
            Text(request.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 9),
            Text('${request.place.city}، ${request.place.country} • ${request.createdAgo}'),
            const SizedBox(height: 20),
            Text(request.description, style: Theme.of(context).textTheme.bodyLarge),
            if (request.budget != null) ...[const SizedBox(height: 18), _Fact(icon: Icons.payments_outlined, label: t.text('الميزانية', 'Budget'), value: '${request.budget} USD')],
            const SizedBox(height: 12),
            _Fact(icon: Icons.schedule, label: t.text('الموعد', 'Schedule'), value: t.text('الجمعة، 6:00 - 10:00 مساءً', 'Friday, 6:00 - 10:00 PM')),
            const SizedBox(height: 28),
            Text('${request.offerCount} ${t.text('عروض مقدمة', 'submitted offers')}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            for (var index = 0; index < 3; index++) _Proposal(index: index),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: () {
              if (ref.read(signedInProvider)) { _showOfferSheet(context); } else { context.push('/auth'); }
            }, icon: const Icon(Icons.send_outlined), label: Text(t.text('تقديم عرض', 'Submit offer'))),
          ]);
        },
      ),
    );
  }

  void _showOfferSheet(BuildContext context) {
    final t = T(context);
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(t.text('قدّم عرضك', 'Submit your offer'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t.text('السعر', 'Price'), suffixText: 'USD')),
        const SizedBox(height: 10),
        TextField(minLines: 3, maxLines: 4, decoration: InputDecoration(labelText: t.text('وصف العرض', 'Offer details'))),
        const SizedBox(height: 10),
        TextField(decoration: InputDecoration(labelText: t.text('مدة التنفيذ', 'Delivery time'))),
        const SizedBox(height: 16),
        FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('تم إرسال عرضك', 'Your offer was submitted')))); }, child: Text(t.text('إرسال العرض', 'Send offer'))),
      ]),
    ));
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.forest), const SizedBox(width: 10), Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w800)), Expanded(child: Text(value))]);
}

class _Proposal extends StatelessWidget {
  const _Proposal({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    const names = ['أروى الحكيمي', 'منار للإنتاج', 'عدنان الصبري'];
    const prices = [850, 980, 700];
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        CircleAvatar(backgroundColor: AppColors.mint, child: Text(names[index][0])),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(names[index], style: const TextStyle(fontWeight: FontWeight.w800)), if (index < 2) const Padding(padding: EdgeInsetsDirectional.only(start: 4), child: Icon(Icons.verified, size: 15, color: AppColors.forest))]), Text('★ ${4.7 + index / 10} • تسليم خلال يومين')])),
        Text('${prices[index]} USD', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forest)),
      ]),
    );
  }
}
