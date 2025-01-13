// lib/widgets/compound_word_card.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/compound_word_model.dart';
import 'dart:math';

class CompoundWordCard extends StatefulWidget {
  final CompoundWord compoundWord;
  final AudioPlayer audioPlayer;
  final int index;

  const CompoundWordCard({
    super.key,
    required this.compoundWord,
    required this.audioPlayer,
    required this.index,
  });

  @override
  State<CompoundWordCard> createState() => _CompoundWordCardState();
}

class _CompoundWordCardState extends State<CompoundWordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // تأخير بدء الأنيميشن بناءً على index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAudio(Uint8List? audioBytes) async {
    if (audioBytes != null) {
      try {
        await widget.audioPlayer.play(BytesSource(audioBytes));
      } catch (e) {
        debugPrint('Error playing audio: $e');
        if (mounted) {
          // فحص إذا كان الـ Widget لا يزال mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to play audio: $e'),
                backgroundColor: Colors.red.shade400),
          );
        }
      }
    } else {
      if (mounted) {
        // فحص إذا كان الـ Widget لا يزال mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No audio available.'),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = max(8.0, screenWidth * 0.02);
    final verticalPadding = max(4.0, screenWidth * 0.01);
    final iconSize = max(16.0, min(screenWidth * 0.06, 24.0));
    final iconSpacing = max(4.0, screenWidth * 0.01);
    final fontSize = max(12.0, min(screenWidth * 0.04, 18.0));

    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // الكلمة المركبة
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up,
                        color: const Color.fromARGB(255, 1, 84, 4),
                        size: iconSize),
                    onPressed: () => _playAudio(widget.compoundWord.mainAudio),
                  ),
                  SizedBox(width: iconSpacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _playAudio(widget.compoundWord.mainAudio),
                      child: Text(
                        widget.compoundWord.main,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: verticalPadding), // مسافة فاصلة بين الكلمة والمثال
              if (widget.compoundWord.example != null) ...[
                Row(
                  // مثال الكلمة المركبة
                  children: [
                    IconButton(
                      icon: Icon(Icons.volume_up,
                          color: const Color.fromARGB(255, 180, 4, 24),
                          size: iconSize),
                      onPressed: () =>
                          _playAudio(widget.compoundWord.mainExampleAudio),
                    ),
                    SizedBox(width: iconSpacing),
                    Expanded(
                      child: Text(
                        widget.compoundWord.example!,
                        style: TextStyle(
                            fontSize: fontSize, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
