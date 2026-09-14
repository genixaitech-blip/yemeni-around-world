import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/onboarding.png', fit: BoxFit.cover),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x5517211B), Color(0xF217211B)], stops: [.2, .86]))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const _Mark(),
                  const Spacer(),
                  SegmentedButton<String>(
                    style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
                    segments: const [ButtonSegment(value: 'ar', label: Text('عربي')), ButtonSegment(value: 'en', label: Text('EN'))],
                    selected: {Localizations.localeOf(context).languageCode},
                    onSelectionChanged: (value) => ref.read(localeProvider.notifier).state = Locale(value.first),
                  ),
                ],
              ),
              const Spacer(),
              Text('يمني\nحول العالم', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: 48)),
              const SizedBox(height: 18),
              Text(
                t.text('أشخاص وخدمات ومنشآت يمنية، أينما كانت وجهتك.', 'Yemeni people, services and businesses, wherever you are headed.'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFFCAD5CE), fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF223128), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: AppColors.coral, size: 34),
                  const SizedBox(width: 16),
                  Expanded(child: Text(t.text('ابحث قبل سفرك أو اكتشف ما حولك الآن', 'Plan before you travel or discover what is nearby'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                ]),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.go('/home'), child: Text(t.text('ابدأ الاستكشاف', 'Start exploring'))),
              const SizedBox(height: 8),
              TextButton(onPressed: () => context.push('/auth'), child: Text(t.text('لدي حساب', 'I have an account'), style: const TextStyle(color: Colors.white))),
            ],
          ),
        )),
      ]),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark();
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(7)),
    alignment: Alignment.center,
    child: const Text('ي', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
  );
}
