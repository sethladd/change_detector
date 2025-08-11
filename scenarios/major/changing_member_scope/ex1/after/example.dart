// Simple example demonstrating members with changed scopes
library example;

/// A class with changed member scopes
class Utilities {
  /// Changed from static to instance - MAJOR breaking change [Major.13]
  String formatText(String text) {
    return text.trim().toUpperCase();
  }

  /// Changed from instance to static - MAJOR breaking change [Major.13]
  static String transform(String input) {
    return input.toLowerCase();
  }

  /// Changed from static to instance - MAJOR breaking change [Major.13]
  int defaultTimeout = 5000;

  /// Changed from instance to static - MAJOR breaking change [Major.13]
  static bool isEnabled = true;
}
