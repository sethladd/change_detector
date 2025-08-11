// Simple example demonstrating variables with incompatibly changed types
library example;

/// Changed from Object to String - MAJOR breaking change [Major.3]
String defaultValue = 'default';

/// A class with a typed field
class Config {
  /// Changed from List<dynamic> to List<String> - MAJOR breaking change [Major.3]
  static List<String> supportedTypes = ['string', 'number', 'boolean'];
}
