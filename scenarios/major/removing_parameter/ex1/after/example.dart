// Simple example demonstrating functions with removed parameters
library example;

/// Removed the 'prefix' parameter - MAJOR breaking change
String formatText(String text, {bool uppercase = false}) {
  return uppercase ? text.toUpperCase() : text;
}

/// Removed the 'category' parameter - MAJOR breaking change
void logMessage(String message, [int level = 0]) {
  final levelStr = level > 0 ? '(Level $level) ' : '';
  print('$levelStr$message');
}

/// A class with methods having removed parameters
class DataProcessor {
  /// Removed the 'timeout' parameter - MAJOR breaking change
  String process(String data, {required bool validate}) {
    if (validate) {
      // Validation logic
    }
    // Processing with default timeout
    return 'Processed: $data';
  }

  /// Removed the 'detailed' parameter - MAJOR breaking change
  void analyze(String data, int depth) {
    // Analysis logic
    print('Analyzing $data with depth $depth');
  }
}

/// Usage example
void main() {
  // These would now fail to compile:
  // print(formatText('Hello', '>> ', uppercase: true)); // Error: Too many positional arguments
  // logMessage('System started', 'SYSTEM', 1);          // Error: String can't be assigned to int
  // processor.process('data123', validate: true, timeout: 2000); // Error: Named parameter not found
  // processor.analyze('sample', 3, true);               // Error: Too many positional arguments

  // Need to use the new signatures:
  print(formatText('Hello', uppercase: true));
  logMessage('System started', 1);

  final processor = DataProcessor();
  processor.process('data123', validate: true);
  processor.analyze('sample', 3);
}
