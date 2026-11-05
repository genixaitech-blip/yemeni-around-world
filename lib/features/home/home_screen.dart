import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

const _heroTop = Color(0xFF0C3148);
const _heroBottom = Color(0xFF061C2C);
const _heroDeep = Color(0xFF04131E);
const _cream = Color(0xFFF7F3EC);
const _creamStrong = Color(0xFFFFFDFC);
const _softLine = Color(0xFFE9E0D2);
const _nightText = Color(0xFFF7FAFB);
const _nightMuted = Color(0xFF9EB1BD);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final categories = ref.watch(categoriesProvider);
    final listings = ref.watch(homeListingsProvider);
    final requests = ref.watch(requestsProvider);

    return Scaffold(
      backgroundColor: _heroDeep,
      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: Colors.white,
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(homeListingsProvider);
          ref.invalidate(requestsProvider);
          await Future.wait([
            ref.read(categoriesProvider.future),
            ref.read(homeListingsProvider.future),
            ref.read(requestsProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _PremiumHero(
              onSearch: () => context.push('/search'),
              onNotifications: () => context.push('/notifications'),
              onLocation: () => context.push('/search'),
              title: t.text(
                'كل ما تحتاجه من مجتمعك اليمني، في مكان واحد',
                'Your Yemeni community, all in one place',
              ),
              subtitle: t.text(
                'أشخاص، منشآت، خدمات وفرص موثوقة حول العالم.',
                'People, businesses, services and trusted opportunities worldwide.',
              ),
              location: t.text('الرياض، السعودية', 'Riyadh, Saudi Arabia'),
              searchHint: t.text(
                'ابحث عن خدمة، شخص أو منشأة',
                'Search for a service, person or business',
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 38),
                decoration: const BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.near_me_rounded,
                            title: t.text('قريب مني', 'Nearby'),
                            subtitle: t.text(
                              'اكتشف حولك حتى 100 كم',
                              'Discover within 100 km',
                            ),
                            strong: true,
                            onTap: () => context.push('/nearby'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.local_offer_rounded,
                            title: t.text('عروض اليوم', 'Today’s offers'),
                            subtitle: t.text(
                              'وفر على خدمات مختارة',
                              'Save on selected services',
                            ),
                            onTap: () => context.push('/offers'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _SectionHeader(
                      eyebrow: t.text('استكشف', 'Explore'),
                      title: t.text('ما الذي تبحث عنه؟', 'What do you need?'),
                      action: t.text('عرض الكل', 'See all'),
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 112,
                      child: categories.when(
                        data: (items) => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _CategoryTile(
                              icon: item.icon,
                              label: t.ar ? item.nameAr : item.nameEn,
                              onTap: () {
                                ref.read(searchFiltersProvider.notifier).state =
                                    SearchFilters(categoryId: item.id);
                                context.push('/search');
                              },
                            );
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => _InlineError(
                          text: t.text(
                            'تعذر تحميل التصنيفات',
                            'Could not load categories',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _SectionHeader(
                      eyebrow: t.text('مختارات', 'Curated'),
                      title: t.text('موصى به لك', 'Recommended for you'),
                      action: t.text('استكشف', 'Explore'),
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 254,
                      child: listings.when(
                        data: (items) => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: math.min(items.length, 5),
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              _FeaturedListingCard(listing: items[index]),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => _InlineError(
                          text: t.text(
                            'تعذر تحميل الترشيحات',
                            'Could not load recommendations',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _SectionHeader(
                      eyebrow: t.text('المجتمع', 'Community'),
                      title: t.text('طلبات حديثة', 'Recent requests'),
                      action: t.text('عرض الكل', 'See all'),
                      onTap: () => context.go('/requests'),
                    ),
                    const SizedBox(height: 14),
                    requests.when(
                      data: (items) => Column(
                        children: [
                          for (final request in items.take(3)) ...[
                            _RequestPreviewCard(
                              request: request,
                              onTap: () =>
                                  context.push('/request/${request.id}'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => _InlineError(
                        text: t.text(
                          'تعذر تحميل الطلبات',
                          'Could not load requests',
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero({
    required this.onSearch,
    required this.onNotifications,
    required this.onLocation,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.searchHint,
  });

  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onLocation;
  final String title;
  final String subtitle;
  final String location;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 344,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_heroTop, _heroBottom],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _WorldHeroPainter()),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .11),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'يمني حول العالم',
                              style: TextStyle(
                                color: _nightText,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            InkWell(
                              onTap: onLocation,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.goldLight,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        color: _nightMuted,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 15,
                                      color: _nightMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: onNotifications,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: .07),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: .11),
                          ),
                        ),
                        icon: const Badge(
                          smallSize: 7,
                          backgroundColor: AppColors.gold,
                          child: Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: _nightText,
                            fontSize: 29,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.3,
                          ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 355),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: _nightMuted,
                        fontSize: 13.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: _creamStrong,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 0,
                    child: InkWell(
                      onTap: onSearch,
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 58,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.navy,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                searchHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              margin: const EdgeInsetsDirectional.only(end: 8),
                              decoration: BoxDecoration(
                                color: AppColors.skyTint,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.navy,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.strong = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final bg = strong ? AppColors.navy : _creamStrong;
    final fg = strong ? Colors.white : AppColors.ink;
    final sub = strong ? const Color(0xFFBFD1DB) : AppColors.muted;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: strong ? AppColors.navy : _softLine),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: strong
                          ? Colors.white.withValues(alpha: .1)
                          : AppColors.skyTint,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: strong ? AppColors.goldLight : AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: strong ? AppColors.goldLight : AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: sub,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _creamStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(color: _softLine),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: SizedBox(
          width: 86,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.skyTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedListingCard extends StatelessWidget {
  const _FeaturedListingCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Material(
      color: _creamStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: _softLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        child: SizedBox(
          width: 248,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    listing.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: AppColors.skyTint,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.navy,
                        size: 34,
                      ),
                    ),
                  ),
                  if (listing.availableNow)
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xEFFFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.text('متاح الآن', 'Available now'),
                          style: const TextStyle(
                            color: Color(0xFF16724E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (listing.verified)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(start: 5),
                            child: Icon(
                              Icons.verified_rounded,
                              color: AppColors.navy,
                              size: 17,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      listing.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.gold,
                          size: 17,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${listing.rating}',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            listing.place.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        if (listing.priceFrom != null)
                          Text(
                            '${listing.priceFrom} USD',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestPreviewCard extends StatelessWidget {
  const _RequestPreviewCard({
    required this.request,
    required this.onTap,
  });

  final ServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Material(
      color: _creamStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _softLine),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2DC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: AppColors.goldDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${request.place.city} • ${request.createdAgo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _MetaPill(
                          text:
                              '${request.offerCount} ${t.text('عروض', 'offers')}',
                        ),
                        if (request.budget != null)
                          _MetaPill(
                            text:
                                '${request.budget} ${request.currency}',
                            emphasized: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text, this.emphasized = false});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: emphasized ? AppColors.skyTint : const Color(0xFFF0ECE5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: emphasized ? AppColors.navy : AppColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.muted),
        ),
      );
}

class _WorldHeroPainter extends CustomPainter {
  const _WorldHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .78, size.height * .43);
    final radius = math.min(size.width * .38, 140.0);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4BB5DE).withValues(alpha: .13),
          const Color(0xFF4BB5DE).withValues(alpha: .025),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.6),
      );
    canvas.drawCircle(center, radius * 1.6, glow);

    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(circle);

    final water = Paint()
      ..color = const Color(0xFF0B405B).withValues(alpha: .28);
    canvas.drawCircle(center, radius, water);

    final grid = Paint()
      ..color = const Color(0xFF9DD4E7).withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final scale in [.46, .76]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * scale,
          height: radius * 2,
        ),
        grid,
      );
    }
    for (final factor in [-.55, 0.0, .55]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * factor),
          width: radius * 1.9,
          height: radius * .5,
        ),
        grid,
      );
    }

    final land = Paint()
      ..color = const Color(0xFF84B7C8).withValues(alpha: .13)
      ..style = PaintingStyle.fill;

    final africa = Path()
      ..moveTo(center.dx - radius * .08, center.dy - radius * .2)
      ..quadraticBezierTo(
        center.dx + radius * .16,
        center.dy - radius * .06,
        center.dx + radius * .07,
        center.dy + radius * .32,
      )
      ..quadraticBezierTo(
        center.dx - radius * .03,
        center.dy + radius * .56,
        center.dx - radius * .18,
        center.dy + radius * .22,
      )
      ..quadraticBezierTo(
        center.dx - radius * .28,
        center.dy + radius * .04,
        center.dx - radius * .08,
        center.dy - radius * .2,
      )
      ..close();

    final europeAsia = Path()
      ..moveTo(center.dx - radius * .18, center.dy - radius * .28)
      ..quadraticBezierTo(
        center.dx + radius * .15,
        center.dy - radius * .55,
        center.dx + radius * .56,
        center.dy - radius * .26,
      )
      ..quadraticBezierTo(
        center.dx + radius * .68,
        center.dy - radius * .04,
        center.dx + radius * .38,
        center.dy + radius * .02,
      )
      ..quadraticBezierTo(
        center.dx + radius * .18,
        center.dy + radius * .04,
        center.dx - radius * .04,
        center.dy - radius * .08,
      )
      ..close();

    final arabia = Path()
      ..moveTo(center.dx + radius * .04, center.dy - radius * .02)
      ..lineTo(center.dx + radius * .22, center.dy + radius * .01)
      ..lineTo(center.dx + radius * .18, center.dy + radius * .16)
      ..lineTo(center.dx + radius * .02, center.dy + radius * .1)
      ..close();

    canvas.drawPath(africa, land);
    canvas.drawPath(europeAsia, land);
    canvas.drawPath(arabia, land);

    canvas.restore();

    final rim = Paint()
      ..color = const Color(0xFF9DD4E7).withValues(alpha: .17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius, rim);

    final yemen = Offset(
      center.dx + radius * .09,
      center.dy + radius * .12,
    );
    final destinations = [
      Offset(center.dx - radius * .62, center.dy - radius * .1),
      Offset(center.dx - radius * .28, center.dy + radius * .54),
      Offset(center.dx + radius * .52, center.dy - radius * .38),
      Offset(center.dx + radius * .62, center.dy + radius * .22),
    ];
    final route = Paint()
      ..color = AppColors.gold.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    for (var i = 0; i < destinations.length; i++) {
      final target = destinations[i];
      final path = Path()..moveTo(yemen.dx, yemen.dy);
      final control = Offset(
        (yemen.dx + target.dx) / 2,
        math.min(yemen.dy, target.dy) - radius * (.18 + i * .035),
      );
      path.quadraticBezierTo(
        control.dx,
        control.dy,
        target.dx,
        target.dy,
      );
      canvas.drawPath(path, route);
      canvas.drawCircle(
        target,
        2.4,
        Paint()
          ..color = const Color(0xFF8AD9F3).withValues(alpha: .7),
      );
    }

    canvas.drawCircle(
      yemen,
      4.2,
      Paint()..color = AppColors.goldLight,
    );
    canvas.drawCircle(
      yemen,
      10,
      Paint()..color = AppColors.gold.withValues(alpha: .08),
    );
  }

  @override
  bool shouldRepaint(covariant _WorldHeroPainter oldDelegate) => false;
}
