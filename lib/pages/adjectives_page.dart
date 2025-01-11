// pages/adjectives_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/adjective_list.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import '../main.dart';
import '../models/adjective_model.dart';

// Provider to fetch adjectives
final adjectivesProvider =
    FutureProvider.autoDispose<List<Adjective>>((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return dbHelper.getAdjectives();
});

class AdjectivesPage extends ConsumerStatefulWidget {
  static const routeName = '/adjectives';

  const AdjectivesPage({super.key});

  @override
  AdjectivesPageState createState() => AdjectivesPageState();
}

class AdjectivesPageState extends ConsumerState<AdjectivesPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adjectivesAsyncValue = ref.watch(adjectivesProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Adjectives'),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger a refetch by invalidating the provider
            ref.invalidate(adjectivesProvider);
            await ref.read(adjectivesProvider.future);
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return adjectivesAsyncValue.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (error, stackTrace) => Center(
                    child: Text('Error: $error',
                        style: const TextStyle(color: Colors.white))),
                data: (adjectives) => AdjectiveList(
                  adjectivesFuture: Future.value(adjectives),
                  audioPlayer: _audioPlayer,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
