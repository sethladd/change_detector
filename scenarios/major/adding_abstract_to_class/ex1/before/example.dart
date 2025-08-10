// Simple example demonstrating a concrete class
library example;

/// A concrete, instantiable class
class Shape {
  void draw() {
    // Implementation
  }
}

/// Usage example
void main() {
  // This is valid because Shape is concrete
  final shape = Shape();
  shape.draw();
}
