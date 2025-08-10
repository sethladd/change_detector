// Simple example demonstrating members with different scopes
library example;

/// A class with static and instance members
class Utilities {
  /// A static method
  static String formatText(String text) {
    return text.trim().toUpperCase();
  }

  /// An instance method
  String transform(String input) {
    return input.toLowerCase();
  }

  /// A static field
  static int defaultTimeout = 5000;

  /// An instance field
  bool isEnabled = true;
}
