// Simple example demonstrating a class with added constructors
library example;

/// A class with additional constructors
class User {
  final String name;
  final int age;

  /// Default constructor (unchanged)
  User(this.name, this.age);

  /// Added named constructor - MINOR change [Minor.3]
  User.guest()
      : name = 'Guest',
        age = 0;

  /// Added factory constructor - MINOR change [Minor.3]
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['name'] as String? ?? 'Unknown',
      map['age'] as int? ?? 0,
    );
  }
}
