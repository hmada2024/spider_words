// lib/pages/quiz_pages/nouns_matching_quiz_page.dart
import 'dart:math'; // تم إضافة هذا السطر

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_game_content.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/nouns_matching_game_logic.dart';

final nounsForAudioImageGameProvider = FutureProvider.autoDispose
    .family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  if (category == 'all') {
    return dbHelper.getNounsForMatchingGame();
  } else {
    return dbHelper.getNounsByCategory(category);
  }
});

final selectedAudioImageGameCategoryProvider =
    StateProvider<String>((ref) => 'all');

final audioImageMatchingGameLogicProvider =
    ChangeNotifierProvider.autoDispose<NounsMatchingTestLogic>((ref) {
  final selectedCategory = ref.watch(selectedAudioImageGameCategoryProvider);
  final nouns =
      ref.watch(nounsForAudioImageGameProvider(selectedCategory)).maybeWhen(
            data: (data) => data,
            orElse: () => [],
          ) as List<Noun>;
  final audioPlayer = ref.read(audioPlayerProvider);
  return NounsMatchingTestLogic(initialNouns: nouns, audioPlayer: audioPlayer);
});

class NounsMatchingTestPage extends ConsumerWidget {
  static const routeName = '/audio_image_matching_game';

  const NounsMatchingTestPage({super.key});

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedAudioImageGameCategoryProvider);
    final nounsState =
        ref.watch(nounsForAudioImageGameProvider(selectedCategory));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Image & Audio Match',
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
                      .read(audioImageMatchingGameLogicProvider)
                      .totalQuestions !=
                  nouns.length) {
                ref
                    .read(audioImageMatchingGameLogicProvider)
                    .setTotalQuestions(nouns.length);
              }
            });

            return NounsMatchingTestContent(
              currentNoun:
                  ref.watch(audioImageMatchingGameLogicProvider).currentNoun,
              answerOptions:
                  ref.watch(audioImageMatchingGameLogicProvider).answerOptions,
              isCorrect:
                  ref.watch(audioImageMatchingGameLogicProvider).isCorrect,
              isWrong: ref.watch(audioImageMatchingGameLogicProvider).isWrong,
              score: ref.watch(audioImageMatchingGameLogicProvider).score,
              answeredQuestions: ref
                  .watch(audioImageMatchingGameLogicProvider)
                  .answeredQuestions,
              totalQuestions:
                  ref.watch(audioImageMatchingGameLogicProvider).totalQuestions,
              onOptionSelected: (noun) => ref
                  .read(audioImageMatchingGameLogicProvider)
                  .checkAnswer(noun),
              playCurrentNounAudio: () => ref
                  .read(audioImageMatchingGameLogicProvider)
                  .playCurrentNounAudio(),
              isInteractionDisabled: ref
                  .watch(audioImageMatchingGameLogicProvider)
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
              value: ref.watch(selectedAudioImageGameCategoryProvider),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                ref
                    .read(selectedAudioImageGameCategoryProvider.notifier)
                    .state = newValue!;
                ref
                    .read(audioImageMatchingGameLogicProvider)
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
    final gameLogic = ref.read(audioImageMatchingGameLogicProvider);
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
                    ref.read(selectedAudioImageGameCategoryProvider);
                ref
                    .read(audioImageMatchingGameLogicProvider)
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
