// Simple example demonstrating a class with renamed members
library example;

/// A class with renamed members - MAJOR breaking changes
class User {
  /// Renamed from 'name' - MAJOR breaking change
  String fullName;

  /// Renamed from 'age' - MAJOR breaking change
  int years;

  User(this.fullName, this.years);

  /// Renamed from 'incrementAge' - MAJOR breaking change
  void addYear() {
    years++;
  }

  /// Renamed from 'isAdult' - MAJOR breaking change
  bool get isMature => years >= 18;

  /// Renamed from 'displayName' - MAJOR breaking change
  set userName(String value) {
    fullName = value;
  }

  /// Renamed from 'createDefault' - MAJOR breaking change
  static User createNew() {
    return User('Default', 30);
  }
}

/// Usage example
void main() {
  final user = User('Alice', 30);

  // These would now fail to compile:
  // print(user.name);         // Error: The getter 'name' isn't defined for the type 'User'
  // print(user.age);          // Error: The getter 'age' isn't defined for the type 'User'
  // user.incrementAge();      // Error: The method 'incrementAge' isn't defined for the type 'User'
  // print(user.isAdult);      // Error: The getter 'isAdult' isn't defined for the type 'User'
  // user.displayName = '...'; // Error: The setter 'displayName' isn't defined for the type 'User'
  // User.createDefault();     // Error: The method 'createDefault' isn't defined for the class 'User'

  // Need to use the new names:
  print(user.fullName);
  print(user.years);
  user.addYear();
  print(user.isMature);
  user.userName = 'Alice Smith';

  final defaultUser = User.createNew();
}
