// lib/models/compound_word_model.dart
import 'dart:typed_data';

class CompoundWord {
  final int id;
  final String main;
  final String part1;
  final String part2;
  final String? example;
  final Uint8List? mainAudio;
  final Uint8List? mainExampleAudio;

  CompoundWord({
    required this.id,
    required this.main,
    required this.part1,
    required this.part2,
    this.example,
    this.mainAudio,
    this.mainExampleAudio,
  });
}
