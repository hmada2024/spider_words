// lib/pages/quiz_pages/nouns_matching_quiz_page.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_logic.dart';
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart';

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

class NounsMatchingQuizPage extends ConsumerStatefulWidget {
  static const routeName = '/nouns_matching_quiz';

  const NounsMatchingQuizPage({super.key});

  @override
  NounsMatchingQuizPageState createState() => NounsMatchingQuizPageState();
}

class NounsMatchingQuizPageState extends ConsumerState<NounsMatchingQuizPage> {
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
    final selectedCategory = ref.watch(selectedAudioImageQuizCategoryProvider);
    final nounsState = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns Matching Quiz',
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
                      ref.read(audioImageMatchingQuizLogicProvider).resetQuiz();
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
                  .checkAnswer(noun),
              playCurrentNounAudio: () => ref
                  .read(audioImageMatchingQuizLogicProvider)
                  .playCurrentNounAudio(),
              isInteractionDisabled: ref
                  .watch(audioImageMatchingQuizLogicProvider)
                  .isInteractionDisabled,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(audioImageMatchingQuizLogicProvider)
              .resetQuiz(); // استدعاء دالة إعادة التشغيل
        },
        tooltip: 'إعادة تشغيل الاختبار',
        child: const Icon(Icons.flag),
      ),
    );
  }
}
