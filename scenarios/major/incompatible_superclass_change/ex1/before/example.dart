// Simple example demonstrating a class with a superclass
library example;

/// Base class with useful functionality
class Base {
  String name;
  
  Base(this.name);
  
  void log() {
    print('Log: $name');
  }
  
  String getData() {
    return 'Data for $name';
  }
}

/// Class extending Base, inheriting its methods
class Child extends Base {
  Child(super.name);
  
  @override
  String getData() {
    return 'Enhanced data for $name';
  }
}
