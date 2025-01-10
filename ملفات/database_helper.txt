// data/database_helper.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'package:spider_words/models/compound_word_model.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'dart:io';
import '../utils/constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, Constants.databaseName);

    var exists = await databaseExists(path);

    if (!exists) {
      if (kDebugMode) {
        print("Creating new copy from asset");
      }
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load("assets/${Constants.databaseName}");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      if (kDebugMode) {
        print("Opening existing database");
      }
    }
    return await openDatabase(path, readOnly: true);
  }

  // Function to retrieve data from the adjectives table
  Future<List<Adjective>> getAdjectives() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(Constants.adjectivesTable);

    return List.generate(maps.length, (i) {
      return Adjective(
        id: maps[i][Constants.adjectiveIdColumn],
        mainAdjective: maps[i][Constants.mainAdjectiveColumn],
        mainExample: maps[i][Constants.mainExampleColumn],
        reverseAdjective: maps[i][Constants.reverseAdjectiveColumn],
        reverseExample: maps[i][Constants.reverseExampleColumn],
        mainAdjectiveAudio: maps[i][Constants.mainAdjectiveAudioColumn],
        reverseAdjectiveAudio: maps[i][Constants.reverseAdjectiveAudioColumn],
        mainExampleAudio: maps[i][Constants.mainExampleAudioColumn],
        reverseExampleAudio: maps[i][Constants.reverseExampleAudioColumn],
      );
    });
  }

  // دالة جديدة لاسترجاع الاسماء حسب الفئة
  Future<List<Noun>> getNounsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Constants.nounsTable,
      where: '${Constants.nounCategoryColumn} = ?',
      whereArgs: [category],
    );

    return List.generate(maps.length, (i) {
      return Noun(
        id: maps[i][Constants.nounIdColumn],
        name: maps[i][Constants.nounNameColumn],
        image: maps[i][Constants.nounImageColumn],
        audio: maps[i][Constants.nounAudioColumn],
        category: maps[i][Constants.nounCategoryColumn],
      );
    });
  }

  // Function to retrieve data from the nouns table
  Future<List<Noun>> getNouns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(Constants.nounsTable);

    return List.generate(maps.length, (i) {
      return Noun(
        id: maps[i][Constants.nounIdColumn],
        name: maps[i][Constants.nounNameColumn],
        image: maps[i][Constants.nounImageColumn],
        audio: maps[i][Constants.nounAudioColumn],
        category: maps[i][Constants.nounCategoryColumn],
      );
    });
  }

  // Function to retrieve data from the compound_words table
  Future<List<CompoundWord>> getCompoundWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(Constants.compoundWordsTable);

    return List.generate(maps.length, (i) {
      return CompoundWord(
        id: maps[i][Constants.compoundWordIdColumn],
        main: maps[i][Constants.compoundWordMainColumn],
        part1: maps[i][Constants.compoundWordPart1Column],
        part2: maps[i][Constants.compoundWordPart2Column],
        example: maps[i][Constants.compoundWordExampleColumn],
        mainAudio: maps[i][Constants.compoundWordMainAudioColumn],
        mainExampleAudio: maps[i][Constants.compoundWordExampleAudioColumn],
      );
    });
  }

  // Function to retrieve nouns for the matching game
  Future<List<Noun>> getNounsForMatchingGame() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Constants.nounsTable,
    );
    return maps.map((e) => Noun.fromMap(e)).toList();
  }
}
