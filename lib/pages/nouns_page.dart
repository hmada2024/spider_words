// pages/nouns_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spider_words/models/nouns_model.dart';
import 'package:spider_words/widgets/custom_app_bar.dart';
import 'package:spider_words/widgets/custom_gradient.dart';
import 'package:spider_words/widgets/noun_list.dart';
import '../data/database_helper.dart';

class NounsPage extends StatefulWidget {
  static const routeName = '/nouns';

  const NounsPage({super.key});

  @override
  NounsPageState createState() => NounsPageState();
}

class NounsPageState extends State<NounsPage> {
  Future<List<Noun>>? _nounsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedCategory;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
    _categoriesFuture.then((categories) {
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first;
          _nounsFuture = _fetchNounsByCategory(_selectedCategory!);
        });
      }
    });
  }

  Future<List<String>> _loadCategories() async {
    final nouns = await DatabaseHelper().getNouns();
    return nouns.map((noun) => noun.category).toSet().toList();
  }

  Future<List<Noun>> _fetchNounsByCategory(String category) async {
    return await DatabaseHelper().getNounsByCategory(category);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (_selectedCategory != null) {
              setState(() {
                _nounsFuture = _fetchNounsByCategory(_selectedCategory!);
              });
            }
          },
          child: NounList(nounsFuture: _nounsFuture, audioPlayer: _audioPlayer),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownIconSize = max(18.0, min(screenWidth * 0.05, 24.0));

    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading categories: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No categories available.');
        } else {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0), // هامش أيمن
            child: DropdownButton<String>(
              value: _selectedCategory,
              underline: Container(), // إزالة الخط السفلي
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white, size: dropdownIconSize),
              dropdownColor: Colors.blueAccent, // لون خلفية القائمة
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold), // نمط نص القائمة
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    _nounsFuture = _fetchNounsByCategory(_selectedCategory!);
                  });
                }
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
