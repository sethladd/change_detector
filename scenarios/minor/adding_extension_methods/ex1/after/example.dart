// Simple example demonstrating extensions with added methods
library example;

/// An extension on String with added methods - MINOR changes
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isNullOrEmpty => isEmpty;

  // Added new method - MINOR change
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  // Added new getter - MINOR change
  bool get isEmail => contains('@') && contains('.');

  // Added new setter - MINOR change
  set debugName(String name) {
    print('Debug: $name = $this');
  }

  // Added static method - MINOR change
  static String join(List<String> strings, String separator) {
    return strings.join(separator);
  }
}

/// An extension on int with added methods
extension IntExtension on int {
  bool isTheAnswer() => this == 42;

  // Added new method - MINOR change
  int squared() => this * this;

  // Added new getter - MINOR change
  bool get isPositive => this > 0;
}

/// Usage example
void main() {
  final name = 'alice smith with a very long name';
  print(name.capitalize()); // "Alice smith with a very long name"
  print(name.isNullOrEmpty); // false
  print(name.truncate(10)); // "alice smit..."
  print(name.isEmail); // false
  name.debugName = 'userName';

  final emails = ['user1@example.com', 'user2@example.com'];
  print(StringExtension.join(emails, ', ')); // Using static method

  final number = 42;
  print(number.isTheAnswer()); // true
  print(number.squared()); // 1764
  print(number.isPositive); // true
}
