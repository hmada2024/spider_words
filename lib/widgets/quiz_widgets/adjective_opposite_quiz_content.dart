// lib/widgets/quiz_widgets/adjective_opposite_quiz_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'package:spider_words/pages/quiz_pages/adjective_opposite_quiz_page.dart';
import 'package:spider_words/utils/app_constants.dart';
import 'package:spider_words/widgets/quiz_widgets/correct_wrong_message.dart';

class AdjectiveOppositeQuizContent extends ConsumerStatefulWidget {
  const AdjectiveOppositeQuizContent({super.key});

  @override
  AdjectiveOppositeQuizContentState createState() =>
      AdjectiveOppositeQuizContentState();
}

class AdjectiveOppositeQuizContentState
    extends ConsumerState<AdjectiveOppositeQuizContent>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(adjectiveOppositeQuizLogicProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final optionSpacing = screenWidth * 0.05;
    final correctTextSize = screenWidth * 0.05;
    final borderRadius = screenWidth * 0.02;
    final buttonFontSize = screenWidth * 0.045;
    final buttonPaddingVertical = screenHeight * 0.015;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Column(
              children: [
                Text(
                  'Total Questions: ${logic.totalQuestions}',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Correct: ${logic.score}',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppConstants.correctColor),
                    ),
                    SizedBox(width: optionSpacing),
                    Text(
                      'Answered: ${logic.answeredQuestions}',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: logic.isInteractionDisabled
                ? null
                : logic.playMainAdjectiveAudio,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.015),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speaker,
                      size: screenWidth * 0.06, color: Colors.blue.shade800),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    logic.currentAdjective?.mainAdjective ?? '',
                    style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            child: Text(
              logic.currentAdjective?.mainExample ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontStyle: FontStyle.italic),
            ),
          ),
          IgnorePointer(
            ignoring: logic.isInteractionDisabled,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: optionSpacing,
              mainAxisSpacing: optionSpacing,
              children: logic.answerOptions.map((option) {
                final isCorrectOption =
                    option == logic.currentAdjective?.reverseAdjective;
                final isWrongOption =
                    option == logic.selectedAnswer && logic.isWrong;
                final isFading = logic.isCorrect && !isCorrectOption;

                return AnimatedOpacity(
                  opacity: isFading ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: GestureDetector(
                    onTap: logic.isInteractionDisabled
                        ? null
                        : () => ref
                            .read(adjectiveOppositeQuizLogicProvider)
                            .checkAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color:
                            isWrongOption ? Colors.red.shade300 : Colors.blue,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: buttonPaddingVertical),
                      child: Center(
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: buttonFontSize, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (logic.isCorrect &&
              logic.selectedAnswer == logic.currentAdjective?.reverseAdjective)
            _buildCorrectAnswerAnimation(logic.currentAdjective!),
          if (logic.isCorrect || logic.isWrong)
            CorrectWrongMessage(
                isCorrect: logic.isCorrect, correctTextSize: correctTextSize),
        ],
      ),
    );
  }

  Widget _buildCorrectAnswerAnimation(Adjective currentAdjective) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -2.0),
    ).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.easeInOut));

    _animationController!.forward();

    return SlideTransition(
      position: _slideAnimation!,
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.03),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Column(
            children: [
              Text(
                currentAdjective.reverseAdjective,
                style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.01),
                child: Text(
                  currentAdjective.reverseExample,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
