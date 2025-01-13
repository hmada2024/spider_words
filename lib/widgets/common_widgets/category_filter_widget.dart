// lib/widgets/common_widgets/category_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryFilterDropdown extends ConsumerWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const CategoryFilterDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButton<String>(
        value: selectedCategory,
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: Colors.blueAccent,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        onChanged: onCategoryChanged,
        items: categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
                value == 'all' ? 'All Categories' : _formatCategoryName(value)),
          );
        }).toList(),
      ),
    );
  }
}
