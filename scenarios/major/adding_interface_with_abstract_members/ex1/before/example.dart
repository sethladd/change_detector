// Simple example demonstrating a class that will have a new interface added
library example;

/// An interface with abstract methods
abstract class Loggable {
  void log(String message);
}

/// A simple class that can be implemented by consumers
class DataProcessor {
  void process(String data) {
    print('Processing: $data');
  }
}

/// A consumer implementation of DataProcessor
class CustomProcessor implements DataProcessor {
  @override
  void process(String data) {
    // Custom implementation
    print('Custom processing: $data');
  }
}
