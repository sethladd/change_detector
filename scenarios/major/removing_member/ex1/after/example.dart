// Simple example demonstrating a class with removed members
library example;

/// A class with various members removed
class User {
  final String name;

  User(this.name); // age parameter removed

  // incrementAge method removed - MAJOR breaking change [Major.11]

  // isAdult getter removed - MAJOR breaking change [Major.11]

  // displayName setter removed - MAJOR breaking change [Major.11]

  // age field removed - MAJOR breaking change [Major.11]
}
