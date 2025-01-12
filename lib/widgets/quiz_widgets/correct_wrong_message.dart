// lib/widgets/quiz_widgets/correct_wrong_message.dart
import 'package:flutter/material.dart';
import 'package:spider_words/utils/app_constants.dart';

class CorrectWrongMessage extends StatelessWidget {
  final bool isCorrect;
  final double correctTextSize;

  const CorrectWrongMessage({
    super.key,
    required this.isCorrect,
    required this.correctTextSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02), // هامش علوي نسبي
      child: Center(
        child: Text(
          isCorrect ? 'Correct!' : 'Wrong!',
          style: TextStyle(
            color:
                isCorrect ? AppConstants.correctColor : AppConstants.wrongColor,
            fontSize: correctTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
