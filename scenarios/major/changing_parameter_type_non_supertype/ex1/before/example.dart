// Simple example demonstrating a function with Object parameter
library example;

/// Function accepting any Object
String process(Object data) {
  return data.toString();
}

/// Class with method accepting any Object
class Example {
  String handle(Object input) {
    return input.toString();
  }
}
