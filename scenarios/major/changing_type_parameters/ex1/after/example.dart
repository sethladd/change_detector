// Simple example demonstrating generic classes and functions with changed type parameters
library example;

/// Added a second type parameter - MAJOR breaking change [Major.24]
class Box<T, E> {
  final T value;
  final E? extra;

  Box(this.value, [this.extra]);

  T getValue() => value;
  E? getExtra() => extra;
}

/// Removed a type parameter - MAJOR breaking change [Major.24]
class Pair<K> {
  final K first;
  final K second;

  Pair(this.first, this.second);
}

/// Removed the type parameter - MAJOR breaking change [Major.24]
dynamic identity(dynamic value) {
  return value;
}

/// Added a third type parameter - MAJOR breaking change [Major.24]
List<R> transform<T, R, E>(List<T> items, R Function(T, E?) converter,
    [E? extra]) {
  return items.map((item) => converter(item, extra)).toList();
}
