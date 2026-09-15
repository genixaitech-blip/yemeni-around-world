import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('المفضلة', 'Saved'))),
      body: AsyncBody(value: ref.watch(homeListingsProvider), builder: (items) {
        final saved = items.where((item) => favorites.contains(item.id)).toList();
        if (saved.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite_border, size: 54), const SizedBox(height: 12),
            Text(t.text('لا توجد عناصر محفوظة', 'Nothing saved yet'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8), Text(t.text('احفظ الأشخاص والمنشآت للعودة إليهم بسهولة.', 'Save people and businesses to find them quickly.'), textAlign: TextAlign.center),
            const SizedBox(height: 16), FilledButton(onPressed: () => context.go('/search'), child: Text(t.text('ابدأ الاستكشاف', 'Start exploring'))),
          ])));
        }
        return ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), itemCount: saved.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, index) => ListingTile(listing: saved[index]));
      }),
    );
  }
}
