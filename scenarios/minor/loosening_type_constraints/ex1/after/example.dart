// Simple example demonstrating generic types with loosened constraints
library example;

/// A generic class with a loosened type parameter constraint - MINOR change [Minor.7]
/// Changed from <T extends num> to <T>
class NumericBox<T> {
  final T value;

  NumericBox(this.value);

  T getValue() => value;

  // This method now requires a runtime check since T is no longer guaranteed to be num
  double getDoubleValue() {
    if (value is num) {
      return (value as num).toDouble();
    }
    return 0.0;
  }
}

/// A generic function with a loosened type parameter constraint - MINOR change [Minor.7]
/// Changed from <E extends Comparable<E>> to <E>
void printComparable<E>(E item) {
  print('Item: $item');
  if (item is Comparable) {
    print('This item is comparable');
  }
}

/// Usage example
// void main() {
//   // These are still valid with the loosened constraints
//   final intBox = NumericBox<int>(42);
//   final doubleBox = NumericBox<double>(3.14);

//   print(intBox.getValue());
//   print(doubleBox.getDoubleValue());

//   // These are now also valid with the loosened constraints
//   final stringBox = NumericBox<String>('hello');
//   final boolBox = NumericBox<bool>(true);

//   print(stringBox.getValue());
//   print(boolBox.getValue());

//   // These are still valid with the loosened constraints
//   printComparable<int>(123);
//   printComparable<String>('hello');

//   // These are now also valid with the loosened constraints
//   printComparable<bool>(true);
//   printComparable<List<int>>([1, 2, 3]);
// }
