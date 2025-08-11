// Simple example demonstrating functions with incompatibly changed return types
library example;

/// Changed return type from String to int - MAJOR breaking change [Major.21]
int formatData(dynamic data) {
  return data.toString().length;
}

/// Class with methods having incompatibly changed return types
class DataProcessor {
  /// Changed return type from Iterable<String> to List<int> - MAJOR breaking change [Major.21]
  /// List<int> is not a subtype of Iterable<String>
  List<int> processItems(List<dynamic> items) {
    return items.map((item) => item.toString().length).toList();
  }

  /// Changed return type from int to String - MAJOR breaking change [Major.21]
  String get dataSize => '100';
}
