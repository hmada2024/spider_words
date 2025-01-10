// lib/pages/matching_game_page.dart
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:spider_words/data/database_helper.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import 'package:spider_words/widgets/matching_game_content.dart';
import 'package:spider_words/widgets/matching_game_logic.dart';

class MatchingGamePage extends StatefulWidget {
  static const routeName = '/matching_game';

  const MatchingGamePage({super.key});

  @override
  State<MatchingGamePage> createState() => _MatchingGamePageState();
}

class _MatchingGamePageState extends State<MatchingGamePage> {
  late MatchingGameLogic _gameLogic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNouns();
  }

  Future<void> _loadNouns() async {
    final nouns = await DatabaseHelper().getNounsForMatchingGame();
    setState(() {
      _gameLogic = MatchingGameLogic(initialNouns: nouns);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _gameLogic.dispose();
    super.dispose();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            'Your final score is: ${_gameLogic.score} out of ${_gameLogic.totalQuestions}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _isLoading = true;
    });
    _loadNouns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Matching Game',
      ),
      body: CustomGradient(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ChangeNotifierProvider<MatchingGameLogic>.value(
                value: _gameLogic,
                child: Center(
                  child: Consumer<MatchingGameLogic>(
                    builder: (context, gameLogic, child) => MatchingGameContent(
                      currentNoun: gameLogic.currentNoun,
                      imageOptions: gameLogic.imageOptions,
                      isCorrect: gameLogic.isCorrect,
                      isWrong: gameLogic.isWrong,
                      score: gameLogic.score,
                      answeredQuestions: gameLogic.answeredQuestions,
                      totalQuestions: gameLogic.totalQuestions,
                      onOptionSelected: gameLogic.checkAnswer,
                      playCurrentNounAudio: gameLogic.playCurrentNounAudio,
                      isInteractionDisabled:
                          gameLogic.isInteractionDisabled, // تمرير الخاصية هنا
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGameOverDialog,
        tooltip: 'Show Game Over',
        child: const Icon(Icons.flag),
      ),
    );
  }
}
