// Simple example demonstrating typedefs with incompatible changes
library example;

/// Changed from String Function(String) to int Function(String) - MAJOR breaking change [Major.10]
typedef StringProcessor = int Function(String input);

/// Changed from Map<String, dynamic> to Map<String, String> - MAJOR breaking change [Major.10]
typedef JsonMap = Map<String, String>;

/// A class using the typedefs
class Processor {
  /// This method now expects a function that returns int, not String
  int process(String input, StringProcessor processor) {
    return processor(input);
  }
  
  /// This method now expects a map with string values only
  void handleData(JsonMap data) {
    data.forEach((key, value) {
      print('$key: $value');
    });
  }
}
