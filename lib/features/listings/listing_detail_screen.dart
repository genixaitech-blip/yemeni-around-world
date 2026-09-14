import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.id, super.key});
  final String id;

  Future<void> _openDirections(Listing listing, BuildContext context) async {
    final destination = listing.latitude != null ? '${listing.latitude},${listing.longitude}' : Uri.encodeComponent('${listing.name} ${listing.place.city}');
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destination');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(T(context).text('تعذر فتح تطبيق الخرائط.', 'Could not open maps.'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(appRepositoryProvider);
    return FutureBuilder<Listing?>(
      future: repository.getListing(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final listing = snapshot.data;
        if (listing == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(T(context).text('الصفحة غير موجودة', 'Listing not found'))));
        return _ListingView(listing: listing, onDirections: () => _openDirections(listing, context));
      },
    );
  }
}

class _ListingView extends ConsumerWidget {
  const _ListingView({required this.listing, required this.onDirections});
  final Listing listing;
  final VoidCallback onDirections;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final saved = ref.watch(favoritesProvider).contains(listing.id);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 268,
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          actions: [
            IconButton(tooltip: t.text('مشاركة', 'Share'), onPressed: () async {
              await Clipboard.setData(ClipboardData(text: 'https://yemeniworld.app/listing/${listing.id}'));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('تم نسخ رابط الصفحة', 'Profile link copied'))));
            }, icon: const Icon(Icons.ios_share)),
            IconButton(tooltip: t.text('حفظ', 'Save'), onPressed: () {
              if (!ref.read(signedInProvider)) { context.push('/auth'); return; }
              final next = {...ref.read(favoritesProvider)};
              saved ? next.remove(listing.id) : next.add(listing.id);
              ref.read(favoritesProvider.notifier).state = next;
            }, icon: Icon(saved ? Icons.favorite : Icons.favorite_border)),
          ],
          flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
            Image.network(listing.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.ink)),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xB017211B)]))),
          ])),
        ),
        SliverToBoxAdapter(child: PageGutter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Flexible(child: Text(listing.name, style: Theme.of(context).textTheme.headlineMedium)), if (listing.verified) const Padding(padding: EdgeInsetsDirectional.only(start: 7), child: Icon(Icons.verified, color: AppColors.forest))]),
              const SizedBox(height: 4),
              Text(listing.subtitle, style: Theme.of(context).textTheme.bodyLarge),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFFFF5D8), borderRadius: BorderRadius.circular(7)), child: Row(children: [const Icon(Icons.star_rounded, color: AppColors.gold, size: 20), Text('${listing.rating}', style: const TextStyle(fontWeight: FontWeight.w900))])),
          ]),
          const SizedBox(height: 12),
          Text('${listing.reviewCount} ${t.text('تقييمًا', 'reviews')} • ${listing.place.city}، ${listing.place.country}', style: Theme.of(context).textTheme.bodyMedium),
          if (listing.availableNow) ...[const SizedBox(height: 8), Row(children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF16A36A), shape: BoxShape.circle)), const SizedBox(width: 6), Text(t.text('متاح الآن', 'Available now'), style: const TextStyle(color: Color(0xFF16724E), fontWeight: FontWeight.w700))])],
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: () => context.push(ref.read(signedInProvider) ? '/chat' : '/auth'), icon: const Icon(Icons.chat_bubble_outline), label: Text(t.text('مراسلة', 'Message')))),
            const SizedBox(width: 8),
            IconButton.filledTonal(tooltip: 'WhatsApp', onPressed: () async {
              final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent('مرحبًا، وصلت إليك عبر تطبيق يمني حول العالم')}');
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('تعذر فتح واتساب', 'Could not open WhatsApp'))));
            }, icon: const Icon(Icons.phone_outlined)),
            if (listing.type == ListingType.business) ...[const SizedBox(width: 8), IconButton.filledTonal(tooltip: t.text('الاتجاهات', 'Directions'), onPressed: onDirections, icon: const Icon(Icons.directions_outlined))],
          ]),
          const SizedBox(height: 28),
          Text(t.text('نبذة', 'About'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(listing.about, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          const Divider(),
          _InfoRow(icon: Icons.translate, title: t.text('اللغات', 'Languages'), value: listing.languages.join(' • ')),
          _InfoRow(icon: Icons.location_city_outlined, title: t.text('منطقة الخدمة', 'Service area'), value: '${listing.place.city}، ${listing.place.country}'),
          if (listing.priceFrom != null) _InfoRow(icon: Icons.payments_outlined, title: t.text('السعر التقريبي', 'Estimated price'), value: '${t.text('يبدأ من', 'From')} ${listing.priceFrom} USD'),
          const SizedBox(height: 22),
          Text(t.text('آراء العملاء', 'Reviews'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)), SizedBox(width: 9), Expanded(child: Text('عبدالله أحمد', style: TextStyle(fontWeight: FontWeight.w800))), Text('★★★★★', style: TextStyle(color: AppColors.gold))]),
            const SizedBox(height: 9),
            Text(t.text('تواصل سريع وتعامل ممتاز، وكانت المعلومات في الصفحة دقيقة.', 'Fast response, excellent service, and accurate profile details.')),
          ])),
          const SizedBox(height: 36),
        ]))),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.forest), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(value)])),
  ]));
}
