// lib/providers/compound_word_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/data/database_helper.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/models/compound_word_model.dart';

final compoundWordsProvider =
    FutureProvider.autoDispose<List<CompoundWord>>((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return await dbHelper.getCompoundWords();
});
