// Simple example demonstrating generic classes and functions with type parameters
library example;

/// A generic class with a single type parameter
class Box<T> {
  final T value;

  Box(this.value);

  T getValue() => value;
}

/// A generic class with two type parameters
class Pair<K, V> {
  final K first;
  final V second;

  Pair(this.first, this.second);
}

/// A generic function with a single type parameter
T identity<T>(T value) {
  return value;
}

/// A generic function that processes items
List<R> transform<T, R>(List<T> items, R Function(T) converter) {
  return items.map(converter).toList();
}
