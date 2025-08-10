// Simple example demonstrating an extension on a general type
library example;

/// An extension on Object that can be used with any object
extension ObjectExtension on Object {
  String describe() {
    return 'Object: $this (${runtimeType})';
  }

  void printInfo() {
    print(describe());
  }
}

/// Usage example
// void main() {
//   // Extension works on any object
//   'Hello'.printInfo();
//   123.printInfo();
//   true.printInfo();

//   final list = [1, 2, 3];
//   list.printInfo();

//   final map = {'key': 'value'};
//   map.printInfo();
// }
