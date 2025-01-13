// lib/pages/quiz_pages/images_matching_quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_logic.dart';
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';

// تعريف Provider للفئة المختارة في لعبة المطابقة
final selectedQuizCategoryProvider = StateProvider<String>((ref) => 'all');

// تعريف Provider لـ MatchingQuizLogic
final matchingQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<ImagesMatchingQuizLogic>((ref) {
  final selectedCategory = ref.watch(selectedQuizCategoryProvider);
  final nouns = ref
          .watch(nounsProvider)
          .value
          ?.where((noun) =>
              selectedCategory == 'all' || noun.category == selectedCategory)
          .toList() ??
      [];
  final audioPlayer = ref.read(audioPlayerProvider);
  return ImagesMatchingQuizLogic(initialNouns: nouns, audioPlayer: audioPlayer);
});

class ImagesMatchingQuizPage extends ConsumerWidget {
  static const routeName = '/images_matching_quiz';

  const ImagesMatchingQuizPage({super.key});

  String formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedQuizCategoryProvider);
    final nounsState = ref.watch(nounsProvider);

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
          data: (allNouns) {
            final nouns = allNouns
                .where((noun) =>
                    selectedCategory == 'all' ||
                    noun.category == selectedCategory)
                .toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final quizLogic = ref.read(matchingQuizLogicProvider);
              if (listEquals(quizLogic.initialNouns, nouns) == false) {
                ref.read(matchingQuizLogicProvider).initialNouns = nouns;
                ref
                    .read(matchingQuizLogicProvider)
                    .resetQuizForCategory(selectedCategory);
              }
              if (quizLogic.totalQuestions != nouns.length) {
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

    return Consumer(
      builder: (context, ref, _) {
        final nounsAsyncValue = ref.watch(nounsProvider);
        return nounsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Text('Error loading categories: $error'),
          data: (nouns) {
            final categories = [
              'all',
              ...nouns.map((noun) => noun.category).toSet()
            ];
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
                  if (newValue != null) {
                    ref.read(selectedQuizCategoryProvider.notifier).state =
                        newValue;
                    ref
                        .read(matchingQuizLogicProvider)
                        .resetQuizForCategory(newValue);
                  }
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'all'
                        ? 'All Categories'
                        : formatCategoryName(value)),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(matchingQuizLogicProvider);
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
