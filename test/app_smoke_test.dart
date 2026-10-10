import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemeni_world/app.dart';

void main() {
  testWidgets('guest can enter the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YemeniWorldApp()));
    await tester.pump();
    expect(find.text('يمني حول العالم'), findsOneWidget);

    await tester.tap(find.text('ابدأ الاستكشاف'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ابحث عن خدمة، شخص أو منشأة'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsWidgets);
  });
}
