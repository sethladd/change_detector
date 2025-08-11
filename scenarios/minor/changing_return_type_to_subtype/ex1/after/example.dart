// Simple example with functions returning more specific subtypes
library example;

/// Now returns int (subtype of num) - MINOR change [Minor.8]
int getValue() {
  return 42;
}

/// Class with methods returning more specific types
class Example {
  /// Now returns int (subtype of num) - MINOR change [Minor.8]
  int calculate() {
    return 100;
  }

  /// Property now returning double (subtype of num) - MINOR change [Minor.8]
  double get value => 123.0;
}
