// Simple example demonstrating functions with parameters that will be removed
library example;

/// A function with multiple parameters
String formatText(String text, String prefix, {bool uppercase = false}) {
  final result = '$prefix$text';
  return uppercase ? result.toUpperCase() : result;
}

/// A function with optional positional parameters
void logMessage(String message, [String? category, int level = 0]) {
  final categoryStr = category != null ? '[$category] ' : '';
  final levelStr = level > 0 ? '(Level $level) ' : '';
  print('$levelStr$categoryStr$message');
}

/// A class with methods having parameters
class DataProcessor {
  /// Method with required and named parameters
  String process(String data, {required bool validate, int timeout = 1000}) {
    if (validate) {
      // Validation logic
    }
    // Processing with timeout
    return 'Processed: $data';
  }

  /// Method with positional parameters
  void analyze(String data, int depth, bool detailed) {
    // Analysis logic
    print('Analyzing $data with depth $depth, detailed: $detailed');
  }
}

/// Usage example
// void main() {
//   print(formatText('Hello', '>> ', uppercase: true));
//   logMessage('System started', 'SYSTEM', 1);

//   final processor = DataProcessor();
//   processor.process('data123', validate: true, timeout: 2000);
//   processor.analyze('sample', 3, true);
// }
