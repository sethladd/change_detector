// Simple example demonstrating functions with parameters made required
library example;

/// Changed optional positional parameter to required - MAJOR breaking change [Major.17]
String formatText(String text, String prefix) {
  return '$prefix$text';
}

/// Changed optional named parameter to required - MAJOR breaking change [Major.17]
void logMessage(String message, {required bool isError}) {
  if (isError) {
    print('ERROR: $message');
  } else {
    print('INFO: $message');
  }
}

/// A class with methods having parameters made required
class Logger {
  /// Changed optional named parameter to required - MAJOR breaking change [Major.17]
  void log(String message, {required String tag}) {
    final prefix = '[$tag] ';
    print('$prefix$message');
  }
}
