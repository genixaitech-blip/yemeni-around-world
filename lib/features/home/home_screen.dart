import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final categories = ref.watch(categoriesProvider);
    final listings = ref.watch(homeListingsProvider);
    final requests = ref.watch(requestsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(6)), child: const Text('ي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
          const SizedBox(width: 10),
          Text(t.text('يمني حول العالم', 'Yemeni Worldwide'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ]),
        actions: [IconButton(tooltip: t.text('الإشعارات', 'Notifications'), onPressed: () => context.push('/notifications'), icon: const Badge(smallSize: 7, child: Icon(Icons.notifications_none)))],
      ),
      body: RefreshIndicator(
        onRefresh: () async { ref.invalidate(homeListingsProvider); ref.invalidate(categoriesProvider); },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            PageGutter(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              InkWell(
                onTap: () => context.push('/search'),
                child: const Row(children: [Icon(Icons.location_on_outlined, size: 19), SizedBox(width: 5), Text('الرياض، السعودية', style: TextStyle(fontWeight: FontWeight.w700)), Icon(Icons.keyboard_arrow_down)]),
              ),
              const SizedBox(height: 14),
              TextField(
                readOnly: true,
                onTap: () => context.push('/search'),
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t.text('ماذا تبحث عنه؟', 'What are you looking for?'), suffixIcon: const Icon(Icons.tune)),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _QuickAction(icon: Icons.near_me_outlined, title: t.text('قريب مني', 'Near me'), subtitle: t.text('حسب المسافة', 'By distance'), onTap: () => context.push('/nearby'))),
                const SizedBox(width: 10),
                Expanded(child: _QuickAction(icon: Icons.local_offer_outlined, title: t.text('عروض اليوم', 'Today’s offers'), subtitle: t.text('وفر أكثر', 'Save more'), onTap: () => context.push('/offers'))),
              ]),
              const SizedBox(height: 26),
              SectionHeading(title: t.text('التصنيفات', 'Categories'), action: t.text('عرض الكل', 'See all'), onTap: () => context.push('/search')),
            ])),
            SizedBox(
              height: 104,
              child: AsyncBody(value: categories, builder: (items) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () { ref.read(searchFiltersProvider.notifier).state = SearchFilters(categoryId: item.id); context.push('/search'); },
                    child: SizedBox(width: 72, child: Column(children: [
                      Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: index.isEven ? AppColors.mint : const Color(0xFFFFECE7), borderRadius: BorderRadius.circular(8)), child: Text(item.icon, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                      const SizedBox(height: 7),
                      Text(t.ar ? item.nameAr : item.nameEn, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ])),
                  );
                },
              )),
            ),
            const SizedBox(height: 18),
            PageGutter(child: Column(children: [
              SectionHeading(title: t.text('موصى به لك', 'Recommended'), action: t.text('استكشف', 'Explore'), onTap: () => context.push('/search')),
              AsyncBody(value: listings, builder: (items) => Column(children: [for (final item in items.take(3)) ...[ListingTile(listing: item), const Divider(height: 1)]])),
              const SizedBox(height: 24),
              SectionHeading(title: t.text('طلبات حديثة', 'Recent requests'), action: t.text('عرض الكل', 'See all'), onTap: () => context.go('/requests')),
              AsyncBody(value: requests, builder: (items) => Column(children: items.take(2).map((request) => ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => context.push('/request/${request.id}'),
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFECE7), child: Icon(Icons.campaign_outlined, color: AppColors.coral)),
                title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${request.place.city} • ${request.offerCount} ${t.text('عروض', 'offers')}'),
                trailing: const Icon(Icons.chevron_right),
              )).toList())),
            ])),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.line)),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
        Icon(icon, color: AppColors.forest, size: 26),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)])),
      ])),
    ),
  );
}
