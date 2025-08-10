// Simple example demonstrating variables with incompatibly changed types
library example;

/// Changed from Object to String - MAJOR breaking change
String defaultValue = 'default';

/// A class with a typed field
class Config {
  /// Changed from List<dynamic> to List<String> - MAJOR breaking change
  static List<String> supportedTypes = ['string', 'number', 'boolean'];
}
