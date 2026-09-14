# إعداد Supabase وGitHub

## 1. تطبيق مخطط قاعدة البيانات

ثبّت Supabase CLI وسجّل الدخول، ثم اربط المشروع وشغّل الهجرات والبذور:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase db reset --linked
```

الأمر الأخير يعيد إنشاء قاعدة البيانات المرتبطة وقد يحذف بياناتها الحالية. استخدمه فقط على مشروع تطوير فارغ. على مشروع يحتوي بيانات استخدم `supabase db push` فقط، ثم أضف البيانات المناسبة يدويًا.

## 2. إعداد المصادقة

من لوحة Supabase:

1. فعّل Phone OTP أو Email OTP حسب المطلوب.
2. فعّل Google وApple بعد إضافة بيانات كل مزود.
3. أضف `io.supabase.yemeniworld://login-callback/` إلى قائمة Redirect URLs.
4. لا تستخدم مفتاح `service_role` داخل التطبيق أو GitHub.

## 3. تشغيل التطبيق بقاعدة البيانات الحية

القيم تمرر إلى Flutter وقت التشغيل ولا تحفظ في المستودع:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_KEY \
  --dart-define=AUTH_REDIRECT_URL=io.supabase.yemeniworld://login-callback/
```

إذا لم تمرر قيم Supabase، يستخدم التطبيق `MockAppRepository` تلقائيًا ليظل العرض التجريبي قابلًا للتشغيل.

## 4. GitHub

أضف القيم العامة إلى GitHub Actions Secrets أو إلى إعداد بيئة البناء، ولا تضف ملف `.env` إلى Git. سير العمل الحالي يشغل `flutter analyze` و`flutter test` على كل Pull Request وكل دفع إلى `main` أو `develop`.
