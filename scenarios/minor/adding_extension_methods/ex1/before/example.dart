// Simple example demonstrating extensions that will have new methods added
library example;

/// An extension on String
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isNullOrEmpty => isEmpty;
}

/// An extension on int
extension IntExtension on int {
  bool isTheAnswer() => this == 42;
}

/// Usage example
void main() {
  final name = 'alice';
  print(name.capitalize()); // "Alice"
  print(name.isNullOrEmpty); // false

  final number = 42;
  print(number.isTheAnswer()); // true
}
