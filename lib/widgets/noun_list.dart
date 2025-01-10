// lib/widgets/noun_list.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/noun_item.dart';

class NounList extends StatelessWidget {
  final Future<List<Noun>>? nounsFuture;
  final AudioPlayer audioPlayer;

  const NounList(
      {super.key, required this.nounsFuture, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Noun>>(
      future: nounsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No data available in this category.',
                  style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final noun = snapshot.data![index];
              return AnimatedNounCard(
                  noun: noun, audioPlayer: audioPlayer, index: index);
            },
          );
        }
      },
    );
  }
}
