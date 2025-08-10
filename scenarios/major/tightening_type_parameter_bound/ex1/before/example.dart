// Simple example demonstrating generic classes and functions with type parameters
library example;

/// A generic container class with unconstrained type parameter
class Container<T> {
  final T value;

  Container(this.value);

  T getValue() => value;
}

/// A generic function with unconstrained type parameter
void process<E>(E item) {
  print(item);
}

/// Usage example
void main() {
  // These are valid with unconstrained type parameters
  final stringContainer = Container<String>('hello');
  final numContainer = Container<num>(42);
  final boolContainer = Container<bool>(true);

  process<String>('hello');
  process<int>(123);
  process<bool>(false);
}
