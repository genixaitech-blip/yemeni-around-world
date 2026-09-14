import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/app_repository.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});
  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool map = false;
  late Future<List<Listing>> results;
  @override
  void initState() { super.initState(); results = ref.read(appRepositoryProvider).search(nearby: true); }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('قريب مني', 'Nearby')), actions: [
        Padding(padding: const EdgeInsetsDirectional.only(end: 12), child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [ButtonSegment(value: false, icon: const Icon(Icons.view_list), tooltip: t.text('قائمة', 'List')), ButtonSegment(value: true, icon: const Icon(Icons.map_outlined), tooltip: t.text('خريطة', 'Map'))],
          selected: {map},
          onSelectionChanged: (value) => setState(() => map = value.first),
        )),
      ]),
      body: FutureBuilder<List<Listing>>(
        future: results,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: map ? _MapView(items: items) : _ListView(items: items));
        },
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.items});
  final List<Listing> items;
  @override
  Widget build(BuildContext context) => ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), itemCount: items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, index) => ListingTile(listing: items[index]));
}

class _MapView extends StatelessWidget {
  const _MapView({required this.items});
  final List<Listing> items;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: CustomPaint(painter: _MapPainter())),
    for (var i = 0; i < items.length; i++)
      Positioned(
        left: (35 + (i * 93) % math.max(120, MediaQuery.sizeOf(context).width.toInt() - 110)).toDouble(),
        top: (75 + (i * 118) % math.max(160, MediaQuery.sizeOf(context).height.toInt() - 300)).toDouble(),
        child: Tooltip(
          message: items[i].name,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(7), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8)]), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 16, color: Colors.white), const SizedBox(width: 3), Text(items[i].distanceKm == null ? items[i].name : '${items[i].distanceKm!.toStringAsFixed(1)} كم', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])),
        ),
      ),
    Positioned(left: 16, right: 16, bottom: 18, child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 16)]),
      child: Row(children: [const Icon(Icons.privacy_tip_outlined, color: AppColors.forest), const SizedBox(width: 10), Expanded(child: Text(T(context).text('نعرض المواقع العامة فقط، ومناطق خدمة تقريبية للأفراد.', 'Only public locations and approximate service areas are shown.'), style: Theme.of(context).textTheme.bodyMedium))]),
    )),
  ]);
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9EFEA));
    final road = Paint()..color = Colors.white..strokeWidth = 13..style = PaintingStyle.stroke;
    final minor = Paint()..color = const Color(0xFFD2DED5)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (var i = -1; i < 7; i++) {
      final y = i * 105.0;
      canvas.drawPath(Path()..moveTo(0, y + 45)..quadraticBezierTo(size.width * .5, y - 5, size.width, y + 48), road);
      canvas.drawLine(Offset(i * 90.0, 0), Offset(i * 90.0 + 180, size.height), minor);
    }
    canvas.drawCircle(Offset(size.width * .48, size.height * .42), 10, Paint()..color = const Color(0xFF2378D4));
    canvas.drawCircle(Offset(size.width * .48, size.height * .42), 22, Paint()..color = const Color(0x332378D4));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
