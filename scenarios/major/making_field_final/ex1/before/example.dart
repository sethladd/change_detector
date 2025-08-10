// Simple example demonstrating mutable fields
library example;

/// A class with mutable fields
class Configuration {
  /// A mutable field that can be changed after initialization
  String name;

  /// Another mutable field
  int timeout;

  Configuration(this.name, this.timeout);
}

/// Usage example
void updateConfiguration(Configuration config) {
  // These assignments are valid since fields are mutable
  config.name = 'updated';
  config.timeout = 10000;
}
