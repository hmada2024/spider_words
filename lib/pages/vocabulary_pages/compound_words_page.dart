// lib/pages/vocabulary_pages/compound_words_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/compound_word_model.dart';
import 'package:spider_words/widgets/vocabulary_widgets/compound_word_card.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import '../../main.dart';

// Provider to fetch compound words
final compoundWordsProvider =
    FutureProvider.autoDispose<List<CompoundWord>>((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return dbHelper.getCompoundWords();
});

class CompoundWordsPage extends ConsumerStatefulWidget {
  static const routeName = '/compound_words';

  const CompoundWordsPage({super.key});

  @override
  CompoundWordsPageState createState() => CompoundWordsPageState();
}

class CompoundWordsPageState extends ConsumerState<CompoundWordsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compoundWordsAsyncValue = ref.watch(compoundWordsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Compound Words'),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger a refetch by invalidating the provider
            ref.invalidate(compoundWordsProvider);
            await ref.read(compoundWordsProvider.future);
          },
          child: compoundWordsAsyncValue.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white)),
            error: (error, stackTrace) => Center(
                child: Text('Error: $error',
                    style: const TextStyle(color: Colors.white))),
            data: (compoundWords) => CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final compoundWord = compoundWords[index];
                      return CompoundWordCard(
                        compoundWord: compoundWord,
                        audioPlayer: _audioPlayer,
                        index: index,
                      );
                    },
                    childCount: compoundWords.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
