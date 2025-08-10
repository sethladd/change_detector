// Simple example demonstrating classes with fields that have incompatibly changed types
library example;

/// A class with fields whose types have changed incompatibly
class Configuration {
  /// Changed from Object to String - MAJOR breaking change
  String defaultValue;

  /// Changed from num to int - MAJOR breaking change
  /// (int is a subtype of num, but this breaks code that assigns double values)
  int timeout;

  /// Changed from List<dynamic> to List<String> - MAJOR breaking change
  List<String> allowedValues;

  /// Changed from Map<String, dynamic> to Map<String, String> - MAJOR breaking change
  Map<String, String> properties;

  Configuration({
    required this.defaultValue,
    required this.timeout,
    required this.allowedValues,
    required this.properties,
  });
}

/// Usage example
void main() {
  final config = Configuration(
    defaultValue: 'default',
    timeout: 1000,
    allowedValues: ['value1', 'value2'],
    properties: {'name': 'Config1', 'enabled': 'true', 'count': '42'},
  );

  // These would now fail to compile:
  // config.defaultValue = 100;        // Error: int can't be assigned to String
  // config.timeout = 3.14;            // Error: double can't be assigned to int
  // config.allowedValues.add(false);  // Error: bool can't be assigned to String
  // config.properties['newProp'] = DateTime.now(); // Error: DateTime can't be assigned to String

  // Need to use compatible types:
  config.defaultValue = 'new default';
  config.timeout = 2000;
  config.allowedValues.add('value3');
  config.properties['newProp'] = 'new value';
}
