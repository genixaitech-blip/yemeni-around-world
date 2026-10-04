import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF061C2C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _HeroGradient(),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _WorldPainter(progress: _controller.value),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const _BrandMark(),
                      const Spacer(),
                      _LanguageSwitch(
                        locale: locale,
                        onChanged: (value) {
                          ref.read(localeProvider.notifier).state = Locale(value);
                        },
                      ),
                    ],
                  ),
                  const Spacer(flex: 5),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          t.text('يمني حول العالم', 'Yemeni Around the World'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 66,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC9A063), Color(0xFFF2D29A)],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          t.text('من اليمن إلى كل العالم', 'From Yemen to the whole world'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD8E3E9),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          t.text(
                            'مجتمع واحد، خدمات أقرب، وهوية تجمعنا أينما كنا.',
                            'One community. Closer services. A shared identity wherever we are.',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9FB2BE),
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: .12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public_rounded, color: Color(0xFFE3C088), size: 25),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.text(
                              'أشخاص، منشآت، خدمات وفرص يمنية حول العالم',
                              'People, businesses, services and opportunities worldwide',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A063),
                        foregroundColor: const Color(0xFF061C2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => context.go('/home'),
                      child: Text(
                        t.text('ابدأ الاستكشاف', 'Start exploring'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/auth'),
                    child: Text(
                      t.text('تسجيل الدخول', 'Sign in'),
                      style: const TextStyle(
                        color: Color(0xFFD8E3E9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, .35),
          radius: 1.1,
          colors: [
            Color(0xFF0D4563),
            Color(0xFF082B41),
            Color(0xFF061C2C),
            Color(0xFF04131E),
          ],
          stops: [0, .36, .7, 1],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
      ),
      child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({required this.locale, required this.onChanged});

  final String locale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangButton(label: 'عربي', selected: locale == 'ar', onTap: () => onChanged('ar')),
          _LangButton(label: 'EN', selected: locale == 'en', onTap: () => onChanged('en')),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: .13) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF9FB2BE),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _WorldPainter extends CustomPainter {
  _WorldPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .51);
    final radius = math.min(size.width * .52, size.height * .29);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2AA1D2).withValues(alpha: .18),
          const Color(0xFF2AA1D2).withValues(alpha: .04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    canvas.drawCircle(center, radius * 1.5, glow);

    final line = Paint()
      ..color = const Color(0xFF72B8D2).withValues(alpha: .17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, line);
    for (final scale in [.42, .72]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2 * scale, height: radius * 2),
        line,
      );
    }
    for (final factor in [-.55, 0.0, .55]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * factor),
          width: radius * 1.9,
          height: radius * .52,
        ),
        line,
      );
    }

    final points = <Offset>[
      Offset(center.dx - radius * .56, center.dy - radius * .18),
      Offset(center.dx - radius * .12, center.dy + radius * .34),
      Offset(center.dx + radius * .18, center.dy - radius * .42),
      Offset(center.dx + radius * .57, center.dy + radius * .02),
      Offset(center.dx + radius * .33, center.dy + radius * .53),
      Offset(center.dx - radius * .42, center.dy + radius * .48),
    ];

    final routePaint = Paint()
      ..color = const Color(0xFFC9A063).withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final yemen = points[1];
    for (var i = 0; i < points.length; i++) {
      if (i == 1) continue;
      final target = points[i];
      final path = Path()..moveTo(yemen.dx, yemen.dy);
      final control = Offset(
        (yemen.dx + target.dx) / 2,
        math.min(yemen.dy, target.dy) - radius * (.22 + .05 * i),
      );
      path.quadraticBezierTo(control.dx, control.dy, target.dx, target.dy);
      canvas.drawPath(path, routePaint);
    }

    for (var i = 0; i < points.length; i++) {
      final pulse = .7 + .3 * math.sin((progress * math.pi * 2) + i);
      final color = i == 1 ? const Color(0xFFE3C088) : const Color(0xFF7FD3F2);
      canvas.drawCircle(
        points[i],
        8 + 3 * pulse,
        Paint()..color = color.withValues(alpha: .08 + .09 * pulse),
      );
      canvas.drawCircle(
        points[i],
        i == 1 ? 3.8 : 2.7,
        Paint()..color = color.withValues(alpha: .68 + .25 * pulse),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
