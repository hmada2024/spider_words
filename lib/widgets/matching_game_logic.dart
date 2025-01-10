// lib/logic/matching_game_logic.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/utils/app_constants.dart';

class MatchingGameLogic with ChangeNotifier {
  final List<Noun> initialNouns;
  List<Noun> _nouns = [];
  Noun? _currentNoun;
  List<Noun> _imageOptions = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isCorrect = false;
  bool _isWrong = false;
  int _score = 0;
  int _answeredQuestions = 0;
  bool _isInteractionDisabled = false;

  int get score => _score;
  int get answeredQuestions => _answeredQuestions;
  int get totalQuestions => initialNouns.length;
  Noun? get currentNoun => _currentNoun;
  List<Noun> get imageOptions => _imageOptions;
  bool get isCorrect => _isCorrect;
  bool get isWrong => _isWrong;
  bool get isInteractionDisabled => _isInteractionDisabled;

  MatchingGameLogic({required this.initialNouns}) {
    _nouns = List<Noun>.from(initialNouns)..shuffle();
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_nouns.isNotEmpty) {
      _isCorrect = false;
      _isWrong = false;
      _isInteractionDisabled = false; // Enable interaction for the new question
      _currentNoun = _nouns.removeAt(0);
      _imageOptions = _generateImageOptions(_currentNoun!);
      _imageOptions.shuffle();
      playCurrentNounAudio();
      if (!disposed) {
        notifyListeners(); // Ensure it's not disposed before notifying listeners
      }
    } else {
      // Game Over - يتم التعامل معها في واجهة المستخدم
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
    // التأكد من وجود 4 خيارات حتى لو لم تكن فريدة تمامًا
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
        await _audioPlayer.play(BytesSource(audioBytes));
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
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource(assetPath.replaceAll('assets/', '')));
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }

  Future<void> checkAnswer(Noun selectedNoun) async {
    _answeredQuestions++;
    _isInteractionDisabled = true; // Disable interaction immediately
    // notifyListeners(); // نقل هذا السطر

    if (_currentNoun != null && selectedNoun.id == _currentNoun!.id) {
      _isCorrect = true;
      _score++; // تحديث النتيجة هنا
      if (!disposed) {
        notifyListeners(); // ثم إعلام الواجهة بالتغيير
      }
      await playSound(AppConstants.correctAnswerSound); // Play correct sound
      await Future.delayed(const Duration(seconds: 2));
      _nextQuestion();
    } else {
      _isWrong = true;
      if (!disposed) {
        notifyListeners(); // Update UI to show the wrong answer
      }
      await playSound(AppConstants.wrongAnswerSound); // Play wrong sound
      await Future.delayed(const Duration(seconds: 2));
      _nextQuestion();
    }
  }

  void resetGame() {
    _score = 0;
    _answeredQuestions = 0;
    _nouns = List<Noun>.from(initialNouns)..shuffle();
    _nextQuestion();
    if (!disposed) {
      notifyListeners();
    }
  }

  bool disposed = false; // Track if this class has been disposed

  @override
  void dispose() {
    disposed = true; // Mark as disposed before calling super.dispose()
    _audioPlayer.dispose();
    super.dispose();
  }
}
