// lib/widgets/common_widgets/custom_home_button.dart
import 'package:flutter/material.dart';

class CustomHomeButton extends StatelessWidget {
  final IconData icon;
  final String labelText;
  final String routeName;
  final Color color;

  const CustomHomeButton({
    super.key,
    required this.icon,
    required this.labelText,
    required this.routeName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.7; // عرض الزر كنسبة من عرض الشاشة
    final iconSize = screenWidth * 0.07; // حجم الأيقونة كنسبة من عرض الشاشة
    final fontSize = screenWidth * 0.05; // حجم الخط كنسبة من عرض الشاشة
    final padding = screenWidth * 0.03; // الهوامش كنسبة من عرض الشاشة

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: iconSize),
        label: Padding(
          padding: EdgeInsets.symmetric(vertical: padding),
          child: Text(
            labelText,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
