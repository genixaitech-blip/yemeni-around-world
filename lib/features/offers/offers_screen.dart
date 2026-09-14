import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('العروض', 'Offers'))),
      body: AsyncBody(value: ref.watch(dealsProvider), builder: (offers) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final offer = offers[index];
          final discount = ((offer.oldPrice - offer.newPrice) / offer.oldPrice * 100).round();
          return Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: index == 0 ? AppColors.ink : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: index == 0 ? AppColors.ink : AppColors.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(5)), child: Text('$discount%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const Spacer(), Text(offer.endsIn, style: TextStyle(color: index == 0 ? const Color(0xFFCAD5CE) : AppColors.muted))]),
              const SizedBox(height: 18),
              Text(offer.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: index == 0 ? Colors.white : AppColors.ink)),
              const SizedBox(height: 5),
              Text('${offer.businessName} • ${offer.city}', style: TextStyle(color: index == 0 ? const Color(0xFFCAD5CE) : AppColors.muted)),
              const SizedBox(height: 14),
              Row(children: [Text('${offer.newPrice} USD', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: index == 0 ? Colors.white : AppColors.forest)), const SizedBox(width: 9), Text('${offer.oldPrice} USD', style: TextStyle(decoration: TextDecoration.lineThrough, color: index == 0 ? const Color(0xFFCAD5CE) : AppColors.muted))]),
            ]),
          );
        },
      )),
    );
  }
}
