// lib/widgets/custom_app_bar.dart ---
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; //  إضافة قائمة actions

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.05; // حجم الخط كنسبة من عرض الشاشة

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black26,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      actions: actions, // تعيين قائمة  actions
      centerTitle: true,
      elevation: 5,
    );
  }
}
