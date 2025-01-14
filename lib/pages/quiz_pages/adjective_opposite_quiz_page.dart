// lib/pages/quiz_pages/adjective_opposite_quiz_page.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/adjective_opposite_quiz_content.dart';
import 'package:spider_words/widgets/quiz_widgets/adjective_opposite_quiz_logic.dart';
import 'package:spider_words/providers/adjective_provider.dart';

// Provider لإنشاء وإدارة حالة اختبار متضادات الصفات
final adjectiveOppositeQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<AdjectiveOppositeQuizLogic>((ref) {
  final adjectives = ref.watch(adjectivesProvider).value ?? [];
  final audioPlayer = ref.read(audioPlayerProvider);
  return AdjectiveOppositeQuizLogic(
      initialAdjectives: adjectives, audioPlayer: audioPlayer);
});

class AdjectiveOppositeQuizPage extends ConsumerStatefulWidget {
  static const routeName = '/adjective_opposite_quiz';

  const AdjectiveOppositeQuizPage({super.key});

  @override
  AdjectiveOppositeQuizPageState createState() =>
      AdjectiveOppositeQuizPageState();
}

class AdjectiveOppositeQuizPageState
    extends ConsumerState<AdjectiveOppositeQuizPage> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = ref.read(audioPlayerProvider); // استخدام AudioPlayer المشترك
  }

  @override
  void dispose() {
    audioPlayer.stop(); // إيقاف الصوت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adjectivesState = ref.watch(adjectivesProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Adjective Opposites Quiz'),
      body: CustomGradient(
        child: adjectivesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (adjectives) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final quizLogic = ref.read(adjectiveOppositeQuizLogicProvider);
              if (listEquals(quizLogic.initialAdjectives, adjectives) ==
                  false) {
                ref.read(adjectiveOppositeQuizLogicProvider).initialAdjectives =
                    adjectives;
                ref
                    .read(adjectiveOppositeQuizLogicProvider)
                    .resetQuizForCategory('all');
              }
              if (quizLogic.totalQuestions != adjectives.length) {
                ref
                    .read(adjectiveOppositeQuizLogicProvider)
                    .setTotalQuestions(adjectives.length);
              }
            });
            return const AdjectiveOppositeQuizContent();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuizOverDialog(context, ref),
        tooltip: 'Show Quiz Over',
        child: const Icon(Icons.flag),
      ),
    );
  }

  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(adjectiveOppositeQuizLogicProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Over!'),
          content: Text(
              'Your final score is: ${quizLogic.score} out of ${quizLogic.totalQuestions}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(adjectiveOppositeQuizLogicProvider).resetQuiz();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
          ],
        );
      },
    );
  }
}
