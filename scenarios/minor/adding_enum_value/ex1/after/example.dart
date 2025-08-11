// Simple example demonstrating an enum with added values
library example;

/// An enum with an added value - MINOR change [Minor.4]
enum Status {
  pending,
  active,
  completed,
  cancelled // New value added
}

/// Function that uses the enum
/// Note: This switch statement is now non-exhaustive (missing cancelled case)
/// but this is only a static warning, not an error
// String getStatusMessage(Status status) {
//   switch (status) {
//     case Status.pending:
//       return 'Pending';
//     case Status.active:
//       return 'Active';
//     case Status.completed:
//       return 'Completed';
//     // Missing Status.cancelled case
//   }
//   return ''; // Added to handle non-exhaustive switch
// }
