// Simple example with functions returning general types
library example;

/// Returns num type
num getValue() {
  return 42;
}

/// Class with method returning num
class Example {
  /// Returns num type
  num calculate() {
    return 100;
  }

  /// Property returning num
  num get value => 123;
}
