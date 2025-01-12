// lib/widgets/quiz_widgets/nouns_matching_quiz_content.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/widgets/quiz_widgets/correct_wrong_message.dart';

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

    final double topInfoPadding = screenHeight *
        0.015; // Padding above the total questions and correct/answered info, relative to screen height.
    final double optionSpacing = screenWidth *
        0.05; // Spacing between answer options, relative to screen width.
    final double correctTextSize = screenWidth *
        0.05; // Font size for the "Correct" message, relative to screen width.
    final double borderRadius = screenWidth *
        0.02; // Border radius for buttons and image container, relative to screen width.
    final double buttonFontSize = screenWidth *
        0.038; // Font size for the text on the answer option buttons, relative to screen width.
    final double buttonPaddingVertical = screenHeight *
        0.015; // Vertical padding inside the answer option buttons, relative to screen height.
    final double imageShadowBlurRadius = screenWidth *
        0.01; // Blur radius for the shadow behind the image, relative to screen width.
    final double imageShadowOffset = screenWidth *
        0.005; // Offset for the shadow behind the image, relative to screen width.
    final double spaceBetweenImageAndOptions = screenHeight *
        0.06; // Spacing between the image and the answer options, set to 6% of screen height.

    return Padding(
      padding: EdgeInsets.all(screenWidth *
          0.03), // Overall padding around the quiz content, relative to screen width.
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
                      fontSize: screenWidth *
                          0.04, // Font size for the total questions text, relative to screen width.
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Correct: $score',
                      style: TextStyle(
                          fontSize: screenWidth *
                              0.035, // Font size for the correct score text, relative to screen width.
                          color: AppConstants.correctColor),
                    ),
                    SizedBox(width: optionSpacing),
                    Text(
                      'Answered: $answeredQuestions',
                      style: TextStyle(
                          fontSize: screenWidth *
                              0.035), // Font size for the answered questions text, relative to screen width.
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Stack(
              // Wrap with Stack
              children: [
                GestureDetector(
                  onTap: isInteractionDisabled
                      ? null
                      : () => playAudio(currentNoun?.audio),
                  child: Container(
                    width: screenWidth *
                        0.44, // Width of the image container, relative to screen width.
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 1),
                          spreadRadius: 3,
                          blurRadius: imageShadowBlurRadius,
                          offset: Offset(imageShadowOffset, imageShadowOffset),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: currentNoun?.image != null
                          ? Image.memory(
                              currentNoun!.image!,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  // Position the icon
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.volume_up,
                    color: Colors.blue,
                    size: screenWidth * 0.06, // Adjust size as needed
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height:
                  spaceBetweenImageAndOptions), // Added SizedBox for spacing between image and options.
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
                          color: const Color.fromARGB(255, 6, 0, 0)
                              .withValues(alpha: 3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(2, 2)),
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
