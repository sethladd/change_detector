// Simple example demonstrating an extension with a changed, more restrictive target type
library example;

/// Extension target changed from Object to String - MAJOR breaking change
extension ObjectExtension on String {
  String describe() {
    return 'String: $this (length: ${length})';
  }

  void printInfo() {
    print(describe());
  }
}

/// Usage example
void main() {
  // Extension now only works on String
  'Hello'.printInfo(); // Still works

  // These no longer compile - MAJOR breaking change
  // 123.printInfo();        // Error: The method 'printInfo' isn't defined for the type 'int'
  // true.printInfo();       // Error: The method 'printInfo' isn't defined for the type 'bool'
  // [1, 2, 3].printInfo();  // Error: The method 'printInfo' isn't defined for the type 'List<int>'
  // {'key': 'value'}.printInfo(); // Error: The method 'printInfo' isn't defined for the type 'Map<String, String>'
}
