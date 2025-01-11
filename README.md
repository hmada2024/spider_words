# Spider Words - تطبيق بناء المفردات الإنجليزية التفاعلي

**Spider Words** هو تطبيق تفاعلي وجذاب مصمم لمساعدة المستخدمين على تعلم وممارسة الكلمات الإنجليزية من خلال تصنيفات متنوعة مثل الصفات والأسماء والكلمات المركبة. يقدم التطبيق تجربة تعليمية غنية تتضمن النطق الصوتي والصور والاختبارات التفاعلية لتعزيز التعلم.

## المميزات الرئيسية

1. **تعلم المفردات:**
    * **الصفات:** تعلم الصفات مع أمثلة، والمعاني العكسية، والنطق الصوتي.
    * **الأسماء:** استكشف الأسماء المصنفة حسب الموضوعات مثل الحيوانات والفواكه والخضروات والمزيد. كل اسم مصحوب بصورة ونطق صوتي.
    * **الكلمات المركبة:** افهم الكلمات المركبة مع أمثلة ونطق صوتي.

2. **الاختبارات التفاعلية:**
    * **اختبار مطابقة الصور:** طابق الصور مع الكلمة الصحيحة من بين قائمة الخيارات.
    * **اختبار مطابقة الأسماء:** طابق الأسماء مع الصور المقابلة لها.
    * **تتبع النتائج:** تتبع تقدمك من خلال عرض النتائج والأسئلة التي تمت الإجابة عليها.

3. **واجهة مستخدم سهلة الاستخدام:**
    * **الرسوم المتحركة:** رسوم متحركة سلسة لانتقالات البطاقات والتفاعلات.
    * **تصميم متجاوب:** تصميم يستجيب ويتكيف مع أحجام الشاشات المختلفة.
    * **تشغيل الصوت:** استمع إلى النطق الصحيح للكلمات والأمثلة.

4. **تعليم مخصص:**
    * **تحديد الفئات:** اختر فئات محددة (مثل الحيوانات والفواكه) أو استكشف جميع الفئات.
    * **تحديث البيانات:** قم بتحديث البيانات بسهولة للحصول على أحدث المحتوى.

## هيكل قاعدة البيانات

يستخدم التطبيق SQLite كقاعدة بيانات محلية. يتم تعبئة قاعدة البيانات مسبقًا بالبيانات المخزنة في مجلد `assets` ويتم نسخها إلى الجهاز عند التشغيل الأول. تحتوي قاعدة البيانات على الجداول التالية:

1. **جدول الأسماء (Nouns):**
    * يخزن الأسماء مع أسمائها وصورها والنطق الصوتي والفئات.
    * **الأعمدة:** `id`, `name`, `image`, `audio`, `category`.

2. **جدول الصفات (Adjectives):**
    * يخزن الصفات مع صيغها الرئيسية والعكسية والأمثلة والنطق الصوتي.
    * **الأعمدة:** `id`, `main_adjective`, `main_example`, `reverse_adjective`, `reverse_example`, `main_adjective_audio`, `reverse_adjective_audio`, `main_example_audio`, `reverse_example_audio`.

3. **جدول الكلمات المركبة (Compound Words):**
    * يخزن الكلمات المركبة مع أجزائها والأمثلة والنطق الصوتي.
    * **الأعمدة:** `id`, `main`, `part1`, `part2`, `example`, `main_audio`, `example_audio`.

4. **جدول الأصول الافتراضية (Default Assets):**
    * يخزن الأصول الافتراضية مثل الصور وملفات الصوت.
    * **الأعمدة:** `id`, `category`, `image`, `audio`.

## إدارة الحالة

يستخدم التطبيق `flutter_riverpod` لإدارة الحالة، مما يوفر طريقة بسيطة وفعالة لإدارة الحالة المشتركة عبر التطبيق. يتم استخدام الموفرات التالية:

* `FutureProvider`: لجلب البيانات بشكل غير متزامن من قاعدة البيانات.
* `ChangeNotifierProvider`: لإدارة حالة الاختبارات التفاعلية.
* `StateProvider`: لإدارة متغيرات الحالة البسيطة مثل الفئات المحددة.

## تنظيم الكود

يتم تنظيم الكود بشكل جيد في ملفات ومجلدات منفصلة، كل منها مسؤول عن وظيفة محددة:

* `data/`: يحتوي على مساعد قاعدة البيانات (`database_helper.dart`) لإدارة عمليات قاعدة البيانات.
* `models/`: يحتوي على نماذج البيانات مثل `Adjective` و `Noun` و `CompoundWord`.
* `pages/`: يحتوي على صفحات واجهة المستخدم للأقسام المختلفة من التطبيق (مثل `adjectives_page.dart` و `nouns_page.dart`).
* `widgets/`: يحتوي على مكونات واجهة المستخدم القابلة لإعادة الاستخدام مثل البطاقات والقوائم ومنطق الاختبار.
* `utils/`: يحتوي على فئات الأدوات المساعدة مثل `ScreenUtils` و `AppConstants`.
* `main.dart`: نقطة البداية الرئيسية للتطبيق.

## كيفية تشغيل التطبيق

1. **استنساخ المستودع:**
   ```bash
   git clone https://github.com/your-repo/spider_words.git
   cd spider_words

   
هيكل التطبيق (المخطط)
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
