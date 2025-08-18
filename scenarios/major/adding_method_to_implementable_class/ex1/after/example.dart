/// A simple storage interface that can be implemented by consumers.
///
/// In the "after" state, this class now has both read AND write methods.
/// This is a BREAKING CHANGE because existing implementations only provide
/// the read method and will now fail to compile due to the missing write method.
abstract class Storage {
  /// Reads data from storage with the given key.
  String? read(String key);

  /// NEW METHOD: Writes data to storage with the given key and value.
  ///
  /// Adding this method breaks existing implementations of Storage
  /// because they must now implement this additional method.
  void write(String key, String value);
}

/// Example concrete implementation - THIS WOULD NOW BE BROKEN
/// because it doesn't implement the new write method.
///
/// Compilation error: "Missing concrete implementation of 'Storage.write'"
// class MemoryStorage implements Storage {
//   final Map<String, String> _data = {};

//   @override
//   String? read(String key) => _data[key];

//   void store(String key, String value) {
//     _data[key] = value;
//   }

//   // Missing: void write(String key, String value) implementation
// }

/// Another example implementation - ALSO BROKEN
///
/// Compilation error: "Missing concrete implementation of 'Storage.write'"
// class FileStorage implements Storage {
//   final String basePath;

//   FileStorage(this.basePath);

//   @override
//   String? read(String key) {
//     // Simulate file reading
//     return 'file_content_for_$key';
//   }

//   // Missing: void write(String key, String value) implementation
// }
