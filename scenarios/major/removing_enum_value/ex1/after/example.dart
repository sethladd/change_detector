// Simple example demonstrating an enum with removed values
library example;

/// An enum with removed values - MAJOR breaking change
enum Status {
  pending,
  inProgress,
  completed,
  // cancelled value removed - MAJOR breaking change
  failed
}

/// Function that processes a status
/// This will now fail for code that passes Status.cancelled
String getStatusMessage(Status status) {
  switch (status) {
    case Status.pending:
      return 'Pending';
    case Status.inProgress:
      return 'In Progress';
    case Status.completed:
      return 'Completed';
    // case Status.cancelled: // This case is now invalid
    //   return 'Cancelled';
    case Status.failed:
      return 'Failed';
  }
}
