// lib/pages/vocabulary_pages/nouns_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/common_widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/common_widgets/custom_gradient.dart';
import 'package:spider_words/widgets/vocabulary_widgets/noun_list.dart';
import '../../main.dart';
import 'package:spider_words/widgets/common_widgets/category_filter_widget.dart'; // استيراد الودجت الجديد

// Provider to fetch nouns by category
final nounsByCategoryProvider =
    FutureProvider.family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  if (category == 'all') {
    return dbHelper.getNouns();
  } else {
    return dbHelper.getNounsByCategory(category);
  }
});

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final nounsAsyncValue =
        ref.watch(nounsByCategoryProvider(selectedCategory));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns',
        actions: [
          _buildCategoryFilterDropdown(), // استخدام الودجت الجديد
        ],
      ),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nounsByCategoryProvider(selectedCategory));
            await ref.read(nounsByCategoryProvider(selectedCategory).future);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    selectedCategory == 'all'
                        ? 'All Categories'
                        : _formatCategoryName(selectedCategory),
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
                      child: Text('Error: $error',
                          style: const TextStyle(color: Colors.white))),
                  data: (nouns) => NounList(
                      nounsFuture: Future.value(nouns),
                      audioPlayer: _audioPlayer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterDropdown() {
    return FutureBuilder<List<String>>(
      future: ref
          .read(databaseHelperProvider)
          .getNouns()
          .then((nouns) => nouns.map((noun) => noun.category).toSet().toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading categories: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No categories available.');
        } else {
          final categories = ['all', ...snapshot.data!];
          return CategoryFilterDropdown(
            // استخدام الودجت المفصول
            categories: categories,
            selectedCategory: ref.watch(selectedCategoryProvider),
            onCategoryChanged: (newValue) {
              ref.read(selectedCategoryProvider.notifier).state = newValue!;
            },
          );
        }
      },
    );
  }
}
