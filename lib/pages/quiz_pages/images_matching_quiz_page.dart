// lib/pages/quiz_pages/images_matching_quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_logic.dart';

// تعريف Provider لقائمة الأسماء لجلبها بشكل غير متزامن
final nounsForGameProvider = FutureProvider.autoDispose
    .family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  if (category == 'all') {
    return dbHelper.getNounsForMatchingQuiz();
  } else {
    return dbHelper.getNounsByCategory(category);
  }
});

// تعريف Provider للفئة المختارة في لعبة المطابقة
final selectedGameCategoryProvider = StateProvider<String>((ref) => 'all');

// تعريف Provider لـ MatchingGameLogic
final matchingGameLogicProvider =
    ChangeNotifierProvider.autoDispose<ImagesMatchingQuizLogic>((ref) {
  final selectedCategory = ref.watch(selectedGameCategoryProvider);
  final nouns = ref.watch(nounsForGameProvider(selectedCategory)).maybeWhen(
        data: (data) => data,
        orElse: () => [],
      ) as List<Noun>;
  final audioPlayer = ref.read(audioPlayerProvider);
  return ImagesMatchingQuizLogic(initialNouns: nouns, audioPlayer: audioPlayer);
});

class ImagesMatchingQuizPage extends ConsumerWidget {
  static const routeName = '/matching_game';

  const ImagesMatchingQuizPage({super.key});

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedGameCategoryProvider);
    final nounsState = ref.watch(nounsForGameProvider(selectedCategory));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Matching Game',
        actions: [
          _buildCategoryDropdown(ref, context),
        ],
      ),
      body: CustomGradient(
        child: nounsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (nouns) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ref.read(matchingGameLogicProvider).totalQuestions !=
                  nouns.length) {
                ref
                    .read(matchingGameLogicProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return ImagesMatchingQuizContent(
              currentNoun: ref.watch(matchingGameLogicProvider).currentNoun,
              answerOptions: ref.watch(matchingGameLogicProvider).imageOptions,
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

  Widget _buildCategoryDropdown(WidgetRef ref, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownIconSize = max(18.0, min(screenWidth * 0.05, 24.0));

    return FutureBuilder<List<String>>(
      future: ref
          .read(databaseHelperProvider)
          .getNouns()
          .then((nouns) => nouns.map((noun) => noun.category).toSet().toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading categories: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No categories available.');
        } else {
          final categories = ['all', ...snapshot.data!];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: ref.watch(selectedGameCategoryProvider),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                ref.read(selectedGameCategoryProvider.notifier).state =
                    newValue!;
                ref
                    .read(matchingGameLogicProvider)
                    .resetGameForCategory(newValue);
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'all'
                      ? 'All Categories'
                      : _formatCategoryName(value)),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

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
                final currentCategory = ref.read(selectedGameCategoryProvider);
                ref
                    .read(matchingGameLogicProvider)
                    .resetGameForCategory(currentCategory);
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
