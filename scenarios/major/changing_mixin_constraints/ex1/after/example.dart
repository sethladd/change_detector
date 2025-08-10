// Simple example demonstrating a mixin with added constraints
library example;

/// A base class
class Base {
  void baseMethod() {
    print('Base method');
  }
}

/// Another class not related to Base
class Other {
  void otherMethod() {
    print('Other method');
  }
}

/// A mixin with added constraint - MAJOR breaking change
/// Now can only be used with classes that extend Base
mixin Logger on Base {
  void log(String message) {
    print('LOG: $message');
    baseMethod(); // Now can use Base methods
  }
}

/// This class is still valid because it extends Base
class ProcessorWithLogging extends Base with Logger {
  void process() {
    log('Processing started');
    // Processing logic
    log('Processing completed');
  }
}

/// This class is no longer valid - MAJOR breaking change
/// Error: 'Logger' can't be mixed onto 'Other' because 'Other' doesn't extend 'Base'
// class OtherWithLogging extends Other with Logger {
//   void doSomething() {
//     otherMethod();
//     log('Did something');
//   }
// }
