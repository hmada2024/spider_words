// lib/utils/string_formatter.dart
class StringFormatter {
  static String formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ') // استبدال الشرطة السفلية بمسافة
        .replaceAll('-', ' ') // استبدال الشرطة العلوية بمسافة
        .split(' ')
        .map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return '';
    }).join(' ');
  }
}
