// lib/pages/vocabulary_pages/adjectives_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/vocabulary_widgets/adjective_list.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/providers/adjective_provider.dart';

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
            ref.invalidate(adjectivesProvider);
            await ref.read(adjectivesProvider.future);
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return adjectivesAsyncValue.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Failed to load adjectives: $error', // رسالة خطأ مفصلة
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(
                              adjectivesProvider); // إعادة محاولة التحميل
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
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
