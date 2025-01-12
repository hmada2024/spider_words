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
  List<Adjective> _adjectives = []; // قائمة الصفات المتبقية للاختبار
  Adjective? _currentAdjective; // الصفة الحالية التي يتم عرضها في السؤال
  List<String> _answerOptions = []; // قائمة خيارات الإجابة (متضادات الصفات)
  bool _isCorrect = false; // يشير إلى ما إذا كانت الإجابة صحيحة
  bool _isWrong = false; // يشير إلى ما إذا كانت الإجابة خاطئة
  String? _selectedAnswer; // الإجابة التي اختارها المستخدم
  int _score = 0; // عدد الإجابات الصحيحة
  int _answeredQuestions = 0; // عدد الأسئلة التي تمت الإجابة عليها
  bool _isInteractionDisabled = false; // تعطيل التفاعل أثناء معالجة الإجابة
  int _totalQuestions = 0; // العدد الكلي للأسئلة في الاختبار

  // Getters للوصول إلى قيم الحالة
  int get score => _score;
  int get answeredQuestions => _answeredQuestions;
  int get totalQuestions => _totalQuestions;
  Adjective? get currentAdjective => _currentAdjective;
  List<String> get answerOptions => _answerOptions;
  bool get isCorrect => _isCorrect;
  bool get isWrong => _isWrong;
  String? get selectedAnswer => _selectedAnswer;
  bool get isInteractionDisabled => _isInteractionDisabled;

  // Constructor يستقبل قائمة الصفات الأولية ومشغل الصوت
  AdjectiveOppositeQuizLogic(
      {required this.initialAdjectives, required this.audioPlayer}) {
    _startNewQuiz(); // بدء اختبار جديد عند إنشاء مدير الحالة
  }

  // تحديث العدد الكلي للأسئلة (يمكن استخدامه إذا كانت القائمة تتغير)
  void setTotalQuestions(int count) {
    _totalQuestions = count;
    notifyListeners();
  }

  // بدء اختبار جديد
  void _startNewQuiz() {
    _adjectives = List<Adjective>.from(initialAdjectives)
      ..shuffle(); // نسخ الصفات وعمل خلط عشوائي
    _totalQuestions = initialAdjectives.length; // تحديد العدد الكلي للأسئلة
    _nextQuestion(); // الانتقال إلى السؤال الأول
  }

  // الانتقال إلى السؤال التالي
  void _nextQuestion() {
    if (_adjectives.isNotEmpty) {
      // تهيئة قيم الحالة للسؤال الجديد
      _isCorrect = false;
      _isWrong = false;
      _selectedAnswer = null;
      _isInteractionDisabled = false;
      _currentAdjective =
          _adjectives.removeAt(0); // اختيار الصفة التالية وإزالتها من القائمة
      _answerOptions =
          _generateAnswerOptions(_currentAdjective!); // إنشاء خيارات الإجابة
      _answerOptions.shuffle(); // عمل خلط عشوائي لخيارات الإجابة
      notifyListeners(); // إعلام المستمعين بالتغييرات في الحالة
    } else {
      // تم الانتهاء من جميع الأسئلة (يمكن إضافة منطق هنا لنهاية الاختبار)
    }
  }

  // إنشاء قائمة خيارات الإجابة (المتضادات)
  List<String> _generateAnswerOptions(Adjective correctAdjective) {
    final List<String> options = [
      correctAdjective.reverseAdjective
    ]; // إضافة المتضاد الصحيح كخيار أول
    final otherAdjectives = initialAdjectives
        .where((adj) => adj.id != correctAdjective.id) // استبعاد الصفة الحالية
        .toList()
      ..shuffle(); // عمل خلط عشوائي للصفات الأخرى

    int count = 0;
    // إضافة 3 متضادات خاطئة بشكل عشوائي
    for (var adj in otherAdjectives) {
      if (count < 3) {
        options.add(adj.reverseAdjective);
        count++;
      } else {
        break;
      }
    }
    // التأكد من وجود 4 خيارات حتى لو لم يكن هناك enough صفات أخرى
    while (options.length < 4 && initialAdjectives.isNotEmpty) {
      final randomAdjective =
          initialAdjectives[Random().nextInt(initialAdjectives.length)];
      if (!options.contains(randomAdjective.reverseAdjective)) {
        options.add(randomAdjective.reverseAdjective);
      }
    }
    return options..shuffle(); // إعادة الخيارات بعد عمل خلط عشوائي
  }

  // تشغيل صوت الصفة الرئيسية
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

  // تشغيل مؤثر صوتي (صحيح أو خطأ)
  Future<void> playSound(String assetPath) async {
    try {
      await audioPlayer.stop(); // إيقاف أي صوت قيد التشغيل حاليًا
      await audioPlayer.play(AssetSource(
          assetPath.replaceAll('assets/', ''))); // تشغيل الصوت المطلوب
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }

  // فحص الإجابة التي اختارها المستخدم
  Future<void> checkAnswer(String selectedAdjective) async {
    _answeredQuestions++; // زيادة عدد الأسئلة التي تمت الإجابة عليها
    _isInteractionDisabled =
        true; // تعطيل التفاعل لمنع المستخدم من تغيير الإجابة
    _selectedAnswer = selectedAdjective; // تسجيل الإجابة التي اختارها المستخدم
    notifyListeners(); // إعلام المستمعين بتغيير الحالة

    // التحقق إذا كانت الإجابة صحيحة
    if (_currentAdjective != null &&
        selectedAdjective == _currentAdjective!.reverseAdjective) {
      _isCorrect = true; // تعيين حالة الإجابة إلى صحيحة
      _score++; // زيادة النتيجة
      playSound(AppConstants.correctAnswerSound); // تشغيل صوت الإجابة الصحيحة
      notifyListeners(); // إعلام المستمعين بالتغييرات
      await Future.delayed(const Duration(
          milliseconds: 3000)); // فترة انتظار قصيرة قبل الانتقال للسؤال التالي
      _nextQuestion(); // الانتقال إلى السؤال التالي
    } else {
      // الإجابة خاطئة
      _isWrong = true; // تعيين حالة الإجابة إلى خاطئة
      playSound(AppConstants.wrongAnswerSound); // تشغيل صوت الإجابة الخاطئة
      notifyListeners(); // إعلام المستمعين بالتغييرات
      await Future.delayed(const Duration(
          milliseconds: 1200)); // فترة انتظار أقصر للإجابة الخاطئة
      _nextQuestion(); // الانتقال إلى السؤال التالي
    }
  }

  // إعادة تعيين الاختبار
  void resetQuiz() {
    _score = 0;
    _answeredQuestions = 0;
    _startNewQuiz();
    notifyListeners();
  }

  // إعادة تعيين الاختبار لفئة معينة (في هذا المثال، يتم التعامل مع جميع الصفات)
  void resetQuizForCategory(String category) {
    // لا يوجد فئات للصفات في هذا المثال، لذلك يتم إعادة تعيين الاختبار باستخدام جميع الصفات
    _adjectives = List<Adjective>.from(initialAdjectives)..shuffle();
    _score = 0;
    _answeredQuestions = 0;
    _totalQuestions = _adjectives.length;
    _nextQuestion();
    notifyListeners();
  }
}
