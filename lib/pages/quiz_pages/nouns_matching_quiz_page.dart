// lib/pages/quiz_pages/nouns_matching_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_logic.dart';
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart'; // استيراد الودجت

final selectedAudioImageQuizCategoryProvider =
    StateProvider<String>((ref) => 'all');

final audioImageMatchingQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<NounsMatchingQuizLogic>((ref) {
  final selectedCategory = ref.watch(selectedAudioImageQuizCategoryProvider);
  final nouns = ref
          .watch(nounsProvider)
          .value
          ?.where((noun) =>
              selectedCategory == 'all' || noun.category == selectedCategory)
          .toList() ??
      [];
  final audioPlayer = ref.read(audioPlayerProvider);
  return NounsMatchingQuizLogic(initialNouns: nouns, audioPlayer: audioPlayer);
});

class NounsMatchingQuizPage extends ConsumerWidget {
  static const routeName = '/nouns_matching_quiz';

  const NounsMatchingQuizPage({super.key});

  String formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedAudioImageQuizCategoryProvider);
    final nounsState = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns Matching Quiz',
        actions: [
          // استبدال DropdownButton بـ CategoryFilterDropdown
          Consumer(
            builder: (context, ref, _) {
              final nounsAsyncValue = ref.watch(nounsProvider);
              return nounsAsyncValue.when(
                loading: () =>
                    const SizedBox.shrink(), // لا نعرض شيء أثناء التحميل هنا
                error: (error, stackTrace) =>
                    Text('Error loading categories: $error'),
                data: (nouns) {
                  final categories = [
                    'all',
                    ...nouns.map((noun) => noun.category).toSet()
                  ];
                  return CategoryFilterDropdown(
                    categories: categories,
                    selectedCategory:
                        ref.watch(selectedAudioImageQuizCategoryProvider),
                    onCategoryChanged: (newValue) {
                      if (newValue != null) {
                        ref
                            .read(
                                selectedAudioImageQuizCategoryProvider.notifier)
                            .state = newValue;
                        ref
                            .read(audioImageMatchingQuizLogicProvider)
                            .resetQuizForCategory(newValue);
                      }
                    },
                  );
                },
              );
            },
          ),
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
              final quizLogic = ref.read(audioImageMatchingQuizLogicProvider);
              if (listEquals(quizLogic.initialNouns, nouns) == false) {
                ref.read(audioImageMatchingQuizLogicProvider).initialNouns =
                    nouns;
                ref
                    .read(audioImageMatchingQuizLogicProvider)
                    .resetQuizForCategory(selectedCategory);
              }
              if (quizLogic.totalQuestions != nouns.length) {
                ref
                    .read(audioImageMatchingQuizLogicProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return NounsMatchingQuizContent(
              currentNoun:
                  ref.watch(audioImageMatchingQuizLogicProvider).currentNoun,
              answerOptions:
                  ref.watch(audioImageMatchingQuizLogicProvider).answerOptions,
              isCorrect:
                  ref.watch(audioImageMatchingQuizLogicProvider).isCorrect,
              isWrong: ref.watch(audioImageMatchingQuizLogicProvider).isWrong,
              score: ref.watch(audioImageMatchingQuizLogicProvider).score,
              answeredQuestions: ref
                  .watch(audioImageMatchingQuizLogicProvider)
                  .answeredQuestions,
              totalQuestions:
                  ref.watch(audioImageMatchingQuizLogicProvider).totalQuestions,
              onOptionSelected: (noun) => ref
                  .read(audioImageMatchingQuizLogicProvider)
                  .checkAnswer(noun, context),
              playCurrentNounAudio: () => ref
                  .read(audioImageMatchingQuizLogicProvider)
                  .playCurrentNounAudio(context),
              isInteractionDisabled: ref
                  .watch(audioImageMatchingQuizLogicProvider)
                  .isInteractionDisabled,
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

  // تم حذف _buildCategoryDropdown هنا

  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(audioImageMatchingQuizLogicProvider);
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
                final currentCategory =
                    ref.read(selectedAudioImageQuizCategoryProvider);
                ref
                    .read(audioImageMatchingQuizLogicProvider)
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
