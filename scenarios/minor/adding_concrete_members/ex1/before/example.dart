// Simple example demonstrating a class that will have new members added
library example;

/// A class with some existing members
class User {
  final String name;
  int age;

  User(this.name, this.age);

  String get displayName => name;

  void incrementAge() {
    age++;
  }

  @override
  String toString() => 'User($name, $age)';
}

/// A class with static members
class Logger {
  static void log(String message) {
    print('LOG: $message');
  }
}

/// An interface that can be implemented
abstract class Identifiable {
  String getId();
}

/// A class that extends User
class Employee extends User {
  final String department;

  Employee(String name, int age, this.department) : super(name, age);

  @override
  String toString() => 'Employee($name, $age, $department)';
}

/// A class that implements Identifiable
class Product implements Identifiable {
  final String code;
  final String name;

  Product(this.code, this.name);

  @override
  String getId() => code;
}

/// Usage example
// void main() {
//   final user = User('Alice', 30);
//   print(user.displayName);
//   user.incrementAge();

//   final employee = Employee('Bob', 35, 'Engineering');
//   print(employee.displayName);

//   final product = Product('P123', 'Widget');
//   print(product.getId());

//   Logger.log('Created user: $user');
// }
