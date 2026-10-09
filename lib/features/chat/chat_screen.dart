import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/providers.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = T(context);
    return Scaffold(
        appBar: AppBar(title: Text(t.text('المحادثات', 'Messages'))),
        body: !ref.watch(signedInProvider)
            ? Center(
                child: TextButton(
                    onPressed: () => context.push('/auth'),
                    child: Text(t.text('تسجيل الدخول', 'Sign in'))))
            : ref.watch(conversationsProvider).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                      child: TextButton(
                          onPressed: () =>
                              ref.invalidate(conversationsProvider),
                          child: Text(t.text('تعذر التحميل. أعد المحاولة',
                              'Could not load. Retry')))),
                  data: (chats) => chats.isEmpty
                      ? Center(
                          child: Text(t.text(
                              'لا توجد محادثات بعد. ابدأ المراسلة من صفحة مقدم الخدمة أو العرض.',
                              'No conversations yet. Start from a listing or offer.')))
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(conversationsProvider);
                            await ref.read(conversationsProvider.future);
                          },
                          child: ListView(children: [
                            for (final chat in chats)
                              ListTile(
                                  title: Text(chat.title),
                                  leading:
                                      const Icon(Icons.chat_bubble_outline),
                                  onTap: () => context.push('/chat/${chat.id}'))
                          ])),
                ));
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversationId, super.key});
  final String conversationId;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final controller = TextEditingController();
  bool sending = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (sending || text.isEmpty || text.length > 4000) return;
    setState(() => sending = true);
    try {
      await ref
          .read(appRepositoryProvider)
          .sendMessage(widget.conversationId, text);
      if (!mounted) return;
      controller.clear();
      ref.invalidate(conversationsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(T(context).text(
                'لم تُرسل الرسالة. احتفظنا بالنص لتعيد المحاولة.',
                'Message was not sent. Your text is kept for retry.'))));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    final chats = ref.watch(conversationsProvider).valueOrNull ?? [];
    final title = chats
            .where((item) => item.id == widget.conversationId)
            .firstOrNull
            ?.title ??
        t.text('محادثة', 'Conversation');
    if (!ref.watch(signedInProvider)) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(
              child: TextButton(
                  onPressed: () => context.push('/auth'),
                  child: Text(t.text(
                      'سجّل لقراءة الرسائل', 'Sign in to read messages')))));
    }
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(children: [
          if (ref.watch(supabaseClientProvider) == null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(t.text('محادثة تجريبية على هذا الجهاز فقط',
                    'Demo conversation on this device only'))),
          Expanded(
              child: ref.watch(messagesProvider(widget.conversationId)).when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(
                        child: TextButton(
                            onPressed: () => ref.invalidate(
                                messagesProvider(widget.conversationId)),
                            child: Text(t.text(
                                'تعذر تحميل الرسائل. أعد المحاولة',
                                'Could not load messages. Retry')))),
                    data: (messages) => messages.isEmpty
                        ? Center(
                            child: Text(t.text('ابدأ المحادثة برسالتك الأولى',
                                'Send the first message')))
                        : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (_, reverseIndex) {
                              final message =
                                  messages[messages.length - reverseIndex - 1];
                              return Align(
                                  alignment: message.mine
                                      ? AlignmentDirectional.centerEnd
                                      : AlignmentDirectional.centerStart,
                                  child: Container(
                                      key: ValueKey(message.id),
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.sizeOf(context).width *
                                                  .76),
                                      margin: const EdgeInsets.only(bottom: 9),
                                      padding: const EdgeInsets.fromLTRB(
                                          13, 9, 13, 7),
                                      decoration: BoxDecoration(
                                          color: message.mine
                                              ? AppColors.forest
                                              : Colors.white,
                                          border: Border.all(
                                              color: message.mine
                                                  ? AppColors.forest
                                                  : AppColors.line),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(message.text,
                                                style: TextStyle(
                                                    color: message.mine
                                                        ? Colors.white
                                                        : AppColors.ink,
                                                    height: 1.45)),
                                            const SizedBox(height: 3),
                                            Text(message.time,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: message.mine
                                                        ? const Color(
                                                            0xFFCFDED6)
                                                        : AppColors.muted)),
                                          ])));
                            }),
                  )),
          SafeArea(
              top: false,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                            controller: controller,
                            enabled: !sending,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 4000,
                            decoration: InputDecoration(
                                hintText: t.text(
                                    'اكتب رسالة...', 'Write a message...'),
                                counterText: ''),
                            onSubmitted: (_) => send())),
                    IconButton.filled(
                        tooltip: t.text('إرسال', 'Send'),
                        onPressed: sending ? null : send,
                        icon: sending
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send)),
                  ]))),
        ]));
  }
}
