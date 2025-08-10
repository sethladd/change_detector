// Simple example demonstrating a mixin without constraints
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

/// A mixin without constraints
mixin Logger {
  void log(String message) {
    print('LOG: $message');
  }
}

/// A class using the mixin
class ProcessorWithLogging with Logger {
  void process() {
    log('Processing started');
    // Processing logic
    log('Processing completed');
  }
}

/// Another class using the mixin
class OtherWithLogging extends Other with Logger {
  void doSomething() {
    otherMethod();
    log('Did something');
  }
}
