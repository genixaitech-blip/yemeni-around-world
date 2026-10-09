import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

const _homeBg = Color(0xFF061C2C);
const _homeBgDeep = Color(0xFF04131E);
const _homeBlue = Color(0xFF0D4563);
const _homeText = Color(0xFFF5F8FA);
const _homeMuted = Color(0xFF9FB2BE);
const _homeLine = Color(0x22FFFFFF);
const _homeSurface = Color(0x12FFFFFF);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    final categories = ref.watch(categoriesProvider);
    final listings = ref.watch(homeListingsProvider);
    final requests = ref.watch(requestsProvider);

    return Scaffold(
      backgroundColor: _homeBg,
      body: Stack(
        children: [
          const Positioned.fill(child: _HomeBackdrop()),
          RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: Colors.white,
            onRefresh: () async {
              ref.invalidate(homeListingsProvider);
              ref.invalidate(categoriesProvider);
              ref.invalidate(requestsProvider);
              await Future.wait([
                ref.read(homeListingsProvider.future),
                ref.read(categoriesProvider.future),
                ref.read(requestsProvider.future),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 34),
              children: [
                _Hero(
                  onNotifications: () => context.push('/notifications'),
                  onSearch: () => context.push('/search'),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.near_me_rounded,
                          title: t.text('قريب مني', 'Near me'),
                          subtitle: t.text('خدمات حول موقعك', 'Services around you'),
                          onTap: () => context.push('/nearby'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.local_offer_rounded,
                          title: t.text('عروض اليوم', 'Today’s offers'),
                          subtitle: t.text('اختيارات مميزة', 'Featured savings'),
                          onTap: () => context.push('/offers'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeading(
                    title: t.text('استكشف حسب التصنيف', 'Explore by category'),
                    action: t.text('عرض الكل', 'See all'),
                    onTap: () => context.push('/search'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 108,
                  child: AsyncBody(
                    value: categories,
                    builder: (items) => ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _CategoryCard(
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
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeading(
                    title: t.text('موصى به لك', 'Recommended for you'),
                    action: t.text('استكشف', 'Explore'),
                    onTap: () => context.push('/search'),
                  ),
                ),
                const SizedBox(height: 12),
                AsyncBody(
                  value: listings,
                  builder: (items) => Column(
                    children: [
                      for (final item in items.take(3))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: _HomeListingCard(child: ListingTile(listing: item)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeading(
                    title: t.text('طلبات حديثة', 'Recent requests'),
                    action: t.text('عرض الكل', 'See all'),
                    onTap: () => context.go('/requests'),
                  ),
                ),
                const SizedBox(height: 12),
                AsyncBody(
                  value: requests,
                  builder: (items) => Column(
                    children: [
                      for (final request in items.take(2))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: _RequestCard(
                            title: request.title,
                            city: request.place.city,
                            offers: request.offerCount,
                            offersLabel: t.text('عروض', 'offers'),
                            onTap: () => context.push('/request/${request.id}'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onNotifications, required this.onSearch});

  final VoidCallback onNotifications;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return SizedBox(
      height: 370,
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _HomeWorldPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _homeLine),
                      ),
                      child: Image.asset('assets/images/app_icon.png'),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        t.text('يمني حول العالم', 'Yemeni Around the World'),
                        style: const TextStyle(
                          color: _homeText,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t.text('الإشعارات', 'Notifications'),
                      onPressed: onNotifications,
                      style: IconButton.styleFrom(
                        foregroundColor: _homeText,
                        backgroundColor: Colors.white.withValues(alpha: .06),
                        side: const BorderSide(color: _homeLine),
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
                Text(
                  t.text('من اليمن إلى كل العالم', 'From Yemen to the whole world'),
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.text(
                    'مجتمعك اليمني، أقرب إليك أينما كنت',
                    'Your Yemeni community, closer wherever you are',
                  ),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 31,
                        height: 1.18,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.text(
                    'اكتشف الأشخاص والمنشآت والخدمات والفرص حول العالم.',
                    'Discover people, businesses, services and opportunities worldwide.',
                  ),
                  style: const TextStyle(
                    color: _homeMuted,
                    height: 1.55,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: onSearch,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .96),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .16),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.navy),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.text('ماذا تبحث عنه؟', 'What are you looking for?'),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.tune_rounded, color: AppColors.navy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: _homeSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _homeLine),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.goldLight, size: 23),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _homeText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _homeMuted,
                          fontSize: 11.5,
                        ),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: _homeSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _homeLine),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 82,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      icon,
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _homeText,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _homeText,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(foregroundColor: AppColors.goldLight),
            child: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
}

class _HomeListingCard extends StatelessWidget {
  const _HomeListingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCF9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.city,
    required this.offers,
    required this.offersLabel,
    required this.onTap,
  });

  final String title;
  final String city;
  final int offers;
  final String offersLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: _homeSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _homeLine),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.goldLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _homeText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$city • $offers $offersLabel',
                        style: const TextStyle(
                          color: _homeMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _homeMuted),
              ],
            ),
          ),
        ),
      );
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_homeBlue, _homeBg, _homeBgDeep],
            stops: [0, .42, 1],
          ),
        ),
      );
}

class _HomeWorldPainter extends CustomPainter {
  const _HomeWorldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .72, 172);
    final radius = math.min(size.width * .46, 180.0);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2AA1D2).withValues(alpha: .15),
          const Color(0xFF2AA1D2).withValues(alpha: .035),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.55));
    canvas.drawCircle(center, radius * 1.55, glow);

    final grid = Paint()
      ..color = const Color(0xFF72B8D2).withValues(alpha: .13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, grid);
    for (final scale in [.42, .72]) {
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
          height: radius * .52,
        ),
        grid,
      );
    }

    final points = [
      Offset(center.dx - radius * .55, center.dy - radius * .18),
      Offset(center.dx - radius * .12, center.dy + radius * .34),
      Offset(center.dx + radius * .18, center.dy - radius * .42),
      Offset(center.dx + radius * .57, center.dy + radius * .02),
      Offset(center.dx + radius * .34, center.dy + radius * .54),
      Offset(center.dx - radius * .43, center.dy + radius * .48),
    ];

    final route = Paint()
      ..color = AppColors.gold.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final origin = points[1];
    for (var i = 0; i < points.length; i++) {
      if (i == 1) continue;
      final target = points[i];
      final path = Path()..moveTo(origin.dx, origin.dy);
      final control = Offset(
        (origin.dx + target.dx) / 2,
        math.min(origin.dy, target.dy) - radius * (.18 + .04 * i),
      );
      path.quadraticBezierTo(control.dx, control.dy, target.dx, target.dy);
      canvas.drawPath(path, route);
    }

    for (var i = 0; i < points.length; i++) {
      final color = i == 1 ? AppColors.goldLight : const Color(0xFF7FD3F2);
      canvas.drawCircle(
        points[i],
        i == 1 ? 4 : 2.8,
        Paint()..color = color.withValues(alpha: .78),
      );
      canvas.drawCircle(
        points[i],
        i == 1 ? 10 : 7,
        Paint()..color = color.withValues(alpha: .07),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeWorldPainter oldDelegate) => false;
}
