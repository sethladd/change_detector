// Simple example demonstrating functions with return types that will change
library example;

/// Returns a string representation of the data
String formatData(dynamic data) {
  return data.toString();
}

/// Class with methods having specific return types
class DataProcessor {
  /// Returns an iterable of processed items
  Iterable<String> processItems(List<dynamic> items) {
    return items.map((item) => item.toString());
  }

  /// Returns the string length
  int get dataSize => 100;
}
