// Simple example demonstrating generic classes with tightened type parameter bounds
library example;

/// A generic container class with added restrictive bound - MAJOR breaking change
class Container<T extends num> {
  final T value;

  Container(this.value);

  T getValue() => value;
}

/// A generic function with added restrictive bound - MAJOR breaking change
void process<E extends Comparable<E>>(E item) {
  print(item);
}

/// Usage example
// void main() {
//   // These are now valid
//   final numContainer = Container<num>(42);
//   final intContainer = Container<int>(123);
//   final doubleContainer = Container<double>(3.14);

//   // These are no longer valid:
//   // final stringContainer = Container<String>('hello'); // Error: String doesn't extend num
//   // final boolContainer = Container<bool>(true);       // Error: bool doesn't extend num

//   process<String>('hello'); // Valid: String implements Comparable<String>
//   process<int>(123); // Valid: int implements Comparable<int>
//   // process<bool>(false);     // Error: bool doesn't implement Comparable<bool>
// }
