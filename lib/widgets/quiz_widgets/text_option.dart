// lib/widgets/quiz_widgets/text_option.dart
import 'package:flutter/material.dart';
import 'package:spider_words/utils/app_constants.dart';

class TextOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool isWrong;

  const TextOption({
    super.key,
    required this.text,
    required this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? buttonColor = Colors.blue;
    if (isCorrect) {
      buttonColor = AppConstants.correctColor;
    } else if (isWrong) {
      buttonColor = AppConstants.wrongColor;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
