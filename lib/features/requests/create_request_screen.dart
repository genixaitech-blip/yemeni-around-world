import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/locale_controller.dart';
import '../../data/providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});
  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final budget = TextEditingController();
  String country = 'السعودية';
  String city = 'الرياض';
  String category = 'تصوير';
  DateTime? selectedDate;
  bool submitting = false;

  static const citiesByCountry = <String, List<String>>{
    'السعودية': ['الرياض', 'جدة'],
    'مصر': ['القاهرة'],
    'ماليزيا': ['كوالالمبور'],
    'الهند': ['نيودلهي'],
    'أمريكا': ['نيويورك'],
  };

  @override
  void dispose() { title.dispose(); description.dispose(); budget.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = T(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.text('نشر طلب خدمة', 'Post a service request'))),
      body: Form(
        key: formKey,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.campaign_outlined, color: AppColors.forest), const SizedBox(width: 10), Expanded(child: Text(t.text('سيصل طلبك فقط إلى مقدمي الخدمة المناسبين.', 'Your request will reach relevant providers only.'), style: const TextStyle(fontWeight: FontWeight.w700)))])),
          const SizedBox(height: 20),
          TextFormField(controller: title, decoration: InputDecoration(labelText: t.text('عنوان الطلب', 'Request title'), hintText: t.text('مثال: أحتاج مصورًا في الرياض', 'Example: Event photographer in Riyadh')), validator: (value) => value == null || value.trim().length < 5 ? t.text('اكتب عنوانًا واضحًا', 'Enter a clear title') : null),
          const SizedBox(height: 12),
          TextFormField(controller: description, minLines: 4, maxLines: 6, decoration: InputDecoration(labelText: t.text('التفاصيل', 'Details'), hintText: t.text('اشرح الوقت والمتطلبات المهمة', 'Describe timing and key requirements')), validator: (value) => value == null || value.trim().length < 10 ? t.text('أضف تفاصيل كافية', 'Add enough detail') : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _SelectField(label: t.text('الدولة', 'Country'), value: country, values: const ['السعودية', 'مصر', 'ماليزيا', 'الهند', 'أمريكا'], onChanged: (value) => setState(() { country = value!; city = citiesByCountry[country]!.first; }))),
            const SizedBox(width: 10),
            Expanded(child: _SelectField(label: t.text('المدينة', 'City'), value: city, values: citiesByCountry[country]!, onChanged: (value) => setState(() => city = value!))),
          ]),
          const SizedBox(height: 12),
          _SelectField(label: t.text('التصنيف', 'Category'), value: category, values: const ['تصوير', 'ترجمة', 'نقل وسائقون', 'سكن', 'شحن'], onChanged: (value) => setState(() => category = value!)),
          const SizedBox(height: 12),
          TextFormField(controller: budget, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t.text('الميزانية (اختياري)', 'Budget (optional)'), suffixText: 'USD')),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: Text(t.text('التاريخ والوقت', 'Date and time')), subtitle: Text(selectedDate == null ? t.text('مرن، يتم الاتفاق لاحقًا', 'Flexible, to be agreed later') : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'), trailing: const Icon(Icons.chevron_right), onTap: () async {
            final value = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (value != null) setState(() => selectedDate = value);
          }),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.attach_file), title: Text(t.text('إضافة صور أو مرفقات', 'Add photos or attachments')), trailing: const Icon(Icons.add), onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('رفع الملفات يتفعل بعد ربط التخزين الآمن.', 'Attachments activate after secure storage is connected.'))))),
          const SizedBox(height: 18),
          FilledButton(onPressed: submitting ? null : _publish, child: submitting ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(t.text('نشر الطلب', 'Publish request'))),
        ]),
      ),
    );
  }

  Future<void> _publish() async {
    final t = T(context);
    if (!formKey.currentState!.validate()) return;
    if (!ref.read(signedInProvider)) { context.push('/auth'); return; }
    setState(() => submitting = true);
    try {
      await ref.read(appRepositoryProvider).createRequest(
        title: title.text,
        description: description.text,
        country: country,
        city: city,
        category: category,
        budget: int.tryParse(budget.text.trim()),
        startsAt: selectedDate,
      );
      ref.invalidate(requestsProvider);
      if (!mounted) return;
      showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
              icon: const Icon(Icons.check_circle, color: AppColors.forest, size: 42),
              title: Text(t.text('تم نشر طلبك', 'Request published')),
              content: Text(t.text('سنخبرك عند وصول عروض جديدة.', 'We will notify you when new offers arrive.')),
              actions: [FilledButton(onPressed: () { Navigator.pop(dialogContext); context.go('/requests'); }, child: Text(t.text('عرض الطلبات', 'View requests')))],
            ));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.text('تعذر نشر الطلب: $error', 'Could not publish request: $error'))));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({required this.label, required this.value, required this.values, required this.onChanged});
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label), items: values.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged);
}
