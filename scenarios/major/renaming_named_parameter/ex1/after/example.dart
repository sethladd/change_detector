// Simple example demonstrating functions with renamed named parameters
library example;

/// A function with renamed named parameters - MAJOR breaking change
void configure({String? label, bool enabled = true, int duration = 1000}) {
  // name -> label, timeout -> duration
  print(
      'Configuring with label: $label, enabled: $enabled, duration: $duration');
}

/// A class with methods having renamed named parameters
class HttpClient {
  /// Method with renamed named parameters - MAJOR breaking change
  Future<void> request({
    required String uri, // url -> uri
    String httpMethod = 'GET', // method -> httpMethod
    Map<String, String>? httpHeaders, // headers -> httpHeaders
    Object? data, // body -> data
  }) async {
    print('Making $httpMethod request to $uri');
    if (httpHeaders != null) {
      print('Headers: $httpHeaders');
    }
    if (data != null) {
      print('Body: $data');
    }
  }
}
