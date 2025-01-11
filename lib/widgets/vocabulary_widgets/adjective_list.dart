// lib/widgets/adjective_list.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/adjective_model.dart';
import 'package:spider_words/widgets/vocabulary_widgets/adjective_card.dart';

class AdjectiveList extends StatelessWidget {
  final Future<List<Adjective>> adjectivesFuture;
  final AudioPlayer audioPlayer;

  const AdjectiveList(
      {super.key, required this.adjectivesFuture, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Adjective>>(
      future: adjectivesFuture,
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
              child: Text('No data available.',
                  style: TextStyle(color: Colors.white)));
        } else {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final adjective = snapshot.data![index];
                  return AnimatedAdjectiveCard(
                    adjective: adjective,
                    audioPlayer: audioPlayer,
                    index: index,
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
