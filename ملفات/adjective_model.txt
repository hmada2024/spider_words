// models/adjective_model.dart
import 'dart:typed_data';

class Adjective {
  final int id;
  final String mainAdjective;
  final String mainExample;
  final String reverseAdjective;
  final String reverseExample;
  final Uint8List? mainAdjectiveAudio;
  final Uint8List? reverseAdjectiveAudio;
  final Uint8List? mainExampleAudio;
  final Uint8List? reverseExampleAudio;

  Adjective({
    required this.id,
    required this.mainAdjective,
    required this.mainExample,
    required this.reverseAdjective,
    required this.reverseExample,
    this.mainAdjectiveAudio,
    this.reverseAdjectiveAudio,
    this.mainExampleAudio,
    this.reverseExampleAudio,
  });
}
