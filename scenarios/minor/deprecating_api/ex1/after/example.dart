// Simple example demonstrating deprecated API elements
library example;

/// A class for user management
class UserManager {
  /// Creates a new user
  void createUser(String name) {
    // Implementation
  }

  /// Method marked as deprecated - MINOR change
  @Deprecated('Use updateUserProfile instead')
  void updateUser(String id, String name) {
    // Implementation
  }

  /// New method that replaces the deprecated one
  void updateUserProfile(String id, String name, {String? email}) {
    // Implementation
  }
}

/// Function marked as deprecated - MINOR change
@Deprecated('Use createFormattedId instead')
String formatId(int id) {
  return 'ID-$id';
}

/// New function that replaces the deprecated one
String createFormattedId(int id) {
  return 'ID-$id';
}

/// Constant marked as deprecated - MINOR change
@Deprecated('Use USER_LIMIT instead')
const int maxUsers = 100;

/// New constant that replaces the deprecated one
const int USER_LIMIT = 100;
