// lib/pages/quiz_pages/nouns_matching_quiz_page.dart
import 'dart:math'; // تم إضافة هذا السطر

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_quiz_logic.dart';

final nounsForAudioImageQuizProvider = FutureProvider.autoDispose
    .family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  if (category == 'all') {
    return dbHelper.getNounsForMatchingQuiz();
  } else {
    return dbHelper.getNounsByCategory(category);
  }
});

final selectedAudioImageQuizCategoryProvider =
    StateProvider<String>((ref) => 'all');

final audioImageMatchingQuizLogicProvider =
    ChangeNotifierProvider.autoDispose<NounsMatchingQuizLogic>((ref) {
  final selectedCategory = ref.watch(selectedAudioImageQuizCategoryProvider);
  final nouns =
      ref.watch(nounsForAudioImageQuizProvider(selectedCategory)).maybeWhen(
            data: (data) => data,
            orElse: () => [],
          ) as List<Noun>;
  final audioPlayer = ref.read(audioPlayerProvider);
  return NounsMatchingQuizLogic(initialNouns: nouns, audioPlayer: audioPlayer);
});

class NounsMatchingQuizPage extends ConsumerWidget {
  static const routeName = '/audio_image_matching_game';

  const NounsMatchingQuizPage({super.key});

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedAudioImageQuizCategoryProvider);
    final nounsState =
        ref.watch(nounsForAudioImageQuizProvider(selectedCategory));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns Matching Quiz',
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
              if (ref
                      .read(audioImageMatchingQuizLogicProvider)
                      .totalQuestions !=
                  nouns.length) {
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
              value: ref.watch(selectedAudioImageQuizCategoryProvider),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                ref
                    .read(selectedAudioImageQuizCategoryProvider.notifier)
                    .state = newValue!;
                ref
                    .read(audioImageMatchingQuizLogicProvider)
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

  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    final gameLogic = ref.read(audioImageMatchingQuizLogicProvider);
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
