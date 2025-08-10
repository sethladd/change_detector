// Simple example demonstrating a function with added required parameter
library example;

/// Function with added required parameter - MAJOR breaking change
String greet(String name, int age) {
  return 'Hello, $name! You are $age years old.';
}

/// Class with method having added required parameter
class Example {
  /// Method with added required parameter - MAJOR breaking change
  String process(String input, bool uppercase) {
    return uppercase ? input.toUpperCase() : input;
  }
}
