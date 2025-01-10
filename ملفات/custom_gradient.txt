// lib/widgets/custom_gradient.dart ---
import 'package:flutter/material.dart';

class CustomGradient extends StatelessWidget {
  final Widget child;

  const CustomGradient({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBBD2C5), // لون فاتح
            Color(0xFF536976), // لون داكن
          ],
        ),
      ),
      child: child,
    );
  }
}
