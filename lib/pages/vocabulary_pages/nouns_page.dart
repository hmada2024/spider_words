// lib/pages/vocabulary_pages/nouns_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/vocabulary_widgets/noun_list.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart';
import 'package:spider_words/utils/string_formatter.dart';
import 'package:spider_words/providers/noun_provider.dart';

// Provider for the selected category
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

class NounsPage extends ConsumerStatefulWidget {
  static const routeName = '/nouns';

  const NounsPage({super.key});

  @override
  NounsPageState createState() => NounsPageState();
}

class NounsPageState extends ConsumerState<NounsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final nounsAsyncValue = ref.watch(nounsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns',
        actions: [
          _buildCategoryFilterDropdown(),
        ],
      ),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nounsProvider);
            await ref.read(nounsProvider.future);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    selectedCategory == 'all'
                        ? 'All Categories'
                        : StringFormatter.formatFieldName(selectedCategory),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: nounsAsyncValue.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load nouns: $error', // رسالة خطأ مفصلة
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(
                                nounsProvider); // إعادة محاولة التحميل
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (nouns) {
                    final filteredNouns = selectedCategory == 'all'
                        ? nouns
                        : nouns
                            .where((noun) => noun.category == selectedCategory)
                            .toList();
                    return NounList(
                      nounsFuture: Future.value(filteredNouns),
                      audioPlayer: _audioPlayer,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterDropdown() {
    return Consumer(
      builder: (context, ref, _) {
        final nounsAsyncValue = ref.watch(nounsProvider);
        return nounsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Text('Error loading categories: $error'),
          data: (nouns) {
            final categories = [
              'all',
              ...nouns.map((noun) => noun.category).toSet()
            ];
            return CategoryFilterDropdown(
              categories: categories.toList(), // Added toList() here
              selectedCategory: ref.watch(selectedCategoryProvider),
              onCategoryChanged: (newValue) {
                if (newValue != null) {
                  ref.read(selectedCategoryProvider.notifier).state = newValue;
                }
              },
            );
          },
        );
      },
    );
  }
}
