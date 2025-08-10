// Simple example demonstrating an enum
library example;

/// An enum with a set of values
enum Status { pending, active, completed }

/// Function that uses the enum
String getStatusMessage(Status status) {
  switch (status) {
    case Status.pending:
      return 'Pending';
    case Status.active:
      return 'Active';
    case Status.completed:
      return 'Completed';
  }
}
