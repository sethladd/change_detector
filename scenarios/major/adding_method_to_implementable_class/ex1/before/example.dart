/// A simple storage interface that can be implemented by consumers.
///
/// In the "before" state, this class only has a read method.
/// Consumers can implement this class to provide their own storage solutions.
abstract class Storage {
  /// Reads data from storage with the given key.
  String? read(String key);
}

/// Example concrete implementation
class MemoryStorage implements Storage {
  final Map<String, String> _data = {};

  @override
  String? read(String key) => _data[key];

  void store(String key, String value) {
    _data[key] = value;
  }
}

/// Another example implementation
class FileStorage implements Storage {
  final String basePath;

  FileStorage(this.basePath);

  @override
  String? read(String key) {
    // Simulate file reading
    return 'file_content_for_$key';
  }
}
