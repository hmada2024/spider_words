// lib/widgets/quiz_widgets/nouns_matching_game_content.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:spider_words/utils/screen_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';

class NounsMatchingTestContent extends ConsumerWidget {
  final Noun? currentNoun;
  final List<Noun> answerOptions;
  final bool isCorrect;
  final bool isWrong;
  final int score;
  final int answeredQuestions;
  final int totalQuestions;
  final Function(Noun) onOptionSelected;
  final VoidCallback playCurrentNounAudio;
  final bool isInteractionDisabled;

  const NounsMatchingTestContent({
    super.key,
    required this.currentNoun,
    required this.answerOptions,
    required this.isCorrect,
    required this.isWrong,
    required this.score,
    required this.answeredQuestions,
    required this.totalQuestions,
    required this.onOptionSelected,
    required this.playCurrentNounAudio,
    required this.isInteractionDisabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenUtils.getWidth(context);
    final screenHeight = ScreenUtils.getHeight(context);
    final audioPlayer = ref.watch(audioPlayerProvider);

    Future<void> playAudio(Uint8List? audioBytes) async {
      if (audioBytes != null) {
        try {
          await audioPlayer.play(BytesSource(audioBytes));
        } catch (e) {
          debugPrint('Error playing audio: $e');
        }
      }
    }

    final double topInfoPadding = screenHeight * 0.02;
    final double imageDisplayWidth = screenWidth * 0.6;
    final double imageDisplayHeight = screenWidth * 0.6;
    final double optionButtonWidth = screenWidth * 0.4;
    final double optionButtonPadding = screenWidth * 0.03;
    final double optionSpacing = screenWidth * 0.05;
    // ignore: unused_local_variable
    final BorderRadius borderRadius =
        BorderRadius.circular(screenWidth * AppConstants.borderRadiusRatio);
    final double bottomSpacing = screenHeight * 0.02;
    final double correctTextSize = screenWidth * 0.06;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: topInfoPadding),
            child: Column(
              children: [
                Text(
                  'Total Questions: $totalQuestions',
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Correct: $score',
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AppConstants.correctColor),
                    ),
                    SizedBox(width: optionSpacing),
                    Text(
                      'Answered: $answeredQuestions',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: topInfoPadding),
            child: GestureDetector(
              onTap: isInteractionDisabled
                  ? null
                  : () => playAudio(currentNoun?.audio),
              child: SizedBox(
                width: imageDisplayWidth,
                height: imageDisplayHeight,
                child: currentNoun?.image != null
                    ? Image.memory(currentNoun!.image!, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
          ),
          SizedBox(height: bottomSpacing),
          IgnorePointer(
            ignoring: isInteractionDisabled,
            child: Column(
              children: answerOptions.map((option) {
                final isCorrectOption = option.id == currentNoun?.id;
                final isAnswered = isCorrect || isWrong;
                Color? buttonColor = Colors.blue;
                if (isAnswered) {
                  buttonColor = isCorrectOption
                      ? AppConstants.correctColor
                      : (option.id == currentNoun?.id
                          ? AppConstants.correctColor
                          : AppConstants.wrongColor);
                }
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: optionButtonPadding),
                  child: SizedBox(
                    width: optionButtonWidth,
                    child: ElevatedButton(
                      onPressed: () => onOptionSelected(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      child: Text(
                        option.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: bottomSpacing),
          if (isCorrect)
            Text(
              'Correct!',
              style: TextStyle(
                  color: AppConstants.correctColor,
                  fontSize: correctTextSize,
                  fontWeight: FontWeight.bold),
            ),
          if (isWrong)
            Text(
              'Wrong!',
              style: TextStyle(
                  color: AppConstants.wrongColor,
                  fontSize: correctTextSize,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
