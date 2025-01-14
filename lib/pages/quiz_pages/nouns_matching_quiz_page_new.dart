// lib/pages/quiz_pages/nouns_matching_quiz_page_new.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_content_new.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_logic_new.dart';
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart';

final selectedAudioImageQuizCategoryNewProvider =
    StateProvider<String>((ref) => 'all');

final audioImageMatchingQuizLogicNewProvider =
    ChangeNotifierProvider.autoDispose<NounsMatchingQuizLogicNew>((ref) {
  final selectedCategory = ref.watch(selectedAudioImageQuizCategoryNewProvider);
  final nouns = ref
          .watch(nounsProvider)
          .value
          ?.where((noun) =>
              selectedCategory == 'all' || noun.category == selectedCategory)
          .toList() ??
      [];
  final audioPlayer = ref.read(audioPlayerProvider);
  return NounsMatchingQuizLogicNew(
      initialNouns: nouns, audioPlayer: audioPlayer);
});

class NounsMatchingQuizPageNew extends ConsumerStatefulWidget {
  static const routeName = '/nouns_matching_quiz_new';

  const NounsMatchingQuizPageNew({super.key});

  @override
  NounsMatchingQuizPageNewState createState() =>
      NounsMatchingQuizPageNewState();
}

class NounsMatchingQuizPageNewState
    extends ConsumerState<NounsMatchingQuizPageNew> {
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
    final selectedCategory =
        ref.watch(selectedAudioImageQuizCategoryNewProvider);
    final nounsState = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns Matching Quiz New',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('هل أنت متأكد أنك تريد الخروج؟'),
                content: const Text('سيتم فقدان تقدمك.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('لا'),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(audioImageMatchingQuizLogicNewProvider)
                          .resetQuiz();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('نعم (خروج)'),
                  ),
                ],
              ),
            );
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
                    selectedCategory:
                        ref.watch(selectedAudioImageQuizCategoryNewProvider),
                    onCategoryChanged: (newValue) {
                      if (newValue != null) {
                        ref
                            .read(selectedAudioImageQuizCategoryNewProvider
                                .notifier)
                            .state = newValue;
                        ref
                            .read(audioImageMatchingQuizLogicNewProvider)
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
              final quizLogic =
                  ref.read(audioImageMatchingQuizLogicNewProvider);
              if (listEquals(quizLogic.initialNouns, nouns) == false) {
                ref.read(audioImageMatchingQuizLogicNewProvider).initialNouns =
                    nouns;
                ref
                    .read(audioImageMatchingQuizLogicNewProvider)
                    .resetQuizForCategory(selectedCategory);
              }
              if (quizLogic.totalQuestions != nouns.length) {
                ref
                    .read(audioImageMatchingQuizLogicNewProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return NounsMatchingQuizContentNew(
              currentNoun:
                  ref.watch(audioImageMatchingQuizLogicNewProvider).currentNoun,
              answerOptions: ref
                  .watch(audioImageMatchingQuizLogicNewProvider)
                  .answerOptions,
              isCorrect:
                  ref.watch(audioImageMatchingQuizLogicNewProvider).isCorrect,
              isWrong:
                  ref.watch(audioImageMatchingQuizLogicNewProvider).isWrong,
              score: ref.watch(audioImageMatchingQuizLogicNewProvider).score,
              answeredQuestions: ref
                  .watch(audioImageMatchingQuizLogicNewProvider)
                  .answeredQuestions,
              totalQuestions: ref
                  .watch(audioImageMatchingQuizLogicNewProvider)
                  .totalQuestions,
              onOptionSelected: (noun) => ref
                  .read(audioImageMatchingQuizLogicNewProvider)
                  .checkAnswer(noun),
              playCurrentNounAudio: () => ref
                  .read(audioImageMatchingQuizLogicNewProvider)
                  .playCurrentNounAudio(),
              isInteractionDisabled: ref
                  .watch(audioImageMatchingQuizLogicNewProvider)
                  .isInteractionDisabled,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(audioImageMatchingQuizLogicNewProvider).resetQuiz();
        },
        tooltip: 'إعادة تشغيل الاختبار',
        child: const Icon(Icons.flag),
      ),
    );
  }
}
