import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('طلبات الخدمات', 'Service requests'))),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/request/new'), icon: const Icon(Icons.add), label: Text(t.text('نشر طلب', 'Post request'))),
      body: AsyncBody(value: ref.watch(requestsProvider), builder: (requests) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 90),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final request = requests[index];
          return InkWell(
            onTap: () => context.push('/request/${request.id}'),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(request.title, style: Theme.of(context).textTheme.titleMedium)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(6)), child: Text('${request.offerCount} ${t.text('عروض', 'offers')}', style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w800)))]),
              const SizedBox(height: 7),
              Text(request.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.location_on_outlined, size: 16), Text('${request.place.city}، ${request.place.country}'), const Spacer(), Text(request.createdAgo, style: Theme.of(context).textTheme.bodyMedium)]),
              if (request.budget != null) ...[const SizedBox(height: 8), Text('${t.text('الميزانية', 'Budget')}: ${request.budget} USD', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forest))],
            ])),
          );
        },
      )),
    );
  }
}
