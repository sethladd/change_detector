// Simple example demonstrating a class with removed members
library example;

/// A class with various members removed
class User {
  final String name;

  User(this.name); // age parameter removed

  // incrementAge method removed - MAJOR breaking change

  // isAdult getter removed - MAJOR breaking change

  // displayName setter removed - MAJOR breaking change

  // age field removed - MAJOR breaking change
}
