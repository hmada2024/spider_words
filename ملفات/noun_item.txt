// lib/widgets/noun_item.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'dart:math';

class AnimatedNounCard extends StatefulWidget {
  final Noun noun;
  final AudioPlayer audioPlayer;
  final int index;

  const AnimatedNounCard({
    super.key,
    required this.noun,
    required this.audioPlayer,
    required this.index,
  });

  @override
  State<AnimatedNounCard> createState() => _AnimatedNounCardState();
}

class _AnimatedNounCardState extends State<AnimatedNounCard>
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

  Future<void> _playAudio(BuildContext context, Uint8List? audioBytes) async {
    if (audioBytes != null) {
      await widget.audioPlayer.play(BytesSource(audioBytes));
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
    final cardWidth = screenWidth * 0.9; // عرض البطاقة
    final horizontalMargin = cardWidth * 0.04; // الهامش الأفقي
    final imageWidth = cardWidth - (horizontalMargin * 2); // عرض الصورة
    final imageHeight = imageWidth; // ارتفاع الصورة
    final iconSize = max(16.0, min(imageWidth * 0.08, 24.0)); // حجم الأيقونة
    final fontSize = max(14.0, min(imageWidth * 0.07, 20.0)); // حجم الخط

    return SlideTransition(
      position: _offsetAnimation, // حركة الدخول
      child: Container(
        width: cardWidth, // عرض البطاقة
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: 10), // الهوامش
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // حواف دائرية
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38), // ظل خفيف
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // الصورة مع الكلمة والأيقونة
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // حواف دائرية للقص
              child: Container(
                width: imageWidth, // عرض الصورة
                height: imageHeight, // ارتفاع الصورة
                margin: EdgeInsets.all(horizontalMargin), // هوامش للصورة
                child: Stack(
                  children: [
                    Positioned.fill(
                      //  استخدام Positioned.fill
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20), //  // حواف دائرية للصورة
                        child: widget.noun.image != null
                            ? Image.memory(widget.noun.image!,
                                fit: BoxFit.cover) // الصورة
                            : Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey)),
                      ),
                    ),
                    Positioned(
                      // موضع  الكلمة والأيقونة
                      bottom: 10, // المسافة من أسفل الصورة
                      left: 0, // محاذاة لليسار
                      right: 0, // محاذاة لليمين
                      child: Center(
                        // توسيط العناصر
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4), // هوامش
                          decoration: BoxDecoration(
                            color: Colors.black54, // خلفية نصف شفافة
                            borderRadius:
                                BorderRadius.circular(10), // حواف دائرية
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // عرض الرو
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _playAudio(context, widget.noun.audio),
                                child: Text(
                                  // اسم الكلمة
                                  widget.noun.name,
                                  style: TextStyle(
                                    fontSize: fontSize, // حجم الخط
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: 8), // مسافة بين الكلمة والأيقونة
                              GestureDetector(
                                // كاشف الضغط
                                onTap: () =>
                                    _playAudio(context, widget.noun.audio),
                                child: Icon(Icons.volume_up,
                                    color: Colors.white,
                                    size: iconSize), // حجم الأيقونة
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
                height: 1), // مسافة بين الصورة والهامش السفلي للبطاقة
          ],
        ),
      ),
    );
  }
}
