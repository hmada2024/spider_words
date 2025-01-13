// lib/widgets/common_widgets/category_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_words/utils/string_formatter.dart'; // استيراد ملف التنسيق

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        tooltip: 'Filter Categories',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(
                      category == 'all'
                          ? 'All Categories'
                          : StringFormatter.formatFieldName(
                              category), // استخدام دالة التنسيق
                    ),
                    onTap: () {
                      onCategoryChanged(category);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
