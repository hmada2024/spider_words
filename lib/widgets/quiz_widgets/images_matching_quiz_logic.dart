// lib/widgets/quiz_widgets/images_matching_quiz_logic.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';

class ImagesMatchingQuizLogic extends ChangeNotifier {
  List<Noun> initialNouns;
  final AudioPlayer audioPlayer;
  List<Noun> _nouns = [];
  Noun? _currentNoun;
  List<Noun> _imageOptions = [];
  bool _isCorrect = false;
  bool _isWrong = false;
  int _score = 0;
  int _answeredQuestions = 0;
  bool _isInteractionDisabled = false;
  int _totalQuestions = 0; // إضافة متغير لعدد الأسئلة الكلية

  int get score => _score;
  int get answeredQuestions => _answeredQuestions;
  int get totalQuestions => _totalQuestions;
  Noun? get currentNoun => _currentNoun;
  List<Noun> get imageOptions => _imageOptions;
  bool get isCorrect => _isCorrect;
  bool get isWrong => _isWrong;
  bool get isInteractionDisabled => _isInteractionDisabled;

  ImagesMatchingQuizLogic(
      {required this.initialNouns, required this.audioPlayer}) {
    _startNewGame();
  }

  void setTotalQuestions(int count) {
    _totalQuestions = count;
    notifyListeners();
  }

  void _startNewGame() {
    _nouns = List<Noun>.from(initialNouns)..shuffle();
    _totalQuestions = initialNouns.length;
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_nouns.isNotEmpty) {
      _isCorrect = false;
      _isWrong = false;
      _isInteractionDisabled = false;
      _currentNoun = _nouns.removeAt(0);
      _imageOptions = _generateImageOptions(_currentNoun!);
      _imageOptions.shuffle();
      playCurrentNounAudio();
      notifyListeners();
    } else {
      // Game Over - سيتم التعامل معها في واجهة المستخدم
    }
  }

  List<Noun> _generateImageOptions(Noun correctNoun) {
    final List<Noun> options = [correctNoun];
    final otherNouns = initialNouns
        .where((noun) => noun.id != correctNoun.id)
        .toList()
      ..shuffle();

    int count = 0;
    for (var noun in otherNouns) {
      if (count < 3) {
        options.add(noun);
        count++;
      } else {
        break;
      }
    }
    while (options.length < 4 && initialNouns.isNotEmpty) {
      final randomNoun = initialNouns[Random().nextInt(initialNouns.length)];
      if (!options.any((option) => option.id == randomNoun.id)) {
        options.add(randomNoun);
      }
    }
    return options..shuffle();
  }

  Future<void> _playAudio(Uint8List? audioBytes) async {
    if (audioBytes != null) {
      try {
        await audioPlayer.play(BytesSource(audioBytes));
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    }
  }

  Future<void> playCurrentNounAudio() async {
    if (_currentNoun?.audio != null) {
      await _playAudio(_currentNoun!.audio);
    }
  }

  Future<void> playSound(String assetPath) async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource(assetPath.replaceAll('assets/', '')));
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }

  Future<void> checkAnswer(Noun selectedNoun) async {
    _answeredQuestions++;
    _isInteractionDisabled = true;
    notifyListeners(); // إعلام الواجهة بتعطيل التفاعل

    if (_currentNoun != null && selectedNoun.id == _currentNoun!.id) {
      _isCorrect = true;
      _score++;
      playSound(AppConstants.correctAnswerSound); // Play sound immediately
      notifyListeners(); // إعلام الواجهة بالإجابة الصحيحة والنتيجة الجديدة
      await Future.delayed(const Duration(seconds: 1)); // Reduced delay
      _nextQuestion();
    } else {
      _isWrong = true;
      playSound(AppConstants.wrongAnswerSound); // Play sound immediately
      notifyListeners(); // إعلام الواجهة بالإجابة الخاطئة
      await Future.delayed(const Duration(milliseconds: 1600)); // Reduced delay
      _nextQuestion();
    }
  }

  void resetGame() {
    _score = 0;
    _answeredQuestions = 0;
    _startNewGame(); // إعادة بدء اللعبة
    notifyListeners();
  }

  void resetGameForCategory(String category) {
    if (category == 'all') {
      _nouns = List<Noun>.from(initialNouns)..shuffle();
    } else {
      _nouns = initialNouns.where((noun) => noun.category == category).toList()
        ..shuffle();
    }
    _score = 0;
    _answeredQuestions = 0;
    _totalQuestions = _nouns.length;
    _nextQuestion();
    notifyListeners();
  }
}