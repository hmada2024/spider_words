// pages/nouns_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import 'package:spider_words/widgets/noun_list.dart';
import '../main.dart';

// Provider to fetch nouns by category
final nounsByCategoryProvider =
    FutureProvider.family<List<Noun>, String>((ref, category) async {
  final dbHelper = ref.read(databaseHelperProvider);
  return dbHelper.getNounsByCategory(category);
});

// Provider for the selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

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
    _loadInitialCategory();
  }

  Future<void> _loadInitialCategory() async {
    final categories = await _fetchCategories();
    if (categories.isNotEmpty) {
      ref.read(selectedCategoryProvider.notifier).state = categories.first;
    }
  }

  Future<List<String>> _fetchCategories() async {
    final nouns = await ref.read(databaseHelperProvider).getNouns();
    return nouns.map((noun) => noun.category).toSet().toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final nounsAsyncValue =
        ref.watch(nounsByCategoryProvider(selectedCategory ?? ''));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouns',
        actions: [
          _buildCategoryDropdown(),
        ],
      ),
      body: CustomGradient(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger a refetch by invalidating the provider
            if (selectedCategory != null) {
              ref.invalidate(nounsByCategoryProvider(selectedCategory));
              await ref.read(nounsByCategoryProvider(selectedCategory).future);
            }
          },
          child: nounsAsyncValue.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white)),
            error: (error, stackTrace) => Center(
                child: Text('Error: $error',
                    style: const TextStyle(color: Colors.white))),
            data: (nouns) => NounList(
                nounsFuture: Future.value(nouns), audioPlayer: _audioPlayer),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownIconSize = max(18.0, min(screenWidth * 0.05, 24.0));

    return FutureBuilder<List<String>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading categories: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No categories available.');
        } else {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: ref.watch(selectedCategoryProvider),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                ref.read(selectedCategoryProvider.notifier).state = newValue;
              },
              items:
                  snapshot.data!.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
