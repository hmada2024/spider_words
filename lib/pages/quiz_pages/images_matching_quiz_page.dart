// lib/pages/quiz_pages/images_matching_quiz_page.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_logic.dart';
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart';

final selectedQuizCategoryProvider = StateProvider<String>((ref) => 'all');

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

class ImagesMatchingQuizPage extends ConsumerStatefulWidget {
  static const routeName = '/images_matching_quiz';

  const ImagesMatchingQuizPage({super.key});

  @override
  ImagesMatchingQuizPageState createState() => ImagesMatchingQuizPageState();
}

class ImagesMatchingQuizPageState
    extends ConsumerState<ImagesMatchingQuizPage> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = ref.read(audioPlayerProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedQuizCategoryProvider);
    final nounsState = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Images Matching Quiz',
        leading: IconButton(
          // The "Exit Quiz" button
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure you want to exit?'),
                content: const Text('Your progress will be lost.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes (Exit)'),
                  ),
                ],
              ),
            );
            if (shouldPop == true) {
              ref.read(matchingQuizLogicProvider).resetQuiz();
              if (mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final nounsAsyncValue = ref.watch(nounsProvider);
              return nounsAsyncValue.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) =>
                    Text('Error loading categories: $error'),
                data: (nouns) {
                  final categories = [
                    'all',
                    ...nouns.map((noun) => noun.category).toSet()
                  ];
                  return CategoryFilterDropdown(
                    categories: categories,
                    selectedCategory: ref.watch(selectedQuizCategoryProvider),
                    onCategoryChanged: (newValue) {
                      if (newValue != null) {
                        ref.read(selectedQuizCategoryProvider.notifier).state =
                            newValue;
                        ref
                            .read(matchingQuizLogicProvider)
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

  void _showQuizOverDialog(BuildContext context, WidgetRef ref) {
    final quizLogic = ref.read(matchingQuizLogicProvider);
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
