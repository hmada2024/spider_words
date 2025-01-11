// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:spider_words/pages/adjectives_page.dart';
import 'package:spider_words/pages/compound_words_page.dart';
import 'package:spider_words/pages/nouns_page.dart';
import 'package:spider_words/pages/matching_game_page.dart'; // استيراد صفحة لعبة المطابقة
import 'package:spider_words/pages/audio_image_matching_game_page.dart'; // استيراد صفحة لعبة الصوت والصورة
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_home_button.dart';
import 'package:spider_words/widgets/custom_gradient.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Vocabulary Builder'),
      body: const CustomGradient(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: HomeButtons(),
          ),
        ),
      ),
    );
  }
}

class HomeButtons extends StatelessWidget {
  const HomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing =
        screenWidth * 0.05; // المسافة بين الأزرار كنسبة من عرض الشاشة

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomHomeButton(
          icon: Icons.record_voice_over,
          labelText: 'Adjectives',
          routeName: AdjectivesPage.routeName,
          color: Colors.blueAccent.shade700,
        ),
        SizedBox(height: spacing),
        CustomHomeButton(
          icon: Icons.category,
          labelText: 'Nouns',
          routeName: NounsPage.routeName,
          color: Colors.green.shade700,
        ),
        SizedBox(height: spacing),
        CustomHomeButton(
          icon: Icons.merge_type,
          labelText: 'Compound Words',
          routeName: CompoundWordsPage.routeName,
          color: Colors.orange.shade700,
        ),
        SizedBox(height: spacing),
        CustomHomeButton(
          icon: Icons.gamepad,
          labelText: 'Matching Game',
          routeName: MatchingGamePage.routeName,
          color: Colors.purple.shade700,
        ),
        SizedBox(height: spacing),
        CustomHomeButton(
          icon: Icons.volume_up,
          labelText: 'Audio & Image Matching',
          routeName: AudioImageMatchingGamePage.routeName,
          color: Colors.red.shade700,
        ),
      ],
    );
  }
}
