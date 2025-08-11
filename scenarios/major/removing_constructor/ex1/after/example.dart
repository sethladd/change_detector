// Simple example demonstrating a class with removed constructors
library example;

/// A class with some constructors removed
class Configuration {
  final String name;
  final Map<String, dynamic> settings;

  /// Default constructor
  Configuration(this.name, this.settings);

  // Named constructor 'empty' has been removed - MAJOR breaking change [Major.22]

  // Named constructor 'fromMap' has been removed - MAJOR breaking change [Major.22]
}
