// Simple example demonstrating an enum with values that will be removed
library example;

/// An enum representing different status values
enum Status { pending, inProgress, completed, cancelled, failed }

/// Function that processes a status
String getStatusMessage(Status status) {
  switch (status) {
    case Status.pending:
      return 'Pending';
    case Status.inProgress:
      return 'In Progress';
    case Status.completed:
      return 'Completed';
    case Status.cancelled:
      return 'Cancelled';
    case Status.failed:
      return 'Failed';
  }
}
