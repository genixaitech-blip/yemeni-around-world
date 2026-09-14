import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import 'app_theme.dart';
import 'locale_controller.dart';

class PageGutter extends StatelessWidget {
  const PageGutter({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, this.action, this.onTap, super.key});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class ListingTile extends ConsumerWidget {
  const ListingTile({required this.listing, this.compact = false, super.key});
  final Listing listing;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(listing.id);
    return InkWell(
      onTap: () => context.push('/listing/${listing.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 8 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                listing.imageUrl,
                width: compact ? 76 : 104,
                height: compact ? 76 : 104,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: compact ? 76 : 104, height: compact ? 76 : 104, color: AppColors.mint, child: const Icon(Icons.person, color: AppColors.forest)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(listing.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium)),
                    if (listing.verified) const Padding(padding: EdgeInsetsDirectional.only(start: 5), child: Icon(Icons.verified, size: 17, color: AppColors.forest)),
                  ]),
                  const SizedBox(height: 3),
                  Text(listing.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 7),
                  Wrap(spacing: 10, runSpacing: 4, children: [
                    _Meta(icon: Icons.star_rounded, text: '${listing.rating} (${listing.reviewCount})', color: AppColors.gold),
                    _Meta(icon: Icons.location_on_outlined, text: '${listing.place.city}، ${listing.place.country}'),
                    if (listing.distanceKm != null) _Meta(icon: Icons.near_me_outlined, text: '${listing.distanceKm} ${t.text('كم', 'km')}'),
                  ]),
                  if (listing.priceFrom != null) ...[
                    const SizedBox(height: 7),
                    Text('${t.text('يبدأ من', 'From')} ${listing.priceFrom} USD', style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w800)),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: t.text('حفظ', 'Save'),
              onPressed: () {
                if (!ref.read(signedInProvider)) {
                  context.push('/auth');
                  return;
                }
                final next = {...favorites};
                isFavorite ? next.remove(listing.id) : next.add(listing.id);
                ref.read(favoritesProvider.notifier).state = next;
              },
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.coral : AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, this.color = AppColors.muted});
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: color), const SizedBox(width: 3), Text(text, style: Theme.of(context).textTheme.bodyMedium)]);
}

class AsyncBody<ValueT> extends StatelessWidget {
  const AsyncBody({required this.value, required this.builder, super.key});
  final AsyncValue<ValueT> value;
  final Widget Function(ValueT data) builder;
  @override
  Widget build(BuildContext context) => value.when(
    data: builder,
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(T(context).text('تعذر تحميل البيانات. حاول مجددًا.', 'Could not load data. Try again.')))),
  );
}
