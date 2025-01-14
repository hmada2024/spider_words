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

  Future<void> playAudio(
      WidgetRef ref, BuildContext context, Uint8List? audioBytes) async {
    if (audioBytes != null) {
      try {
        await ref.read(audioPlayerProvider).play(BytesSource(audioBytes));
      } catch (e) {
        debugPrint('Error playing audio: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تشغيل الصوت لهذا العنصر.')),
          );
        }
      }
    } else {
      debugPrint('Audio bytes are null for this noun.');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف الصوتي غير متوفر.')),
        );
      }
    }
  }

  Future<void> playCorrectSound(WidgetRef ref) async {
    try {
      await ref
          .read(audioPlayerProvider)
          .play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Error playing correct sound: $e');
    }
  }

  Future<void> playWrongSound(WidgetRef ref) async {
    try {
      await ref.read(audioPlayerProvider).play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      debugPrint('Error playing wrong sound: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double topInfoPadding = screenHeight * 0.015;
    final double optionSpacing = screenWidth * 0.05;
    final double correctTextSize = screenWidth * 0.05;
    final double borderRadius = screenWidth * 0.02;
    final double buttonFontSize = screenWidth * 0.038;
    final double buttonPaddingVertical = screenHeight * 0.015;
    final double imageShadowBlurRadius = screenWidth * 0.01;
    final double imageShadowOffset = screenWidth * 0.005;
    final double spaceBetweenImageAndOptions = screenHeight * 0.06;

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
            child: Stack(
              children: [
                GestureDetector(
                  onTap: isInteractionDisabled
                      ? null
                      : () => playAudio(ref, context, currentNoun?.audio),
                  child: Container(
                    width: screenWidth * 0.44,
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
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                    'Error loading image for ${currentNoun?.name}: $error');
                                return Image.asset(
                                    'assets/images/placeholder_image.png');
                              },
                            )
                          : Image.asset('assets/images/placeholder_image.png',
                              fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: Colors.blue,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: isInteractionDisabled
                        ? null
                        : () => playAudio(ref, context, currentNoun?.audio),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spaceBetweenImageAndOptions),
          IgnorePointer(
            ignoring: isInteractionDisabled,
            child: answerOptions.isEmpty
                ? const Center(child: Text('لا توجد خيارات إجابة.'))
                : GridView.count(
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
                              playCorrectSound(ref);
                            } else if (isWrong) {
                              playWrongSound(ref);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: buttonColor,
                            padding: EdgeInsets.symmetric(
                                vertical: buttonPaddingVertical),
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
