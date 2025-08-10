// Simple example demonstrating enums with values that will be renamed/reordered
library example;

/// An enum representing different status values
enum Status {
  pending, // index 0
  active, // index 1
  completed, // index 2
  cancelled, // index 3
  failed // index 4
}

/// An enum representing log levels
enum LogLevel {
  debug, // index 0
  info, // index 1
  warning, // index 2
  error, // index 3
  fatal // index 4
}

/// Function that processes a status
String getStatusMessage(Status status) {
  switch (status) {
    case Status.pending:
      return 'Pending';
    case Status.active:
      return 'Active';
    case Status.completed:
      return 'Completed';
    case Status.cancelled:
      return 'Cancelled';
    case Status.failed:
      return 'Failed';
  }
}

/// Function that relies on enum indices
bool isHighSeverity(LogLevel level) {
  // Assumes warning is index 2, error is index 3, and fatal is index 4
  return level.index >= 2;
}
