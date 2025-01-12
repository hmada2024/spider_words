// lib/widgets/quiz_widgets/images_matching_quiz_content.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:spider_words/utils/screen_utils.dart';
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
    final double optionSpacing = screenWidth * 0.05;
    final double correctTextSize = screenWidth * 0.06;
    final double borderRadius = screenWidth * 0.03;

    return Padding(
      // تم استبدال SingleChildScrollView بـ Padding
      padding: EdgeInsets.all(screenWidth * 0.05),
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
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02), // تعديل حجم منطقة السؤال
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentNoun?.name ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  IconButton(
                    icon: Icon(Icons.volume_up,
                        size: screenWidth * 0.08, color: Colors.blue.shade800),
                    onPressed: isInteractionDisabled
                        ? null
                        : () => playAudio(currentNoun?.audio),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: optionSpacing), // توحيد المسافات
          IgnorePointer(
            ignoring: isInteractionDisabled,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1,
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
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => onOptionSelected(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      elevation: 0,
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
