import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final countries = const ['السعودية', 'مصر', 'ماليزيا', 'الهند', 'أمريكا'];
  final cities = const ['الرياض', 'جدة', 'القاهرة', 'كوالالمبور', 'نيودلهي', 'نيويورك'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchFiltersProvider).query);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _search() {
    final old = ref.read(searchFiltersProvider);
    ref.read(searchFiltersProvider.notifier).state = old.copyWith(query: _controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final filters = ref.watch(searchFiltersProvider);
    final categories = ref.watch(categoriesProvider);
    final results = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('استكشف', 'Explore')), actions: [
        IconButton(
          tooltip: t.text('مسح الفلاتر', 'Clear filters'),
          onPressed: () { _controller.clear(); ref.read(searchFiltersProvider.notifier).state = const SearchFilters(); },
          icon: const Icon(Icons.restart_alt),
        ),
      ]),
      body: Column(children: [
        PageGutter(child: Column(children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: t.text('مثال: مترجم يمني في نيودلهي', 'Example: Yemeni translator in New Delhi'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(tooltip: t.text('بحث', 'Search'), onPressed: _search, icon: const Icon(Icons.arrow_forward)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            _FilterMenu(label: filters.country ?? t.text('الدولة', 'Country'), items: countries, onSelected: (value) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(country: value)),
            const SizedBox(width: 8),
            _FilterMenu(label: filters.city ?? t.text('المدينة', 'City'), items: cities, onSelected: (value) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(city: value)),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.near_me_outlined, size: 17),
              label: Text(t.text('قريب مني', 'Near me')),
              selected: filters.nearby,
              onSelected: (value) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(nearby: value),
            ),
          ])),
        ])),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: categories.when(
            data: (items) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, index) {
                final item = items[index];
                return ChoiceChip(
                  label: Text(t.ar ? item.nameAr : item.nameEn),
                  selected: filters.categoryId == item.id,
                  onSelected: (selected) => ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                    query: filters.query,
                    country: filters.country,
                    city: filters.city,
                    categoryId: selected ? item.id : null,
                    nearby: filters.nearby,
                  ),
                );
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        const Divider(height: 20),
        Expanded(child: AsyncBody(value: results, builder: (items) {
          if (items.isEmpty) return _EmptySearch(onReset: () { _controller.clear(); ref.read(searchFiltersProvider.notifier).state = const SearchFilters(); });
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => ListingTile(listing: items[index]),
          );
        })),
      ]),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.label, required this.items, required this.onSelected});
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    onSelected: onSelected,
    itemBuilder: (_) => items.map((item) => PopupMenuItem(value: item, child: Text(item))).toList(),
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(width: 5), const Icon(Icons.keyboard_arrow_down, size: 18)]),
    ),
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.onReset});
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.manage_search, size: 60, color: AppColors.muted),
      const SizedBox(height: 12),
      Text(t.text('لم نجد نتائج مطابقة', 'No matching results'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text(t.text('جرّب مدينة أخرى أو قلل عدد الفلاتر.', 'Try another city or remove some filters.'), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: onReset, child: Text(t.text('مسح الفلاتر', 'Clear filters'))),
    ])));
  }
}
