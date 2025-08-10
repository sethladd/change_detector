// Simple example demonstrating a class with members that will be removed
library example;

/// A class with various members
class User {
  final String name;

  /// A public field
  int age;

  User(this.name, this.age);

  /// A public method
  void incrementAge() {
    age++;
  }

  /// A public getter
  bool get isAdult => age >= 18;

  /// A public setter
  set displayName(String value) {
    // Implementation
  }
}
