// lib/widgets/quiz_widgets/quiz_image_option.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spider_words/utils/app_constants.dart';

class QuizImageOption extends StatelessWidget {
  final Uint8List? imageData;
  final VoidCallback? onTap;
  final bool isCorrect;
  final bool isWrong;
  final double borderRadius;
  final double imageShadowBlurRadius;
  final double imageShadowOffset;

  const QuizImageOption({
    super.key,
    required this.imageData,
    this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
    required this.borderRadius,
    required this.imageShadowBlurRadius,
    required this.imageShadowOffset,
  });

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    if (isCorrect) {
      borderColor = AppConstants.correctColor;
    } else if (isWrong) {
      borderColor = AppConstants.wrongColor;
    }

    Widget imageWidget;
    if (imageData != null) {
      imageWidget = Image.memory(
        imageData!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder_image.jpg',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/placeholder_image.jpg',
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              spreadRadius: 0,
              blurRadius: imageShadowBlurRadius,
              offset: Offset(imageShadowOffset, imageShadowOffset),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: imageWidget,
        ),
      ),
    );
  }
}
