// Simple example demonstrating a class with a new interface added
library example;

/// An interface with abstract methods
abstract class Loggable {
  void log(String message);
}

/// Class now implements Loggable - MAJOR breaking change [Major.7]
/// This introduces a new abstract method requirement
class DataProcessor implements Loggable {
  @override
  void log(String message) {
    print('LOG: $message');
  }

  void process(String data) {
    print('Processing: $data');
    log('Processed data: $data');
  }
}

/// A consumer implementation of DataProcessor
/// This will now fail to compile because it needs to implement log()
// class CustomProcessor implements DataProcessor {
//   // Missing implementation of log() method

//   @override
//   void process(String data) {
//     // Custom implementation
//     print('Custom processing: $data');
//   }

//   // Need to add this to fix the error:
//   // @override
//   // void log(String message) {
//   //   // Implementation required
//   // }
// }
