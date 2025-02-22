// lib/providers/noun_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/main.dart';
import 'package:spider_words/models/nouns_model.dart';

final nounsProvider = FutureProvider.autoDispose<List<Noun>>((ref) async {
  try {
    final dbHelper = ref.read(databaseHelperProvider);
    return await dbHelper.getNouns();
  } catch (e) {
    throw Exception('Failed to load nouns: $e'); // رسالة خطأ أوضح
  }
});
