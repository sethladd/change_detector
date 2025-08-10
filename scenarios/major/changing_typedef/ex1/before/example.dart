// Simple example demonstrating typedefs
library example;

/// A typedef for a function that processes a string
typedef StringProcessor = String Function(String input);

/// A typedef for a map with string keys and dynamic values
typedef JsonMap = Map<String, dynamic>;

/// A class using the typedefs
class Processor {
  /// Method that takes a StringProcessor function
  String process(String input, StringProcessor processor) {
    return processor(input);
  }
  
  /// Method that takes a JsonMap
  void handleData(JsonMap data) {
    data.forEach((key, value) {
      print('$key: $value');
    });
  }
}
