// main.dart
import 'package:flutter/material.dart';
import 'package:spider_words/pages/quiz_pages/nouns_matching_quiz_page_new.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spider_words/pages/vocabulary_pages/adjectives_page.dart';
import 'package:spider_words/pages/vocabulary_pages/compound_words_page.dart';
import 'package:spider_words/pages/common_pages/home_page.dart';
import 'package:spider_words/pages/vocabulary_pages/nouns_page.dart';
import 'package:spider_words/pages/quiz_pages/images_matching_quiz_page.dart';
import 'package:spider_words/pages/quiz_pages/images_matching_quiz_page_new.dart'; // استيراد الصفحة الجديدة
import 'package:spider_words/pages/quiz_pages/nouns_matching_quiz_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/data/database_helper.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spider Words',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        AdjectivesPage.routeName: (context) => const AdjectivesPage(),
        NounsPage.routeName: (context) => const NounsPage(),
        CompoundWordsPage.routeName: (context) => const CompoundWordsPage(),
        ImagesMatchingQuizPage.routeName: (context) =>
            const ImagesMatchingQuizPage(),
        ImagesMatchingQuizPageNew.routeName: (context) => // المسار الجديد
            const ImagesMatchingQuizPageNew(),
        NounsMatchingQuizPage.routeName: (context) =>
            const NounsMatchingQuizPage(),
        NounsMatchingQuizPageNew.routeName: (context) =>
            const NounsMatchingQuizPageNew(),
      },
    );
  }
}
