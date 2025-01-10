// lib/pages/compound_words_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/compound_word_model.dart';
import 'package:spider_words/widgets/compound_word_card.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import '../data/database_helper.dart';

class CompoundWordsPage extends StatefulWidget {
  static const routeName = '/compound_words';

  const CompoundWordsPage({super.key});

  @override
  CompoundWordsPageState createState() => CompoundWordsPageState();
}

class CompoundWordsPageState extends State<CompoundWordsPage> {
  late Future<List<CompoundWord>> _compoundWordsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _compoundWordsFuture = DatabaseHelper().getCompoundWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Compound Words'),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            // أعد تحميل البيانات هنا
            setState(() {
              _compoundWordsFuture = DatabaseHelper().getCompoundWords();
            });
          },
          child: FutureBuilder<List<CompoundWord>>(
            future: _compoundWordsFuture,
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
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final compoundWord = snapshot.data![index];
                          return CompoundWordCard(
                            compoundWord: compoundWord,
                            audioPlayer: _audioPlayer,
                            index: index,
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
