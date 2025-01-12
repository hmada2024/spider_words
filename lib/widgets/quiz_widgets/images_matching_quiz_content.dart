// lib/widgets/quiz_widgets/images_matching_quiz_content.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/correct_wrong_message.dart'; // هذا السطر تم اضافته

class ImagesMatchingQuizContent extends ConsumerWidget {
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

  const ImagesMatchingQuizContent({
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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

    Future<void> playCorrectSound() async {
      try {
        await audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        debugPrint('Error playing correct sound: $e');
      }
    }

    Future<void> playWrongSound() async {
      try {
        await audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      } catch (e) {
        debugPrint('Error playing wrong sound: $e');
      }
    }

    // تحديد النسب المئوية والأحجام بناءً على أبعاد الشاشة
    final double topInfoPadding = screenHeight * 0.015;
    final double optionSpacing = screenWidth * 0.07;
    final double correctTextSize = screenWidth * 0.05;
    final double borderRadius = screenWidth * 0.02;
    final double wordAreaFontSize = screenWidth * 0.06;
    final double wordAreaPaddingVertical = screenHeight * 0.01;
    final double wordAreaPaddingHorizontal = screenWidth * 0.03;
    final double imageShadowBlurRadius = screenWidth * 0.01;
    final double imageShadowOffset = screenWidth * 0.005;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: topInfoPadding),
            child: Column(
              children: [
                Text(
                  'Total Questions: $totalQuestions',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Correct: $score',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppConstants.correctColor),
                    ),
                    SizedBox(width: optionSpacing),
                    Text(
                      'Answered: $answeredQuestions',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isInteractionDisabled
                ? null
                : () => playAudio(currentNoun?.audio),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: EdgeInsets.symmetric(
                vertical: wordAreaPaddingVertical,
                horizontal: wordAreaPaddingHorizontal,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up,
                        size: screenWidth * 0.07, color: Colors.blue.shade800),
                    onPressed: isInteractionDisabled
                        ? null
                        : () => playAudio(currentNoun?.audio),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    currentNoun?.name ?? '',
                    style: TextStyle(
                      fontSize: wordAreaFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: optionSpacing),
          IgnorePointer(
            ignoring: isInteractionDisabled,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: optionSpacing,
              mainAxisSpacing: optionSpacing,
              children: answerOptions.map((option) {
                final isCorrectOption = option.id == currentNoun?.id;
                final isAnswered = isCorrect || isWrong;
                Color? borderColor;
                if (isAnswered) {
                  borderColor = isCorrectOption
                      ? AppConstants.correctColor
                      : AppConstants.wrongColor;
                }
                return GestureDetector(
                  onTap: () {
                    onOptionSelected(option);
                    if (isCorrect) {
                      playCorrectSound();
                    } else if (isWrong) {
                      playWrongSound();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: borderColor ?? Colors.transparent, // لون الحدود
                        width: 2.0, // سمك الحدود
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          spreadRadius: 0,
                          blurRadius: imageShadowBlurRadius,
                          offset: Offset(imageShadowOffset,
                              imageShadowOffset), // ظل من اليسار والأسفل
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: option.image != null
                          ? Image.memory(
                              option.image!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isCorrect || isWrong)
            CorrectWrongMessage(
              isCorrect: isCorrect,
              correctTextSize: correctTextSize,
            ),
        ],
      ),
    );
  }
}
