// Simple example demonstrating changed constant values
library example;

/// Value changed from 3 to 5 - MAJOR breaking change
const int maxRetryCount = 5;

/// Value changed from '1.0.0' to '2.0.0' - MAJOR breaking change
const String apiVersion = '2.0.0';

/// A class with a constant field
class Config {
  /// Value changed from 5000 to 10000 - MAJOR breaking change
  static const int timeout = 10000;
}
