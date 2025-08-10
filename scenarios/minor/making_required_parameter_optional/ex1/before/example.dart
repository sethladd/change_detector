// Simple example demonstrating functions with required parameters
library example;

/// Function with required positional parameters
String formatName(String firstName, String lastName) {
  return '$firstName $lastName';
}

/// Function with required named parameter
void sendMessage(String message, {required String recipient}) {
  // Implementation
}

/// Class with method having required parameters
class Example {
  /// Method with required parameters
  void process(String input, int count) {
    // Implementation
  }
}
