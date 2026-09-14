import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final messages = <ChatMessage>[
    const ChatMessage(text: 'مرحبًا، شاهدت عرضك على طلب التصوير.', mine: true, time: '10:24'),
    const ChatMessage(text: 'أهلًا بك. نعم، أنا متاحة يوم الجمعة ويمكنني إرسال نماذج أعمال إضافية.', mine: false, time: '10:26'),
    const ChatMessage(text: 'ممتاز، هل العرض يشمل فيديو قصير للفعالية؟', mine: true, time: '10:28'),
  ];
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  void send() {
    if (controller.text.trim().isEmpty) return;
    setState(() { messages.add(ChatMessage(text: controller.text.trim(), mine: true, time: 'الآن')); controller.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Row(children: [CircleAvatar(radius: 18, backgroundColor: AppColors.mint, child: Text('أ')), SizedBox(width: 9), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أروى الحكيمي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), Text('متاحة الآن', style: TextStyle(fontSize: 11, color: AppColors.forest))])]),
        actions: [PopupMenuButton(itemBuilder: (_) => [PopupMenuItem(child: Text(t.text('إبلاغ', 'Report'))), PopupMenuItem(child: Text(t.text('حظر', 'Block')))])],
      ),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), color: AppColors.mint, child: Row(children: [const Icon(Icons.campaign_outlined, size: 18, color: AppColors.forest), const SizedBox(width: 8), Expanded(child: Text(t.text('طلب: أحتاج مصورًا في الرياض', 'Request: Event photographer in Riyadh'), style: const TextStyle(fontWeight: FontWeight.w700))), const Icon(Icons.chevron_right)])),
        Expanded(child: ListView.builder(reverse: true, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, reverseIndex) {
          final message = messages[messages.length - reverseIndex - 1];
          return Align(
            alignment: message.mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .76),
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 7),
              decoration: BoxDecoration(color: message.mine ? AppColors.forest : Colors.white, border: Border.all(color: message.mine ? AppColors.forest : AppColors.line), borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(message.text, style: TextStyle(color: message.mine ? Colors.white : AppColors.ink, height: 1.45)), const SizedBox(height: 3), Text(message.time, style: TextStyle(fontSize: 10, color: message.mine ? const Color(0xFFCFDED6) : AppColors.muted))]),
            ),
          );
        })),
        SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), color: Colors.white, child: Row(children: [
          IconButton(tooltip: t.text('إرفاق', 'Attach'), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('المرفقات تتفعل بعد ربط التخزين الآمن.', 'Attachments activate after secure storage is connected.')))), icon: const Icon(Icons.attach_file)),
          Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: t.text('اكتب رسالة...', 'Write a message...'), border: InputBorder.none, enabledBorder: InputBorder.none, filled: false), onSubmitted: (_) => send())),
          IconButton.filled(tooltip: t.text('إرسال', 'Send'), onPressed: send, icon: const Icon(Icons.send)),
        ]))),
      ]),
    );
  }
}
