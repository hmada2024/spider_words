# تطبيق Spider Words

تطبيق **Spider Words** هو تطبيق تعليمي تفاعلي يساعد المستخدمين على تعلم الكلمات الإنجليزية من خلال تصنيفات مختلفة مثل الأسماء، الصفات، والكلمات المركبة. بالإضافة إلى ذلك، يحتوي التطبيق على لعبة مطابقة لتعزيز عملية التعلم بشكل ممتع وتفاعلي.

## المميزات

- **تصفح الأسماء:** عرض قائمة بالأسماء مع إمكانية التصفية حسب الفئة (مثل الحيوانات، الفواكه، الخضراوات، إلخ).
- **تصفح الصفات:** عرض قائمة بالصفات مع أمثلة توضيحية.
- **تصفح الكلمات المركبة:** عرض قائمة بالكلمات المركبة مع أمثلة.
- **لعبة المطابقة:** لعبة تفاعلية لمطابقة الصور مع الأسماء لتعزيز التعلم.

## التقنيات المستخدمة

- **Flutter:** إطار عمل لتطوير التطبيقات متعددة المنصات.
- **SQLite:** قاعدة بيانات محلية لتخزين البيانات.
- **Audioplayers:** لتشغيل الأصوات المرتبطة بالكلمات.

## كيفية التشغيل

1. قم بتنزيل المشروع.
2. افتح المشروع في Android Studio أو Visual Studio Code.
3. قم بتشغيل الأمر `flutter pub get` لتحميل التبعيات.
4. قم بتشغيل التطبيق على جهاز محاكي أو جهاز فعلي.

## هيكل المشروع

- **lib/main.dart:** نقطة الدخول الرئيسية للتطبيق.
- **lib/pages/:** يحتوي على صفحات التطبيق مثل الصفحة الرئيسية، صفحة الأسماء، صفحة الصفات، إلخ.
- **lib/widgets/:** يحتوي على واجهات المستخدم المخصصة مثل `CustomAppBar`، `CustomGradient`، إلخ.
- **lib/models/:** يحتوي على نماذج البيانات مثل `Noun`، `Adjective`، `CompoundWord`.
- **lib/data/:** يحتوي على `DatabaseHelper` لإدارة قاعدة البيانات.
- **lib/logic/:** يحتوي على منطق لعبة المطابقة.


## الرخصة

هذا المشروع مرخص تحت رخصة MIT. يمكنك استخدامه، تعديله، وإعادة توزيعه بحرية مع ذكر المصدر الأصلي.

## كيفية المساهمة

إذا كنت ترغب في إضافة تحسينات أو إصلاحات إلى المشروع الأصلي، يرجى اتباع الخطوات التالية:

1. قم بعمل Fork للمشروع.
2. أنشئ فرعًا جديدًا (`git checkout -b feature/YourFeatureName`).
3. قم بإجراء التغييرات المطلوبة.
4. تأكد من أن الكود يعمل بشكل صحيح.
5. قم بفتح طلب سحب (Pull Request) مع وصف للتغييرات التي أجريتها.

سنقوم بمراجعة طلب السحب ودمجه إذا كان مناسبًا.

lib/
├── data/
│   └── database_helper.dart
├── models/
│   ├── adjective_model.dart
│   ├── compound_word_model.dart
│   └── nouns_model.dart
├── pages/
│   ├── common_pages/
│   │   └── home_page.dart
│   ├── vocabulary_pages/
│   │   ├── adjectives_page.dart
│   │   ├── compound_words_page.dart
│   │   └── nouns_page.dart
│   └── quiz_pages/
│       ├── images_matching_quiz_page.dart
│       └── nouns_matching_quiz_page.dart
├── utils/
│   ├── app_constants.dart
│   ├── constants.dart
│   └── screen_utils.dart
├── widgets/
│   ├── common_widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_gradient.dart
│   │   └── custom_home_button.dart
│   ├── quiz_widgets/
│   │   ├── images_matching_quiz_content.dart
│   │   ├── images_matching_quiz_logic.dart
│   │   ├── nouns_matching_quiz_content.dart
│   │   └── nouns_matching_quiz_logic.dart
│   └── vocabulary_widgets/
│       ├── adjective_card.dart
│       ├── adjective_list.dart
│       ├── compound_word_card.dart
│       ├── noun_item.dart
│       └── noun_list.dart
└── main.dart