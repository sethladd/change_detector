// Simple example demonstrating API elements that will be deprecated
library example;

/// A class for user management
class UserManager {
  /// Creates a new user
  void createUser(String name) {
    // Implementation
  }

  /// Legacy method for updating user
  void updateUser(String id, String name) {
    // Implementation
  }
}

/// A utility function
String formatId(int id) {
  return 'ID-$id';
}

/// A constant for maximum users
const int maxUsers = 100;
