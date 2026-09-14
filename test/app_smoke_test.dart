import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemeni_world/app.dart';

void main() {
  testWidgets('guest can enter the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YemeniWorldApp()));
    await tester.pumpAndSettle();
    expect(find.text('يمني\nحول العالم'), findsOneWidget);

    await tester.tap(find.text('ابدأ الاستكشاف'));
    await tester.pumpAndSettle();
    expect(find.text('ماذا تبحث عنه؟'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsWidgets);
  });
}
