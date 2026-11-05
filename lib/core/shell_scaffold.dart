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
        backgroundColor: Colors.white,
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
    final visibleIndex =
        shell.currentIndex >= 2 ? shell.currentIndex + 1 : shell.currentIndex;

    final navTheme = NavigationBarThemeData(
      height: 66,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.skyTint,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.navy : AppColors.muted,
          size: selected ? 24 : 22,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.navy : AppColors.muted,
        );
      }),
    );

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .12),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: navTheme,
              ),
              child: NavigationBar(
                selectedIndex: visibleIndex,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (index) => _select(context, index),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: t.text('الرئيسية', 'Home'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.search_rounded),
                    label: t.text('استكشف', 'Explore'),
                  ),
                  NavigationDestination(
                    icon: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF061C2C),
                        size: 28,
                      ),
                    ),
                    label: t.text('إضافة', 'Add'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border_rounded),
                    selectedIcon: const Icon(Icons.favorite_rounded),
                    label: t.text('المفضلة', 'Saved'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long_rounded),
                    label: t.text('الطلبات', 'Requests'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: t.text('حسابي', 'Account'),
                  ),
                ],
              ),
            ),
          ),
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
      (
        Icons.campaign_outlined,
        t.text('نشر طلب خدمة', 'Post a service request'),
        t.text('اطلب خدمة من المجتمع بسهولة', 'Ask the community for a service'),
        '/request/new',
      ),
      (
        Icons.person_add_alt_rounded,
        t.text('إضافة خدمة شخصية', 'Add personal service'),
        t.text('اعرض خبرتك أو خدمتك', 'Offer your skills or service'),
        '/auth',
      ),
      (
        Icons.storefront_outlined,
        t.text('إضافة منشأة', 'Add a business'),
        t.text('أنشئ صفحة لمنشأتك', 'Create a page for your business'),
        '/auth',
      ),
      (
        Icons.local_offer_outlined,
        t.text('إضافة عرض', 'Add an offer'),
        t.text('شارك عرضًا أو خصمًا جديدًا', 'Publish a new deal'),
        '/auth',
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.text('ماذا تريد أن تضيف؟', 'What would you like to add?'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              t.text(
                'اختر الإجراء المناسب وسنكمل معك الخطوات.',
                'Choose an action and we will guide you through it.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            for (final action in actions)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.skyTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.$1, color: AppColors.navy),
                ),
                title: Text(
                  action.$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(action.$3),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  context.push(action.$4);
                },
              ),
          ],
        ),
      ),
    );
  }
}
