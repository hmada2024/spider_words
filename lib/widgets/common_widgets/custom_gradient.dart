// lib/widgets/common_widgets/custom_gradient.dart
import 'package:flutter/material.dart';

class CustomGradient extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const CustomGradient({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF00C9FF), // لون أزرق فاتح
      Color(0xFF92FE9D) // لون أخضر فاتح
    ],
    this.begin = Alignment.topLeft, // اتجاه التدرج يبدأ من أعلى اليسار
    this.end = Alignment.bottomRight, // اتجاه التدرج ينتهي في أسفل اليمين
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
