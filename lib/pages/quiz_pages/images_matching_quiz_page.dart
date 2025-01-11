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
final nounsForQuizProvider = FutureProvider.autoDispose
    .family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  if (category == 'all') {
    return dbHelper.getNounsForMatchingQuiz();
  } else {
    return dbHelper.getNounsByCategory(category);
  }
});

// تعريف Provider للفئة المختارة في لعبة المطابقة
final selectedQuizCategoryProvider = StateProvider<String>((ref) => 'all');

// تعريف Provider لـ MatchingGameLogic
final matchingQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<ImagesMatchingQuizLogic>((ref) {
  final selectedCategory = ref.watch(selectedQuizCategoryProvider);
  final nouns = ref.watch(nounsForQuizProvider(selectedCategory)).maybeWhen(
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
    final selectedCategory = ref.watch(selectedQuizCategoryProvider);
    final nounsState = ref.watch(nounsForQuizProvider(selectedCategory));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Images Matching Quiz',
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
              if (ref.read(matchingQuizLogicProvider).totalQuestions !=
                  nouns.length) {
                ref
                    .read(matchingQuizLogicProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return ImagesMatchingQuizContent(
              currentNoun: ref.watch(matchingQuizLogicProvider).currentNoun,
              answerOptions: ref.watch(matchingQuizLogicProvider).imageOptions,
              isCorrect: ref.watch(matchingQuizLogicProvider).isCorrect,
              isWrong: ref.watch(matchingQuizLogicProvider).isWrong,
              score: ref.watch(matchingQuizLogicProvider).score,
              answeredQuestions:
                  ref.watch(matchingQuizLogicProvider).answeredQuestions,
              totalQuestions:
                  ref.watch(matchingQuizLogicProvider).totalQuestions,
              onOptionSelected: (noun) =>
                  ref.read(matchingQuizLogicProvider).checkAnswer(noun),
              playCurrentNounAudio: () =>
                  ref.read(matchingQuizLogicProvider).playCurrentNounAudio(),
              isInteractionDisabled:
                  ref.watch(matchingQuizLogicProvider).isInteractionDisabled,
            );
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
              value: ref.watch(selectedQuizCategoryProvider),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                ref.read(selectedQuizCategoryProvider.notifier).state =
                    newValue!;
                ref
                    .read(matchingQuizLogicProvider)
                    .resetQuizForCategory(newValue);
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

  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(matchingQuizLogicProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            'Your final score is: ${quizLogic.score} out of ${quizLogic.totalQuestions}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final currentCategory = ref.read(selectedQuizCategoryProvider);
                ref
                    .read(matchingQuizLogicProvider)
                    .resetQuizForCategory(currentCategory);
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
