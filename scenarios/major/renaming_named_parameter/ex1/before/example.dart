// Simple example demonstrating functions with named parameters
library example;

/// A function with named parameters
void configure({String? name, bool enabled = true, int timeout = 1000}) {
  print('Configuring with name: $name, enabled: $enabled, timeout: $timeout');
}

/// A class with methods having named parameters
class HttpClient {
  /// Method with named parameters
  Future<void> request({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
  }) async {
    print('Making $method request to $url');
    if (headers != null) {
      print('Headers: $headers');
    }
    if (body != null) {
      print('Body: $body');
    }
  }
}
