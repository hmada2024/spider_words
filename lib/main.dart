// main.dart
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spider_words/pages/adjectives_page.dart';
import 'package:spider_words/pages/compound_words_page.dart';
import 'package:spider_words/pages/home_page.dart';
import 'package:spider_words/pages/nouns_page.dart';
import 'package:spider_words/pages/matching_game_page.dart';
import 'package:spider_words/pages/audio_image_matching_game_page.dart'; // استيراد الصفحة الجديدة

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/data/database_helper.dart';

// Provider for AudioPlayer
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

// Provider for DatabaseHelper
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
      home: const HomePage(), // Set HomePage as the initial screen
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        AdjectivesPage.routeName: (context) => const AdjectivesPage(),
        NounsPage.routeName: (context) => const NounsPage(),
        CompoundWordsPage.routeName: (context) => const CompoundWordsPage(),
        MatchingGamePage.routeName: (context) =>
            const MatchingGamePage(), // إضافة مسار صفحة لعبة المطابقة
        AudioImageMatchingGamePage.routeName: (context) =>
            const AudioImageMatchingGamePage(), // إضافة مسار الصفحة الجديدة
      },
    );
  }
}
