// Simple example demonstrating fields made final
library example;

/// A class with fields made final
class Configuration {
  /// Changed to final - MAJOR breaking change [Major.14]
  final String name;

  /// Changed to final - MAJOR breaking change [Major.14]
  final int timeout;

  Configuration(this.name, this.timeout);
}

/// Usage example
// void updateConfiguration(Configuration config) {
//   // These assignments are no longer valid
//   // config.name = 'updated';     // Error: Can't assign to final variable
//   // config.timeout = 10000;      // Error: Can't assign to final variable

//   // Need to create a new instance instead
//   return Configuration('updated', 10000);
// }
