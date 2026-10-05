import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});
  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool map = false;
  bool locating = false;
  Position? origin;
  Future<List<Listing>>? results;
  String? locationError;
  Future<void> locate() async {
    setState(() {
      locating = true;
      locationError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('services');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('permission');
      }
      final point = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 20)));
      if (!mounted) return;
      setState(() {
        origin = point;
        results = ref.read(appRepositoryProvider).search(
            nearby: true,
            originLat: point.latitude,
            originLng: point.longitude);
      });
    } catch (_) {
      if (mounted) {
        setState(() => locationError = T(context).text(
            'تعذر تحديد الموقع. فعّل خدمة الموقع واسمح بالوصول إليه، ثم أعد المحاولة.',
            'Could not get location. Enable location services and allow access, then retry.'));
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  void retrySearch() {
    final point = origin;
    if (point != null) {
      setState(() => results = ref.read(appRepositoryProvider).search(
          nearby: true, originLat: point.latitude, originLng: point.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
        appBar: AppBar(title: Text(t.text('قريب مني', 'Nearby')), actions: [
          IconButton(
              tooltip: t.text('تحديث الموقع', 'Refresh location'),
              onPressed: locating ? null : locate,
              icon: const Icon(Icons.my_location)),
          if (origin != null)
            IconButton(
                tooltip:
                    t.text('تبديل الخريطة والقائمة', 'Toggle map and list'),
                onPressed: () => setState(() => map = !map),
                icon: Icon(map ? Icons.view_list : Icons.map_outlined)),
        ]),
        body: locating
            ? const Center(child: CircularProgressIndicator())
            : locationError != null || results == null
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                              locationError ??
                                  t.text(
                                      'استخدم موقعك للعثور على خدمات ضمن 100 كم. الموقع اختياري ولا يُحفظ في حسابك.',
                                      'Use your location to find services within 100 km. Location is optional and is not saved to your account.'),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                              onPressed: locate,
                              child: Text(
                                  t.text('تحديد موقعي', 'Use my location'))),
                        ])))
                : FutureBuilder<List<Listing>>(
                    future: results,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: TextButton(
                                onPressed: retrySearch,
                                child: Text(t.text(
                                    'تعذر تحميل النتائج. أعد المحاولة',
                                    'Could not load results. Retry'))));
                      }
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return Center(
                            child: Text(t.text(
                                'لا توجد خدمات ذات موقع متاح ضمن 100 كم.',
                                'No services with a location found within 100 km.')));
                      }
                      return map
                          ? _MapView(
                              items: items,
                              origin:
                                  LatLng(origin!.latitude, origin!.longitude))
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, index) =>
                                  ListingTile(listing: items[index]));
                    }));
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.items, required this.origin});
  final List<Listing> items;
  final LatLng origin;
  @override
  Widget build(BuildContext context) => FlutterMap(
          options: MapOptions(initialCenter: origin, initialZoom: 11),
          children: [
            TileLayer(
                urlTemplate: const String.fromEnvironment('MAP_TILE_URL',
                    defaultValue:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                userAgentPackageName: 'com.genix.yemeni_world'),
            MarkerLayer(markers: [
              Marker(
                  point: origin,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.my_location,
                      color: Colors.blue, size: 28)),
              for (final item in items)
                if (item.latitude != null && item.longitude != null)
                  Marker(
                      point: LatLng(item.latitude!, item.longitude!),
                      width: 48,
                      height: 48,
                      child: IconButton(
                          tooltip: item.name,
                          icon: const Icon(Icons.location_on,
                              color: AppColors.forest, size: 36),
                          onPressed: () =>
                              context.push('/listing/${item.id}'))),
            ]),
            RichAttributionWidget(attributions: [
              TextSourceAttribution('OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'))),
            ]),
          ]);
}
