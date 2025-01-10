// models/noun.dart
import 'dart:typed_data';

class Noun {
  final int id;
  final String name;
  final Uint8List? image;
  final Uint8List? audio;
  final String category;

  Noun({
    required this.id,
    required this.name,
    this.image,
    this.audio,
    required this.category,
  });

  factory Noun.fromMap(Map<String, dynamic> map) {
    return Noun(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as Uint8List?,
      audio: map['audio'] as Uint8List?,
      category: map['category'] as String,
    );
  }
}
