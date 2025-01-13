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
      } catch (e) {
        debugPrint("Error creating database directory: $e");
        throw Exception(
            "Failed to create database directory"); // تحسين رسالة الخطأ
      }

      try {
        ByteData data =
            await rootBundle.load("assets/${Constants.databaseName}");
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint("Error copying database from assets: $e");
        throw Exception(
            "Failed to copy database from assets"); // تحسين رسالة الخطأ
      }
    } else {
      if (kDebugMode) {
        print("Opening existing database");
      }
    }
    return await openDatabase(path, readOnly: true);
  }

  // Function to retrieve data from the adjectives table
  Future<List<Adjective>> getAdjectives() async {
    try {
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
    } catch (e) {
      debugPrint("Error retrieving adjectives: $e");
      throw Exception(
          "Failed to retrieve adjectives from the database"); // تحسين رسالة الخطأ
    }
  }

  // دالة جديدة لاسترجاع الاسماء حسب الفئة
  Future<List<Noun>> getNounsByCategory(String category) async {
    try {
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
    } catch (e) {
      debugPrint("Error retrieving nouns by category '$category': $e");
      throw Exception(
          "Failed to retrieve nouns for the category '$category'"); // تحسين رسالة الخطأ
    }
  }

  // Function to retrieve data from the nouns table
  Future<List<Noun>> getNouns() async {
    try {
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
    } catch (e) {
      debugPrint("Error retrieving nouns: $e");
      throw Exception(
          "Failed to retrieve nouns from the database"); // تحسين رسالة الخطأ
    }
  }

  // Function to retrieve data from the compound_words table
  Future<List<CompoundWord>> getCompoundWords() async {
    try {
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
    } catch (e) {
      debugPrint("Error retrieving compound words: $e");
      throw Exception(
          "Failed to retrieve compound words from the database"); // تحسين رسالة الخطأ
    }
  }

  // Function to retrieve nouns for the matching Quiz (سيتم تجاهلها مؤقتًا)
  Future<List<Noun>> getNounsForMatchingQuiz() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Constants.nounsTable,
    );
    return maps.map((e) => Noun.fromMap(e)).toList();
  }
}
