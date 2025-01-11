// lib/widgets/matching_game_content.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:spider_words/utils/screen_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';

class MatchingGameContent extends ConsumerWidget {
  final Noun? currentNoun;
  final List<Noun> imageOptions;
  final bool isCorrect;
  final bool isWrong;
  final int score;
  final int answeredQuestions;
  final int totalQuestions;
  final Function(Noun) onOptionSelected;
  final VoidCallback playCurrentNounAudio;
  final bool isInteractionDisabled;

  const MatchingGameContent({
    super.key,
    required this.currentNoun,
    required this.imageOptions,
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
    final double audioIconRadius = screenWidth * 0.12;
    final double audioIconSize = screenWidth * 0.08;
    final double imageOptionWidth = screenWidth * 0.4;
    final double imageOptionHeight = screenWidth * 0.4;
    final double optionSpacing = screenWidth * 0.05;
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
            child: Center(
              child: CircleAvatar(
                radius: audioIconRadius,
                backgroundColor: Colors.blue.shade100,
                child: IconButton(
                  icon: Icon(Icons.volume_up, size: audioIconSize),
                  onPressed: isInteractionDisabled
                      ? null
                      : () => playAudio(currentNoun?.audio),
                ),
              ),
            ),
          ),
          SizedBox(height: bottomSpacing),
          IgnorePointer(
            ignoring: isInteractionDisabled,
            child: Wrap(
              spacing: optionSpacing,
              runSpacing: optionSpacing,
              alignment: WrapAlignment.center,
              children: imageOptions.map((option) {
                final isCorrectOption = option.id == currentNoun?.id;
                final isAnswered = isCorrect || isWrong;
                Color? borderColor;
                if (isAnswered) {
                  borderColor = isCorrectOption
                      ? AppConstants.correctColor
                      : (option.id == currentNoun?.id
                          ? AppConstants.correctColor
                          : AppConstants
                              .wrongColor); // عرض اللون الأحمر للإجابة الخاطئة
                }
                return SizedBox(
                  width: imageOptionWidth,
                  height: imageOptionHeight,
                  child: GestureDetector(
                    onTap: () => onOptionSelected(option),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: borderColor ?? Colors.transparent,
                          width: screenWidth * 0.01,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: option.image != null
                            ? Image.memory(
                                option.image!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
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
          if (isWrong) // عرض رسالة "خطأ"
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
