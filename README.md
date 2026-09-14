# يمني حول العالم

تطبيق Flutter لمنصة اكتشاف الأشخاص والخدمات والمنشآت اليمنية حول العالم. التجربة Search First وتدعم العربية RTL والإنجليزية. يعمل التطبيق ببيانات Supabase الحية عند تمرير الإعدادات، ويرجع تلقائيًا إلى بيانات Mock للعرض المحلي من دون مفاتيح.

## ما يعمل في هذه النسخة

- Onboarding وتصفح كضيف وتسجيل تجريبي.
- الرئيسية والبحث النصي والمنظم والتصنيفات والنتائج.
- صفحات مقدم الخدمة والمنشأة والمفضلة والاتجاهات الخارجية.
- قريب مني بقائمة وخريطة داخلية لا تعرض Google Places.
- طلبات الخدمات، مقارنة العروض، تقديم عرض، والمحادثة الأساسية.
- عروض اليوم وبيانات السعودية ومصر وماليزيا والهند وأمريكا.
- مخطط Supabase/PostGIS وRLS والتوثيق والاستلام وسجل الإدارة.
- مستودع Supabase حي للبحث والتصنيفات والطلبات والعروض.
- تسجيل Phone OTP وEmail Magic Link وGoogle وApple عبر Supabase Auth.
- نشر طلبات الخدمة الحقيقية مع سياسات RLS.

## المتطلبات

- Flutter stable 3.24 أو أحدث.
- Android Studio/SDK لمحاكي Android.
- Xcode وCocoaPods لبناء iOS على macOS.
- Supabase CLI اختياري لتشغيل قاعدة البيانات محليًا.

## التشغيل لأول مرة

توليد ملفات Android وiOS القياسية مطلوب مرة واحدة لأن بيئة إنشاء هذه الحزمة لا تحتوي Flutter SDK:

```bash
chmod +x tool/*.sh
./tool/bootstrap_platforms.sh
flutter run
```

## المعاينة السريعة في المتصفح

المجلد `preview/` يحتوي نموذجًا تفاعليًا مؤقتًا لعرض تجربة التطبيق من دون Flutter. شغّله من جذر المشروع:

```bash
python -m http.server 4173
```

ثم افتح `http://localhost:4173/preview/`. هذه المعاينة ليست WebView أو نسخة الويب النهائية؛ تطبيق Flutter يظل المنتج الأساسي.

وللمعاينة دون خادم، افتح `preview/standalone.html` مباشرة بعد فك ضغط الحزمة.

البرنامج النصي يشغّل `flutter create` داخل المشروع من دون حذف `lib` أو `pubspec.yaml`، ثم يجلب الحزم ويشغّل التحليل والاختبارات. بعد توليد المنصات يمكن استخدام:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d android
```

لبناء iOS على macOS:

```bash
flutter run -d ios
```

## قاعدة البيانات

ملف الهجرة في `supabase/migrations/202609140001_initial_schema.sql` والبيانات التجريبية في `supabase/seed.sql`.

```bash
supabase start
supabase db reset
```

المخطط يفصل `accounts` و`profiles` و`businesses`، ويدعم عدة منشآت وفروع وملاك وموظفين للحساب الواحد. ويحتوي فهارس Full Text Search وPostGIS وGiST وسياسات RLS.

## ربط الخدمات الحية

1. استخدم أسماء الإعدادات في `.env.example` داخل نظام أسرار البيئة.
2. مرّر `SUPABASE_URL` و`SUPABASE_ANON_KEY` باستخدام `--dart-define`؛ يختار المزود الحي تلقائيًا.
3. طبّق ملفات `supabase/migrations/` ثم `supabase/seed.sql` على مشروع التطوير.
4. استبدل خريطة العرض بمحول Mapbox خلف واجهة مستقلة، مع إبقاء البيانات من قاعدة التطبيق فقط.
5. اربط FCM وسجل `device_tokens`، ثم أضف Sentry أو Crashlytics.

راجع [دليل الربط الحي](docs/live-setup.md) للأوامر وخطوات إعداد Auth وGitHub.

لا تضع `SUPABASE_SERVICE_ROLE_KEY` داخل تطبيق Flutter. عمليات الإدارة الحساسة تنفذ عبر Edge Functions أو خادم موثوق فقط.

## بنية المشروع

```text
lib/
  core/           theme, routing, shared UI
  data/           models, repository contract, mock implementation
  features/       screens grouped by product feature
supabase/
  migrations/     schema, indexes, functions and RLS
  seed.sql         global demo data
test/              repository and widget smoke tests
docs/              product scope and architecture decisions
```

## التحقق الحالي

يمكن تشغيل `./tool/structure_check.sh` في أي بيئة Unix لفحص الملفات والأسرار المكشوفة. تعذر تشغيل `flutter analyze` و`flutter test` في بيئة الإنشاء الحالية لعدم وجود Flutter/Dart ومنع تنزيل SDK؛ لذلك يجب تشغيل `./tool/bootstrap_platforms.sh` قبل اعتماد build نهائي.

## المرحلة التالية

توصيل مشروع Supabase الفعلي، ثم إضافة Mapbox ورفع الصور وFCM وبناء لوحة الإدارة المرئية فوق نفس المخطط. الدفع والاشتراكات والذكاء الاصطناعي والمتجر والوظائف تبقى خارج النسخة الأولى.
