// Simple example demonstrating a function with changed parameter type
library example;

/// Function now accepting only String (changed from Object) - MAJOR breaking change [Major.20]
String process(String data) {
  return data.toString();
}

/// Class with method now accepting only String - MAJOR breaking change [Major.20]
class Example {
  String handle(String input) {
    return input.toString();
  }
}
