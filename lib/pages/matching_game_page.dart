// lib/pages/matching_game_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/data/database_helper.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import 'package:spider_words/widgets/matching_game_content.dart';
import 'package:spider_words/widgets/matching_game_logic.dart';

// تعريف Provider لقائمة الأسماء لجلبها بشكل غير متزامن
final nounsForGameProvider =
    FutureProvider.autoDispose<List<Noun>>((ref) async {
  final dbHelper = DatabaseHelper();
  return dbHelper.getNounsForMatchingGame();
});

// تعريف Provider لـ MatchingGameLogic. نستخدم ChangeNotifierProvider لأنه MatchingGameLogic يرث من ChangeNotifier
final matchingGameLogicProvider =
    ChangeNotifierProvider.autoDispose<MatchingGameLogic>((ref) {
  final nouns = ref.watch(nounsForGameProvider).maybeWhen(
        data: (data) => data,
        orElse: () => [],
      ) as List<Noun>;
  return MatchingGameLogic(initialNouns: nouns);
});

// تغيير StatelessWidget إلى ConsumerWidget لاستخدام Riverpod
class MatchingGamePage extends ConsumerWidget {
  static const routeName = '/matching_game';

  const MatchingGamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // قراءة حالة تحميل الأسماء
    final nounsState = ref.watch(nounsForGameProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Matching Game',
      ),
      body: CustomGradient(
        child: nounsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (nouns) {
            return MatchingGameContent(
              currentNoun: ref.watch(matchingGameLogicProvider).currentNoun,
              imageOptions: ref.watch(matchingGameLogicProvider).imageOptions,
              isCorrect: ref.watch(matchingGameLogicProvider).isCorrect,
              isWrong: ref.watch(matchingGameLogicProvider).isWrong,
              score: ref.watch(matchingGameLogicProvider).score,
              answeredQuestions:
                  ref.watch(matchingGameLogicProvider).answeredQuestions,
              totalQuestions:
                  ref.watch(matchingGameLogicProvider).totalQuestions,
              onOptionSelected: (noun) =>
                  ref.read(matchingGameLogicProvider).checkAnswer(noun),
              playCurrentNounAudio: () =>
                  ref.read(matchingGameLogicProvider).playCurrentNounAudio(),
              isInteractionDisabled:
                  ref.watch(matchingGameLogicProvider).isInteractionDisabled,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGameOverDialog(context, ref),
        tooltip: 'Show Game Over',
        child: const Icon(Icons.flag),
      ),
    );
  }

  // دالة عرض الـ Game Over Dialog. الآن تستقبل BuildContext و WidgetRef
  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    final gameLogic = ref.read(matchingGameLogicProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            'Your final score is: ${gameLogic.score} out of ${gameLogic.totalQuestions}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(matchingGameLogicProvider).resetGame();
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
