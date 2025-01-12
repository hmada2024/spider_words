// lib/pages/quiz_pages/adjective_opposite_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/adjective_opposite_quiz_content.dart';
import 'package:spider_words/widgets/quiz_widgets/adjective_opposite_quiz_logic.dart';

// Provider لجلب قائمة الصفات من قاعدة البيانات
final adjectivesForOppositeQuizProvider =
    FutureProvider.autoDispose<List<Adjective>>((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return dbHelper.getAdjectives();
});

// Provider لإنشاء وإدارة حالة اختبار متضادات الصفات
final adjectiveOppositeQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<AdjectiveOppositeQuizLogic>((ref) {
  // قراءة قائمة الصفات من البروفايدر الآخر
  final adjectives = ref.watch(adjectivesForOppositeQuizProvider).maybeWhen(
        data: (data) => data,
        orElse: () => [],
      ) as List<Adjective>;
  // قراءة مشغل الصوت
  final audioPlayer = ref.read(audioPlayerProvider);
  // إنشاء مدير حالة الاختبار وتمرير البيانات اللازمة
  return AdjectiveOppositeQuizLogic(
      initialAdjectives: adjectives, audioPlayer: audioPlayer);
});

class AdjectiveOppositeQuizPage extends ConsumerWidget {
  static const routeName = '/adjective_opposite_quiz';

  const AdjectiveOppositeQuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // قراءة حالة قائمة الصفات
    final adjectivesState = ref.watch(adjectivesForOppositeQuizProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Adjective Opposites Quiz'),
      // استخدام CustomGradient للخلفية
      body: CustomGradient(
        // التعامل مع حالات تحميل البيانات، الخطأ، والنجاح
        child: adjectivesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (adjectives) {
            // تحديث العدد الكلي للأسئلة بعد تحميل البيانات
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ref.read(adjectiveOppositeQuizLogicProvider).totalQuestions !=
                  adjectives.length) {
                ref
                    .read(adjectiveOppositeQuizLogicProvider)
                    .setTotalQuestions(adjectives.length);
              }
            });
            // عرض محتوى الاختبار
            return const AdjectiveOppositeQuizContent();
          },
        ),
      ),
      // زر لإنهاء الاختبار وعرض النتيجة
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuizOverDialog(context, ref),
        tooltip: 'Show Quiz Over',
        child: const Icon(Icons.flag),
      ),
    );
  }

  // دالة لعرض مربع حوار عند انتهاء الاختبار
  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(adjectiveOppositeQuizLogicProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Over!'),
          content: Text(
            'Your final score is: ${quizLogic.score} out of ${quizLogic.totalQuestions}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // إعادة تعيين الاختبار عند الضغط على "Play Again"
                ref.read(adjectiveOppositeQuizLogicProvider).resetQuiz();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // الرجوع إلى الصفحة السابقة
              },
              child: const Text('Back to Menu'),
            ),
          ],
        );
      },
    );
  }
}
