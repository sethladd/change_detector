// Simple example demonstrating a class with multiple constructors
library example;

/// A class with both default and named constructors
class Configuration {
  final String name;
  final Map<String, dynamic> settings;

  /// Default constructor
  Configuration(this.name, this.settings);

  /// Named constructor for creating an empty configuration
  Configuration.empty()
      : name = 'default',
        settings = {};

  /// Named constructor for creating from a map
  Configuration.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String? ?? 'unnamed',
        settings = map['settings'] as Map<String, dynamic>? ?? {};
}
