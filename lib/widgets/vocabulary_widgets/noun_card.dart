// lib/widgets/noun_card.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/nouns_model.dart';

class NounCard extends StatefulWidget {
  final Noun noun;
  final AudioPlayer audioPlayer;
  final int index;

  const NounCard({
    super.key,
    required this.noun,
    required this.audioPlayer,
    required this.index,
  });

  @override
  State<NounCard> createState() => _NounCardState();
}

class _NounCardState extends State<NounCard>
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to play audio: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio available.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final imageSide = screenWidth * 0.75; // 75% of screen width
    final iconSize = imageSide * 0.08;
    final fontSize = imageSide * 0.05;

    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _playAudio(widget.noun.audio),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: imageSide,
                    height: imageSide,
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        widget.noun.image != null
                            ? Image.memory(
                                widget.noun.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      'Error loading image for ${widget.noun.name}: $error');
                                  return Icon(
                                    Icons.image, // أيقونة صورة
                                    size: 100, // حجم الأيقونة
                                    color: Colors.grey, // لون الأيقونة
                                  );
                                },
                              )
                            : Icon(
                                Icons.image, // أيقونة صورة
                                size: 100, // حجم الأيقونة
                                color: Colors.grey, // لون الأيقونة
                              ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.volume_up,
                            color: Colors.blue.shade700,
                            size: iconSize,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                widget.noun.name,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}
