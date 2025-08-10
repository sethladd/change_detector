// Simple example demonstrating enums with renamed/reordered values
library example;

/// An enum with renamed values - MAJOR breaking change
enum Status {
  waiting, // renamed from pending - MAJOR breaking change
  active,
  completed,
  aborted, // renamed from cancelled - MAJOR breaking change
  failed
}

/// An enum with reordered values - MAJOR breaking change
enum LogLevel {
  info, // now index 0 (was index 1)
  debug, // now index 1 (was index 0)
  error, // now index 2 (was index 3)
  warning, // now index 3 (was index 2)
  fatal // still index 4
}

/// Function that processes a status
/// This will now fail to compile due to renamed enum values
String getStatusMessage(Status status) {
  switch (status) {
    case Status.waiting: // Was Status.pending
      return 'Waiting';
    case Status.active:
      return 'Active';
    case Status.completed:
      return 'Completed';
    case Status.aborted: // Was Status.cancelled
      return 'Aborted';
    case Status.failed:
      return 'Failed';
  }
}

/// Function that relies on enum indices
/// This will now produce incorrect results due to reordered enum values
bool isHighSeverity(LogLevel level) {
  // Now error is index 2, warning is index 3
  // Code that relied on the original ordering will produce incorrect results
  return level.index >= 2;
}
