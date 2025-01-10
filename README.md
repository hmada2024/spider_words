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

## المساهمة

إذا كنت ترغب في المساهمة في تطوير التطبيق، يرجى فتح طلب سحب (Pull Request) وسنقوم بمراجعته.

## الرخصة

هذا المشروع مرخص تحت رخصة MIT.

lib/
├── main.dart
├── models/
│   ├── nouns_model.dart
│   ├── adjective_model.dart
│   └── compound_word_model.dart
├── data/
│   └── database_helper.dart
├── widgets/
│   ├── custom_app_bar.dart
│   ├── custom_gradient.dart
│   ├── custom_home_button.dart
│   ├── noun_item.dart
│   ├── adjective_card.dart
│   ├── compound_word_card.dart
│   ├── matching_game_content.dart
│   └── matching_game_logic.dart
├── pages/
│   ├── home_page.dart
│   ├── nouns_page.dart
│   ├── adjectives_page.dart
│   ├── compound_words_page.dart
│   └── matching_game_page.dart
├── utils/
│   ├── app_constants.dart
│   ├── constants.dart
│   └── screen_utils.dart
assets/
├── nouns.db
├── sounds/
│   ├── correct.mp3
│   └── wrong.mp3
└── icon.ico