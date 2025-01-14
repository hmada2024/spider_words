// lib/pages/quiz_pages/images_matching_quiz_page_new.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_content_new.dart'; // استيراد النسخة الجديدة من الكونتنت
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/images_matching_quiz_logic_new.dart'; // استيراد النسخة الجديدة من اللوجيك
import 'package:spider_words/providers/noun_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart';

final selectedQuizCategoryNewProvider = StateProvider<String>((ref) => 'all');

final matchingQuizLogicNewProvider =
    ChangeNotifierProvider.autoDispose<ImagesMatchingQuizLogicNew>((ref) {
  final selectedCategory = ref.watch(selectedQuizCategoryNewProvider);
  final nouns = ref
          .watch(nounsProvider)
          .value
          ?.where((noun) =>
              selectedCategory == 'all' || noun.category == selectedCategory)
          .toList() ??
      [];
  final audioPlayer = ref.read(audioPlayerProvider);
  return ImagesMatchingQuizLogicNew(
      initialNouns: nouns, audioPlayer: audioPlayer);
});

class ImagesMatchingQuizPageNew extends ConsumerStatefulWidget {
  static const routeName = '/images_matching_quiz_new';

  const ImagesMatchingQuizPageNew({super.key});

  @override
  ImagesMatchingQuizPageNewState createState() =>
      ImagesMatchingQuizPageNewState();
}

class ImagesMatchingQuizPageNewState
    extends ConsumerState<ImagesMatchingQuizPageNew> {
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
    final selectedCategory = ref.watch(selectedQuizCategoryNewProvider);
    final nounsState = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Images Matching Quiz New',
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
                      ref.read(matchingQuizLogicNewProvider).resetQuiz();
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
                        ref.watch(selectedQuizCategoryNewProvider),
                    onCategoryChanged: (newValue) {
                      if (newValue != null) {
                        ref
                            .read(selectedQuizCategoryNewProvider.notifier)
                            .state = newValue;
                        ref
                            .read(matchingQuizLogicNewProvider)
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
              final quizLogic = ref.read(matchingQuizLogicNewProvider);
              if (listEquals(quizLogic.initialNouns, nouns) == false) {
                ref.read(matchingQuizLogicNewProvider).initialNouns = nouns;
                ref
                    .read(matchingQuizLogicNewProvider)
                    .resetQuizForCategory(selectedCategory);
              }
              if (quizLogic.totalQuestions != nouns.length) {
                ref
                    .read(matchingQuizLogicNewProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return ImagesMatchingQuizContentNew(
              // استخدام النسخة الجديدة من الكونتنت هنا
              currentNoun: ref.watch(matchingQuizLogicNewProvider).currentNoun,
              answerOptions:
                  ref.watch(matchingQuizLogicNewProvider).imageOptions,
              isCorrect: ref.watch(matchingQuizLogicNewProvider).isCorrect,
              isWrong: ref.watch(matchingQuizLogicNewProvider).isWrong,
              score: ref.watch(matchingQuizLogicNewProvider).score,
              answeredQuestions:
                  ref.watch(matchingQuizLogicNewProvider).answeredQuestions,
              totalQuestions:
                  ref.watch(matchingQuizLogicNewProvider).totalQuestions,
              onOptionSelected: (noun) =>
                  ref.read(matchingQuizLogicNewProvider).checkAnswer(noun),
              playCurrentNounAudio: () =>
                  ref.read(matchingQuizLogicNewProvider).playCurrentNounAudio(),
              isInteractionDisabled:
                  ref.watch(matchingQuizLogicNewProvider).isInteractionDisabled,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(matchingQuizLogicNewProvider).resetQuiz();
        },
        tooltip: 'إعادة تشغيل الاختبار',
        child: const Icon(Icons.flag),
      ),
    );
  }
}
