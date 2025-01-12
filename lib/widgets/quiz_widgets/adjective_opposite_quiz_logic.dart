// lib/widgets/quiz_widgets/adjective_opposite_quiz_logic.dart
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'package:spider_words/utils/app_constants.dart';

class AdjectiveOppositeQuizLogic extends ChangeNotifier {
  List<Adjective> initialAdjectives;
  final AudioPlayer audioPlayer;
  List<Adjective> _adjectives = [];
  Adjective? _currentAdjective;
  List<String> _answerOptions = [];
  bool _isCorrect = false;
  bool _isWrong = false;
  String? _selectedAnswer;
  int _score = 0;
  int _answeredQuestions = 0;
  bool _isInteractionDisabled = false;
  int _totalQuestions = 0;

  int get score => _score;
  int get answeredQuestions => _answeredQuestions;
  int get totalQuestions => _totalQuestions;
  Adjective? get currentAdjective => _currentAdjective;
  List<String> get answerOptions => _answerOptions;
  bool get isCorrect => _isCorrect;
  bool get isWrong => _isWrong;
  String? get selectedAnswer => _selectedAnswer;
  bool get isInteractionDisabled => _isInteractionDisabled;

  AdjectiveOppositeQuizLogic(
      {required this.initialAdjectives, required this.audioPlayer}) {
    _startNewQuiz();
  }

  void setTotalQuestions(int count) {
    _totalQuestions = count;
    notifyListeners();
  }

  void _startNewQuiz() {
    _adjectives = List<Adjective>.from(initialAdjectives)..shuffle();
    _totalQuestions = initialAdjectives.length;
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_adjectives.isNotEmpty) {
      _isCorrect = false;
      _isWrong = false;
      _selectedAnswer = null;
      _isInteractionDisabled = false;
      _currentAdjective = _adjectives.removeAt(0);
      _answerOptions = _generateAnswerOptions(_currentAdjective!);
      _answerOptions.shuffle();
      notifyListeners();
    } else {
      // Game Over
    }
  }

  List<String> _generateAnswerOptions(Adjective correctAdjective) {
    final List<String> options = [correctAdjective.reverseAdjective];
    final otherAdjectives = initialAdjectives
        .where((adj) => adj.id != correctAdjective.id)
        .toList()
      ..shuffle();

    int count = 0;
    for (var adj in otherAdjectives) {
      if (count < 3) {
        options.add(adj.reverseAdjective);
        count++;
      } else {
        break;
      }
    }
    while (options.length < 4 && initialAdjectives.isNotEmpty) {
      final randomAdjective =
          initialAdjectives[Random().nextInt(initialAdjectives.length)];
      if (!options.contains(randomAdjective.reverseAdjective)) {
        options.add(randomAdjective.reverseAdjective);
      }
    }
    return options..shuffle();
  }

  Future<void> playMainAdjectiveAudio() async {
    if (_currentAdjective?.mainAdjectiveAudio != null) {
      try {
        await audioPlayer
            .play(BytesSource(_currentAdjective!.mainAdjectiveAudio!));
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
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

  Future<void> checkAnswer(String selectedAdjective) async {
    _answeredQuestions++;
    _isInteractionDisabled = true;
    _selectedAnswer = selectedAdjective;
    notifyListeners();

    if (_currentAdjective != null &&
        selectedAdjective == _currentAdjective!.reverseAdjective) {
      _isCorrect = true;
      _score++;
      playSound(AppConstants.correctAnswerSound);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 3000));
      _nextQuestion();
    } else {
      _isWrong = true;
      playSound(AppConstants.wrongAnswerSound);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));
      _nextQuestion();
    }
  }

  void resetQuiz() {
    _score = 0;
    _answeredQuestions = 0;
    _startNewQuiz();
    notifyListeners();
  }

  void resetQuizForCategory(String category) {
    // لا يوجد فئات للصفات في هذا المثال
    _adjectives = List<Adjective>.from(initialAdjectives)..shuffle();
    _score = 0;
    _answeredQuestions = 0;
    _totalQuestions = _adjectives.length;
    _nextQuestion();
    notifyListeners();
  }
}
