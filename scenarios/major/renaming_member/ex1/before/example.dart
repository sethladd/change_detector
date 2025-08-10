// Simple example demonstrating a class with members that will be renamed
library example;

/// A class with various members
class User {
  /// A public field
  String name;

  /// Another public field
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
    name = value;
  }

  /// A static method
  static User createDefault() {
    return User('Default', 30);
  }
}

/// Usage example
// void main() {
//   final user = User('Alice', 30);

//   // Using the members
//   print(user.name);
//   print(user.age);
//   user.incrementAge();
//   print(user.isAdult);
//   user.displayName = 'Alice Smith';

//   final defaultUser = User.createDefault();
// }
