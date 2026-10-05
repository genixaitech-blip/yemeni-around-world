import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemeni_world/data/mock_repository.dart';
import 'package:yemeni_world/data/providers.dart';
import 'package:yemeni_world/features/requests/request_detail_screen.dart';

class ControlledRepository extends MockAppRepository {
  final save = Completer<void>();
  @override
  Future<void> submitProposal(
          {required String requestId,
          required double price,
          required String description,
          required String deliveryTime}) =>
      save.future;
}

Future<void> openOfferForm(
    WidgetTester tester, ControlledRepository repository) async {
  await tester.pumpWidget(ProviderScope(overrides: [
    appRepositoryProvider.overrideWithValue(repository),
    signedInProvider.overrideWithValue(true),
  ], child: const MaterialApp(home: RequestDetailScreen(id: 'r1'))));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Submit offer'));
  await tester.tap(find.text('Submit offer'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), '100');
  await tester.enterText(
      find.byType(TextFormField).at(1), 'Real offer description');
  await tester.enterText(find.byType(TextFormField).at(2), 'Two days');
  await tester.ensureVisible(find.text('Send offer'));
  await tester.tap(find.text('Send offer'));
  await tester.pump();
}

void main() {
  test('demo preserves requests, submitted offers and conversation history',
      () async {
    final repository = MockAppRepository();
    final date = DateTime(2026, 11, 1);
    await repository.createRequest(
        title: 'New photography request',
        description: 'Details of the new request',
        country: 'السعودية',
        city: 'الرياض',
        category: 'تصوير',
        startsAt: date);
    final request = (await repository.getRequests()).first;
    expect((await repository.getRequest(request.id))!.startsAt, date);
    await repository.submitProposal(
        requestId: request.id,
        price: 123.45,
        description: 'Offer details',
        deliveryTime: 'Two days');
    final offer = (await repository.getProposals(request.id)).single;
    expect(offer.price, 123.45);
    final chatId = await repository.openProposalConversation(offer.id);
    await repository.sendMessage(chatId, 'Hello');
    expect((await repository.watchMessages(chatId).first).single.text, 'Hello');
    expect((await repository.getConversations()).single.id, chatId);
    await expectLater(
        repository.sendMessage('another-chat', 'Hello'), throwsArgumentError);
  });

  test(
      'nearby uses origin coordinates and excludes distant or unlocated listings',
      () async {
    final repository = MockAppRepository();
    final local = await repository.search(
        nearby: true, originLat: 24.7136, originLng: 46.6753);
    expect(local.map((item) => item.id), ['b1']);
    expect(local.single.distanceKm, closeTo(0, .001));
    expect(
        await repository.search(nearby: true, originLat: 40.7, originLng: -74),
        isEmpty);
  });

  testWidgets('offer success appears only after persistence succeeds',
      (tester) async {
    final repository = ControlledRepository();
    await openOfferForm(tester, repository);
    expect(find.text('Your offer was submitted'), findsNothing);
    repository.save.complete();
    await tester.pumpAndSettle();
    expect(find.text('Your offer was submitted'), findsOneWidget);
  });

  testWidgets('failed offer preserves form and does not claim success',
      (tester) async {
    final repository = ControlledRepository();
    await openOfferForm(tester, repository);
    repository.save.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Your offer was submitted'), findsNothing);
    expect(find.textContaining('Offer was not sent'), findsOneWidget);
    expect(find.text('Real offer description'), findsOneWidget);
  });
}
