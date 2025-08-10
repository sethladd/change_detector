// Simple example demonstrating members with changed scopes
library example;

/// A class with changed member scopes
class Utilities {
  /// Changed from static to instance - MAJOR breaking change
  String formatText(String text) {
    return text.trim().toUpperCase();
  }

  /// Changed from instance to static - MAJOR breaking change
  static String transform(String input) {
    return input.toLowerCase();
  }

  /// Changed from static to instance - MAJOR breaking change
  int defaultTimeout = 5000;

  /// Changed from instance to static - MAJOR breaking change
  static bool isEnabled = true;
}
