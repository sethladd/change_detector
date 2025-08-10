// Simple example demonstrating functions with parameters made optional
library example;

/// Second parameter made optional - MINOR change
String formatName(String firstName, [String lastName = '']) {
  return lastName.isEmpty ? firstName : '$firstName $lastName';
}

/// Required named parameter made optional - MINOR change
void sendMessage(String message, {String recipient = 'default'}) {
  // Implementation
}

/// Class with method having optional parameters
class Example {
  /// Second parameter made optional - MINOR change
  void process(String input, [int count = 1]) {
    // Implementation
  }
}
