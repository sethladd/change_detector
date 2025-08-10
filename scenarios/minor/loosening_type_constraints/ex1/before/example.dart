// Simple example demonstrating generic types with constraints
library example;

/// A generic class with a constrained type parameter
class NumericBox<T extends num> {
  final T value;

  NumericBox(this.value);

  T getValue() => value;

  double getDoubleValue() => value.toDouble();
}

/// A generic function with a constrained type parameter
void printComparable<E extends Comparable<E>>(E item) {
  print('Comparable item: $item');
}

/// Usage example
// void main() {
//   // These are valid with the current constraints
//   final intBox = NumericBox<int>(42);
//   final doubleBox = NumericBox<double>(3.14);

//   print(intBox.getValue());
//   print(doubleBox.getDoubleValue());

//   // These are valid with the current constraints
//   printComparable<String>('hello');
//   printComparable<DateTime>(DateTime.now());
// }
