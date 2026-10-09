import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart';
import 'locale_controller.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});
  final StatefulNavigationShell shell;

  void _select(BuildContext context, int index) {
    if (index == 2) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => const _CreateSheet(),
      );
      return;
    }
    final branch = index > 2 ? index - 1 : index;
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final visibleIndex = shell.currentIndex >= 2 ? shell.currentIndex + 1 : shell.currentIndex;
    final onHome = shell.currentIndex == 0;
    final navTheme = NavigationBarThemeData(
      height: 68,
      backgroundColor: onHome ? const Color(0xFF04131E) : Colors.white,
      indicatorColor: onHome
          ? AppColors.gold.withValues(alpha: .16)
          : AppColors.skyTint,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: onHome
              ? (selected ? AppColors.goldLight : const Color(0xFF8297A3))
              : (selected ? AppColors.navy : AppColors.muted),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: onHome
              ? (selected ? AppColors.goldLight : const Color(0xFF8297A3))
              : (selected ? AppColors.navy : AppColors.muted),
        );
      }),
    );

    return Scaffold(
      body: shell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(navigationBarTheme: navTheme),
        child: NavigationBar(
          selectedIndex: visibleIndex,
          onDestinationSelected: (index) => _select(context, index),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: t.text('الرئيسية', 'Home')),
            NavigationDestination(icon: const Icon(Icons.search), label: t.text('استكشف', 'Explore')),
            NavigationDestination(icon: const Icon(Icons.add_circle, color: AppColors.coral, size: 32), label: t.text('إضافة', 'Add')),
            NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: const Icon(Icons.favorite), label: t.text('المفضلة', 'Saved')),
            NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: t.text('الطلبات', 'Requests')),
            NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: t.text('حسابي', 'Account')),
          ],
        ),
      ),
    );
  }
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final actions = [
      (Icons.campaign_outlined, t.text('نشر طلب خدمة', 'Post a service request'), '/request/new'),
      (Icons.person_add_alt, t.text('إضافة خدمة شخصية', 'Add personal service'), '/auth'),
      (Icons.storefront_outlined, t.text('إضافة منشأة', 'Add a business'), '/auth'),
      (Icons.local_offer_outlined, t.text('إضافة عرض', 'Add an offer'), '/auth'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.text('ماذا تريد أن تضيف؟', 'What would you like to add?'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final action in actions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: AppColors.mint, child: Icon(action.$1, color: AppColors.forest)),
                title: Text(action.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () { Navigator.pop(context); context.push(action.$3); },
              ),
          ],
        ),
      ),
    );
  }
}
