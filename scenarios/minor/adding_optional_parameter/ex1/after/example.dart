// Simple example demonstrating function with added optional parameter
library example;

/// Simple function with added optional parameter - MINOR change
String greet(String name, {bool formal = false}) {
  return formal ? 'Greetings, $name.' : 'Hello, $name!';
}

/// Class with a simple method with added optional parameter
class Example {
  /// Method with added optional parameter - MINOR change
  String process(String input, {bool uppercase = false}) {
    return uppercase ? input.toUpperCase() : input;
  }
}
