// lib/widgets/quiz_widgets/nouns_matching_quiz_content.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/correct_wrong_message.dart'; // هذا السطر تم اضافته

class NounsMatchingQuizContent extends ConsumerWidget {
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

  const NounsMatchingQuizContent({
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

    // تحديد النسب المئوية والأحجام بناءً على أبعاد الشاشة
    final double topInfoPadding = screenHeight * 0.015;
    final double optionSpacing = screenWidth * 0.02;
    final double correctTextSize = screenWidth * 0.05;
    final double borderRadius = screenWidth * 0.02;
    final double imageWidth = screenWidth * 0.7;
    final double buttonFontSize = screenWidth * 0.038;
    final double buttonPaddingVertical = screenHeight * 0.015;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Center(
            child: GestureDetector(
              onTap: isInteractionDisabled
                  ? null
                  : () => playAudio(currentNoun?.audio),
              child: Container(
                width: imageWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: currentNoun?.image != null
                          ? Image.memory(
                              currentNoun!.image!,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon:
                            Icon(Icons.volume_up, color: Colors.blue.shade700),
                        onPressed: isInteractionDisabled
                            ? null
                            : () => playAudio(currentNoun?.audio),
                      ),
                    ),
                  ],
                ),
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
              childAspectRatio: 3.0,
              crossAxisSpacing: optionSpacing,
              mainAxisSpacing: optionSpacing,
              children: answerOptions.map((option) {
                final isCorrectOption = option.id == currentNoun?.id;
                final isAnswered = isCorrect || isWrong;
                Color? buttonColor = Colors.blue;
                if (isAnswered) {
                  buttonColor = isCorrectOption
                      ? AppConstants.correctColor
                      : AppConstants.wrongColor;
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      padding:
                          EdgeInsets.symmetric(vertical: buttonPaddingVertical),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      option.name,
                      style: TextStyle(fontSize: buttonFontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isCorrect || isWrong) // تم التعديل هنا
            CorrectWrongMessage(
              isCorrect: isCorrect,
              correctTextSize: correctTextSize,
            ),
        ],
      ),
    );
  }
}
