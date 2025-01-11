// lib/widgets/quiz_widgets/nouns_matching_quiz_logic.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';

class NounsMatchingQuizLogic extends ChangeNotifier {
  List<Noun> initialNouns;
  final AudioPlayer audioPlayer;
  List<Noun> _nouns = [];
  Noun? _currentNoun;
  List<Noun> _answerOptions = [];
  bool _isCorrect = false;
  bool _isWrong = false;
  int _score = 0;
  int _answeredQuestions = 0;
  bool _isInteractionDisabled = false;
  int _totalQuestions = 0;

  int get score => _score;
  int get answeredQuestions => _answeredQuestions;
  int get totalQuestions => _totalQuestions;
  Noun? get currentNoun => _currentNoun;
  List<Noun> get answerOptions => _answerOptions;
  bool get isCorrect => _isCorrect;
  bool get isWrong => _isWrong;
  bool get isInteractionDisabled => _isInteractionDisabled;

  NounsMatchingQuizLogic(
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
      _answerOptions = _generateAnswerOptions(_currentNoun!);
      _answerOptions.shuffle();
      notifyListeners();
    } else {
      // Game Over
    }
  }

  List<Noun> _generateAnswerOptions(Noun correctNoun) {
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
    notifyListeners();

    if (_currentNoun != null && selectedNoun.id == _currentNoun!.id) {
      _isCorrect = true;
      _score++;
      playSound(AppConstants.correctAnswerSound);
      if (_currentNoun?.audio != null) {
        await _playAudio(_currentNoun!.audio);
      }
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      _nextQuestion();
    } else {
      _isWrong = true;
      playSound(AppConstants.wrongAnswerSound);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1600));
      _nextQuestion();
    }
  }

  void resetGame() {
    _score = 0;
    _answeredQuestions = 0;
    _startNewGame();
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
