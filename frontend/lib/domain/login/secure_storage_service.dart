import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage secureStorage;

  SecureStorageService(this.secureStorage);

  Future<void> storeAccessToken(String accessTokenValue) async {
    await secureStorage.write(key: accessTokenKey, value: accessTokenValue);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await secureStorage.delete(key: accessTokenKey);
  }

  Future<int?> getAccessTokenExpiresAt() async {
    // parse to int:
    final string = await secureStorage.read(key: accessExpiresKey);
    if (string == null) return null;
    return int.parse(string);
  }

  Future<void> storeAccessTokenExpiresAt(int accessTokenValue) async {
    await secureStorage.write(key: accessExpiresKey, value: accessTokenValue.toString());
  }

  Future<void> deleteAccessTokenExpiresAt() async {
    await secureStorage.delete(key: accessExpiresKey);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: refreshTokenKey);
  }

  Future<void> storeRefreshToken(String refreshTokenValue) async {
    await secureStorage.write(key: refreshTokenKey, value: refreshTokenValue);
  }

  Future<void> deleteRefreshToken() async {
    await secureStorage.delete(key: refreshTokenKey);
  }

  static const refreshTokenKey = 'REFRESH_TOKEN_KEY';
  static const accessTokenKey = 'ACCESS_TOKEN_KEY';
  static const accessExpiresKey = 'ACCESS_EXPIRES_KEY';
}
