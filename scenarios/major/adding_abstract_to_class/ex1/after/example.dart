// Simple example demonstrating a class made abstract
library example;

/// Now abstract - MAJOR breaking change [Major.5]
abstract class Shape {
  void draw(); // Now abstract method with no implementation
}

/// Usage example
// void main() {
//   // This is no longer valid - Shape cannot be instantiated
//   // final shape = Shape();  // Error!

//   // Must use a concrete subclass instead
//   final circle = Circle();
//   circle.draw();
// }

// /// Concrete subclass
// class Circle extends Shape {
//   @override
//   void draw() {
//     // Implementation
//   }
// }
