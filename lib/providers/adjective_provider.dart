// lib/providers/adjective_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/data/database_helper.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/models/adjective_model.dart';

final adjectivesProvider =
    FutureProvider.autoDispose<List<Adjective>>((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return await dbHelper.getAdjectives();
});
