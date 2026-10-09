import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/locale_controller.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
        appBar: AppBar(title: Text(t.text('تفاصيل الطلب', 'Request details'))),
        body: ref.watch(requestDetailProvider(id)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                  child: TextButton(
                      onPressed: () =>
                          ref.invalidate(requestDetailProvider(id)),
                      child: Text(t.text('تعذر التحميل. أعد المحاولة',
                          'Could not load. Retry')))),
              data: (request) {
                if (request == null) {
                  return Center(
                      child:
                          Text(t.text('الطلب غير موجود', 'Request not found')));
                }
                final own = request.requesterId != null &&
                    request.requesterId ==
                        ref.watch(supabaseClientProvider)?.auth.currentUser?.id;
                return ListView(padding: const EdgeInsets.all(20), children: [
                  Text(request.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                      '${request.place.city}، ${request.place.country} • ${request.createdAgo}'),
                  const SizedBox(height: 20),
                  Text(request.description),
                  if (request.budget != null)
                    Text(
                        '${t.text('الميزانية', 'Budget')}: ${request.budget} ${request.currency}'),
                  const SizedBox(height: 12),
                  Text(
                      '${t.text('الموعد', 'Schedule')}: ${request.startsAt == null ? t.text('مرن، يتم الاتفاق لاحقًا', 'Flexible, to be agreed later') : MaterialLocalizations.of(context).formatMediumDate(request.startsAt!)}'),
                  const SizedBox(height: 24),
                  Text(t.text('العروض المتاحة لك', 'Offers visible to you'),
                      style: Theme.of(context).textTheme.titleLarge),
                  ref.watch(proposalsProvider(id)).when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => TextButton(
                            onPressed: () =>
                                ref.invalidate(proposalsProvider(id)),
                            child: Text(t.text(
                                'تعذر تحميل العروض. أعد المحاولة',
                                'Could not load offers. Retry'))),
                        data: (items) => Column(children: [
                          if (items.isEmpty)
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(t.text(
                                    'لا توجد عروض متاحة لك بعد. تفاصيل العروض خاصة بصاحب الطلب ومقدم العرض.',
                                    'No offers visible yet. Offer details are private to the requester and provider.'))),
                          for (final item in items)
                            _ProposalCard(proposal: item),
                        ]),
                      ),
                  const SizedBox(height: 16),
                  if (!own)
                    FilledButton.icon(
                        icon: const Icon(Icons.send_outlined),
                        label: Text(t.text('تقديم عرض', 'Submit offer')),
                        onPressed: () async {
                          if (!ref.read(signedInProvider)) {
                            context.push('/auth');
                            return;
                          }
                          final sent = await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (_) => _OfferSheet(
                                  requestId: id, currency: request.currency));
                          if (sent == true && context.mounted) {
                            ref.invalidate(proposalsProvider(id));
                            ref.invalidate(requestDetailProvider(id));
                            ref.invalidate(requestsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(t.text('تم إرسال عرضك',
                                    'Your offer was submitted'))));
                          }
                        }),
                ]);
              },
            ));
  }
}

class _ProposalCard extends ConsumerStatefulWidget {
  const _ProposalCard({required this.proposal});
  final RequestProposal proposal;
  @override
  ConsumerState<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<_ProposalCard> {
  bool opening = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final t = T(context);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.providerName,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${p.price.toStringAsFixed(2)} ${p.currency}'),
              Text(p.description),
              if (p.deliveryTime.isNotEmpty) Text(p.deliveryTime),
              TextButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(t.text('مراسلة', 'Message')),
                  onPressed: opening
                      ? null
                      : () async {
                          setState(() => opening = true);
                          try {
                            final chatId = await ref
                                .read(appRepositoryProvider)
                                .openProposalConversation(p.id);
                            ref.invalidate(conversationsProvider);
                            if (context.mounted) context.push('/chat/$chatId');
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(t.text(
                                      'تعذر فتح المحادثة. أعد المحاولة.',
                                      'Could not open conversation. Retry.'))));
                            }
                          } finally {
                            if (mounted) setState(() => opening = false);
                          }
                        }),
            ])));
  }
}

class _OfferSheet extends ConsumerStatefulWidget {
  const _OfferSheet({required this.requestId, required this.currency});
  final String requestId;
  final String currency;
  @override
  ConsumerState<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends ConsumerState<_OfferSheet> {
  final formKey = GlobalKey<FormState>();
  final price = TextEditingController();
  final description = TextEditingController();
  final delivery = TextEditingController();
  bool sending = false;
  String? error;
  @override
  void dispose() {
    price.dispose();
    description.dispose();
    delivery.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await ref.read(appRepositoryProvider).submitProposal(
          requestId: widget.requestId,
          price: double.parse(price.text.trim()),
          description: description.text,
          deliveryTime: delivery.text);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => error = T(context).text(
            'لم يُرسل العرض. تحقق من اتصالك ومن أن الطلب مفتوح ولم تقدم عرضًا سابقًا.',
            'Offer was not sent. Check your connection, request status and whether you already submitted an offer.'));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return PopScope(
        canPop: !sending,
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
            child: SingleChildScrollView(
                child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(t.text('قدّم عرضك', 'Submit your offer'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 14),
                          TextFormField(
                              controller: price,
                              enabled: !sending,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                  labelText: t.text('السعر', 'Price'),
                                  suffixText: widget.currency),
                              validator: (value) {
                                final number =
                                    double.tryParse(value?.trim() ?? '');
                                return number == null ||
                                        !number.isFinite ||
                                        number < 0 ||
                                        number > 9999999999.99
                                    ? t.text('أدخل سعرًا صحيحًا',
                                        'Enter a valid price')
                                    : null;
                              }),
                          const SizedBox(height: 10),
                          TextFormField(
                              controller: description,
                              enabled: !sending,
                              minLines: 3,
                              maxLines: 4,
                              maxLength: 2000,
                              decoration: InputDecoration(
                                  labelText:
                                      t.text('وصف العرض', 'Offer details')),
                              validator: (value) =>
                                  (value?.trim().length ?? 0) < 5
                                      ? t.text('أضف تفاصيل العرض',
                                          'Add offer details')
                                      : null),
                          TextFormField(
                              controller: delivery,
                              enabled: !sending,
                              maxLength: 200,
                              decoration: InputDecoration(
                                  labelText:
                                      t.text('مدة التنفيذ', 'Delivery time')),
                              validator: (value) => value == null ||
                                      value.trim().isEmpty
                                  ? t.text(
                                      'حدد مدة التنفيذ', 'Enter delivery time')
                                  : null),
                          if (error != null)
                            Text(error!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                          const SizedBox(height: 16),
                          FilledButton(
                              onPressed: sending ? null : submit,
                              child: sending
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Text(t.text('إرسال العرض', 'Send offer'))),
                        ])))));
  }
}
