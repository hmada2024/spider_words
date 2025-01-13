// lib/widgets/adjective_card.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'dart:math';

class AnimatedAdjectiveCard extends StatefulWidget {
  final Adjective adjective;
  final AudioPlayer audioPlayer;
  final int index;

  const AnimatedAdjectiveCard({
    super.key,
    required this.adjective,
    required this.audioPlayer,
    required this.index,
  });

  @override
  State<AnimatedAdjectiveCard> createState() => _AnimatedAdjectiveCardState();
}

class _AnimatedAdjectiveCardState extends State<AnimatedAdjectiveCard>
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
          // فحص mounted فقط
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to play audio: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        // فحص mounted فقط
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio available.')),
        );
      }
    }
  }

  Widget _buildTextWithPlayButton({
    required String text,
    required Uint8List? audioBytes,
    required double fontSize,
    required double iconSize,
    required double iconSpacing,
  }) {
    List<TextSpan> formatText(String text) {
      final List<TextSpan> textSpans = [];
      final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
      int start = 0;
      for (final match in regex.allMatches(text)) {
        textSpans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
              color: Colors.black87,
              fontSize: fontSize,
            ),
          ),
        );
        textSpans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: fontSize,
            ),
          ),
        );
        start = match.end;
      }
      textSpans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: Colors.black87,
            fontSize: fontSize,
          ),
        ),
      );
      return textSpans;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.volume_up, color: Colors.blueAccent, size: iconSize),
          onPressed: () => _playAudio(audioBytes),
        ),
        SizedBox(width: iconSpacing),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: formatText(text),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = constraints.maxWidth;

            // حساب حجم الخط ديناميكيًا
            final adjectiveFontSize = max(12.0, min(maxWidth * 0.04, 18.0));
            final exampleFontSize = max(10.0, min(maxWidth * 0.035, 16.0));

            // حساب المسافات ديناميكيًا
            final horizontalPadding = max(8.0, maxWidth * 0.02);
            final verticalPadding = max(4.0, maxWidth * 0.01);
            final iconSpacing = max(4.0, maxWidth * 0.02);
            final iconSize = max(16.0, min(maxWidth * 0.06, 24.0));

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            color: Colors.blueAccent, size: iconSize),
                        onPressed: () =>
                            _playAudio(widget.adjective.mainAdjectiveAudio),
                      ),
                      SizedBox(width: iconSpacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _playAudio(widget.adjective.mainAdjectiveAudio),
                          child: Text(
                            widget.adjective.mainAdjective,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: adjectiveFontSize),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalPadding),
                  _buildTextWithPlayButton(
                    text: widget.adjective.mainExample,
                    audioBytes: widget.adjective.mainExampleAudio,
                    fontSize: exampleFontSize,
                    iconSize: iconSize,
                    iconSpacing: iconSpacing,
                  ),
                  SizedBox(height: verticalPadding * 2),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            color: Colors.blueAccent, size: iconSize),
                        onPressed: () =>
                            _playAudio(widget.adjective.reverseAdjectiveAudio),
                      ),
                      SizedBox(width: iconSpacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _playAudio(
                              widget.adjective.reverseAdjectiveAudio),
                          child: Text(
                            widget.adjective.reverseAdjective,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: adjectiveFontSize),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalPadding),
                  _buildTextWithPlayButton(
                    text: widget.adjective.reverseExample,
                    audioBytes: widget.adjective.reverseExampleAudio,
                    fontSize: exampleFontSize,
                    iconSize: iconSize,
                    iconSpacing: iconSpacing,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
