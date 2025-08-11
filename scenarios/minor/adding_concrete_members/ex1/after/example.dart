// Simple example demonstrating a class with added members
library example;

/// A class with added members - MINOR changes
class User {
  final String name;
  int age;

  // Added new field - MINOR change
  String? email;

  User(this.name, this.age, {this.email});

  String get displayName => name;

  // Added new getter - MINOR change
  bool get isAdult => age >= 18;

  void incrementAge() {
    age++;
  }

  // Added new method - MINOR change
  void updateEmail(String newEmail) {
    email = newEmail;
  }

  // Added new setter - MINOR change
  set displayAge(bool show) {
    // Implementation
  }

  @override
  String toString() =>
      email != null ? 'User($name, $age, $email)' : 'User($name, $age)';
}

/// A class with added static members
class Logger {
  static void log(String message) {
    print('LOG: $message');
  }

  // Added static field - MINOR change
  static bool verbose = false;

  // Added static method - MINOR change
  static void logError(String error) {
    print('ERROR: $error');
  }

  // Added static getter - MINOR change
  static bool get isVerbose => verbose;
}

/// An interface that can be implemented
abstract class Identifiable {
  String getId();

  // Added new abstract method - this would be a major
  //breaking change for implementers
  // This is only shown as an example of what NOT to do for MINOR changes
  String getDisplayName();
}

/// A class that extends User
class Employee extends User {
  final String department;

  Employee(String name, int age, this.department, {String? email})
      : super(name, age, email: email);

  @override
  String toString() => 'Employee($name, $age, $department)';

  // Employee automatically gets all the new methods and fields from User
  // This is why adding members to a class intended for extension is a MINOR change
}

/// A class that implements Identifiable
class Product implements Identifiable {
  final String code;
  final String name;

  Product(this.code, this.name);

  @override
  String getId() => code;

  // This class would need to be updated to implement the new getDisplayName() method
  // This is why adding abstract members to an interface is a MAJOR change
  @override
  String getDisplayName() => name;
}

/// Usage example
// void main() {
//   final user = User('Alice', 30, email: 'alice@example.com');
//   print(user.displayName);
//   print('Is adult: ${user.isAdult}'); // Using new getter
//   user.incrementAge();
//   user.updateEmail('newalice@example.com'); // Using new method

//   final employee = Employee('Bob', 35, 'Engineering', email: 'bob@example.com');
//   print(employee.isAdult); // Employee has access to the new getter
//   employee.updateEmail(
//       'newbob@example.com'); // Employee has access to the new method

//   final product = Product('P123', 'Widget');
//   print(product.getId());
//   print(product.getDisplayName()); // Product must implement the new method

//   Logger.verbose = true; // Using new static field
//   if (Logger.isVerbose) {
//     // Using new static getter
//     Logger.log('Created user: $user');
//   }
//   Logger.logError('Example error'); // Using new static method
// }
