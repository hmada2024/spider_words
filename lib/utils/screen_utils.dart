// lib/utils/screen_utils.dart
import 'package:flutter/material.dart';

class ScreenUtils {
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
