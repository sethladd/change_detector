// Simple example demonstrating functions with optional parameters
library example;

/// A function with optional positional parameter
String formatText(String text, [String prefix = '']) {
  return '$prefix$text';
}

/// A function with optional named parameter
void logMessage(String message, {bool isError = false}) {
  if (isError) {
    print('ERROR: $message');
  } else {
    print('INFO: $message');
  }
}

/// A class with methods having optional parameters
class Logger {
  /// Method with optional named parameter
  void log(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    print('$prefix$message');
  }
}
