import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart';
import 'locale_controller.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});
  final StatefulNavigationShell shell;

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (context) => const _CreateSheet(),
    );
  }

  void _select(BuildContext context, int branch) {
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: t.text('الرئيسية', 'Home'),
                    active: shell.currentIndex == 0,
                    onTap: () => _select(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.search,
                    activeIcon: Icons.search,
                    label: t.text('استكشف', 'Explore'),
                    active: shell.currentIndex == 1,
                    onTap: () => _select(context, 1),
                  ),
                  const SizedBox(width: 64),
                  _NavItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: t.text('المفضلة', 'Saved'),
                    active: shell.currentIndex == 2,
                    onTap: () => _select(context, 2),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: t.text('الطلبات', 'Requests'),
                    active: shell.currentIndex == 3,
                    onTap: () => _select(context, 3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: t.text('حسابي', 'Account'),
                    active: shell.currentIndex == 4,
                    onTap: () => _select(context, 4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -22,
              child: GestureDetector(
                onTap: () => _openCreateSheet(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primary,
                    border: Border.all(color: AppColors.canvas, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: AppColors.goldLight, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navy : AppColors.muted;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
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
                leading: CircleAvatar(backgroundColor: AppColors.skyTint, child: Icon(action.$1, color: AppColors.navy)),
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
