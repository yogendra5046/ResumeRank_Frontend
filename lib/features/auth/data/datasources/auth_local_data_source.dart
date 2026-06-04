import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _tokenKey = "auth_token";

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException();
    }
  }
}
