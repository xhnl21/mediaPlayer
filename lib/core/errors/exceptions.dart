/// Infrastructure exceptions
class ServerException implements Exception {
  ServerException([this.message = 'Server Exception']);
  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache Exception']);
  final String message;
}

class SecurityException implements Exception {
  SecurityException([this.message = 'Security Exception']);
  final String message;
}

class CryptoException implements Exception {
  CryptoException([this.message = 'Cryptographic Exception']);
  final String message;
}
