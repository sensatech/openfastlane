import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage secureStorage;

  SecureStorageService(this.secureStorage);

  Future<void> storeAccessToken(String accessTokenValue) async {
    await secureStorage.write(key: ACCESS_TOKEN_KEY, value: accessTokenValue);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: ACCESS_TOKEN_KEY);
  }

  Future<void> deleteAccessToken() async {
    await secureStorage.delete(key: ACCESS_TOKEN_KEY);
  }

  Future<int?> getAccessTokenExpiresAt() async {
    // parse to int:
    final string = await secureStorage.read(key: ACCESS_EXPIRES_KEY);
    if (string == null) return null;
    return int.parse(string);
  }

  Future<void> storeAccessTokenExpiresAt(int accessTokenValue) async {
    await secureStorage.write(key: ACCESS_EXPIRES_KEY, value: accessTokenValue.toString());
  }

  Future<void> deleteAccessTokenExpiresAt() async {
    await secureStorage.delete(key: ACCESS_EXPIRES_KEY);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: REFRESH_TOKEN_KEY);
  }

  Future<void> storeRefreshToken(String refreshTokenValue) async {
    await secureStorage.write(key: REFRESH_TOKEN_KEY, value: refreshTokenValue);
  }

  Future<void> deleteRefreshToken() async {
    await secureStorage.delete(key: REFRESH_TOKEN_KEY);
  }

  static const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN_KEY';
  static const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN_KEY';
  static const ACCESS_EXPIRES_KEY = 'ACCESS_EXPIRES_KEY';
}
