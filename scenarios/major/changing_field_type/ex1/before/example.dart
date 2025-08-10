// Simple example demonstrating classes with fields that will have their types changed
library example;

/// A class with various typed fields
class Configuration {
  /// A field with Object type that can hold any value
  Object defaultValue;

  /// A field with num type that can hold int or double
  num timeout;

  /// A field with List<dynamic> type that can hold any list
  List<dynamic> allowedValues;

  /// A field with Map<String, dynamic> type
  Map<String, dynamic> properties;

  Configuration({
    required this.defaultValue,
    required this.timeout,
    required this.allowedValues,
    required this.properties,
  });
}

/// Usage example
// void main() {
//   final config = Configuration(
//     defaultValue: 'default',
//     timeout: 1000,
//     allowedValues: ['value1', 'value2', 123, true],
//     properties: {'name': 'Config1', 'enabled': true, 'count': 42},
//   );

//   // These are valid with the current field types
//   config.defaultValue = 100;
//   config.timeout = 3.14;
//   config.allowedValues.add(false);
//   config.properties['newProp'] = DateTime.now();
// }
