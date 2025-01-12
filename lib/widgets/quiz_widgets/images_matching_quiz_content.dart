// lib/widgets/quiz_widgets/images_matching_quiz_content.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';

class ImagesMatchingQuizContent extends ConsumerWidget {
  final Noun? currentNoun;
  final List<Noun> answerOptions;
  final bool isCorrect;
  final bool isWrong;
  final int score;
  final int answeredQuestions;
  final int totalQuestions;
  final Function(Noun) onOptionSelected;
  final VoidCallback playCurrentNounAudio; // <-- هذا المتغير
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

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03), // هوامش متناسبة
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
              childAspectRatio: 1.0,
              crossAxisSpacing: optionSpacing,
              mainAxisSpacing: optionSpacing,
              children: answerOptions.map((option) {
                final isCorrectOption = option.id == currentNoun?.id;
                final isAnswered = isCorrect || isWrong;
                Color? buttonColor = Colors.blue;
                if (isAnswered) {
                  buttonColor = isCorrectOption
                      ? const Color.fromARGB(255, 12, 99, 15)
                      : AppConstants.wrongColor;
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      onOptionSelected(option);
                      if (isCorrect) {
                        playCorrectSound();
                      } else if (isWrong) {
                        playWrongSound();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius)),
                      elevation: 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: option.image != null
                          ? Image.memory(
                              option.image!,
                              fit: BoxFit.cover, // تغطية المساحة
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isCorrect)
            Padding(
              padding: EdgeInsets.only(top: optionSpacing),
              child: Text(
                'Correct!',
                style: TextStyle(
                    color: AppConstants.correctColor,
                    fontSize: correctTextSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
          if (isWrong)
            Padding(
              padding: EdgeInsets.only(top: optionSpacing),
              child: Text(
                'Wrong!',
                style: TextStyle(
                    color: AppConstants.wrongColor,
                    fontSize: correctTextSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
