// Simple example demonstrating a class with a changed, incompatible superclass
library example;

/// A different base class that doesn't have the same members
class DifferentBase {
  final int id;

  DifferentBase(this.id);

  // No log() method

  // Different return type for getData()
  int getData() {
    return id;
  }
}

/// Class now extends DifferentBase - MAJOR breaking change
/// The superclass lacks the same members as the original Base
class Child extends DifferentBase {
  Child(int id) : super(id);

  // Need to reimplement members that were previously inherited
  void log() {
    print('Log: $id');
  }

  @override
  int getData() {
    return id * 2;
  }
}
