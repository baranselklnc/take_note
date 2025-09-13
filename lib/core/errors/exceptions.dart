/// Custom exceptions for the app
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException(this.message, [this.statusCode]);
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
}

class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
}
