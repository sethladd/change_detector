// Simple example library with added declarations
library example;

/// A simple class (unchanged)
class Example {
  String value;
  Example(this.value);
}

/// A simple function (unchanged)
String doSomething() {
  return 'result';
}

/// Added class - MINOR change [Minor.1]
class NewExample {}

/// Added function - MINOR change [Minor.1]
int calculate() => 42;

/// Added enum - MINOR change [Minor.1]
enum Status { active, inactive }

/// Added constant - MINOR change [Minor.1]
const String version = '1.0.0';

/// Added mixin - MINOR change [Minor.1]
mixin Loggable {
  void log(String message) {
    print('LOG: $message');
  }
}

/// Added extension - MINOR change [Minor.1]
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Added type alias (typedef) - MINOR change [Minor.1]
typedef JsonMap = Map<String, dynamic>;

/// Added variable - MINOR change [Minor.1]
final bool isDebugMode = true;
