// pages/adjectives_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/widgets/adjective_list.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import '../data/database_helper.dart';
import '../models/adjective_model.dart';

class AdjectivesPage extends StatefulWidget {
  static const routeName = '/adjectives';

  const AdjectivesPage({super.key});

  @override
  AdjectivesPageState createState() => AdjectivesPageState();
}

class AdjectivesPageState extends State<AdjectivesPage> {
  late Future<List<Adjective>> _adjectivesFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _adjectivesFuture = DatabaseHelper().getAdjectives();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Adjectives'),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _adjectivesFuture = DatabaseHelper().getAdjectives();
            });
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return AdjectiveList(
                adjectivesFuture: _adjectivesFuture,
                audioPlayer: _audioPlayer,
              );
            },
          ),
        ),
      ),
    );
  }
}
