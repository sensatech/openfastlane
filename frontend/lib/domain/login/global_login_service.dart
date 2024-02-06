import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/login/auth_result_model.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class GlobalLoginService extends Cubit<GlobalLoginState> {
  GlobalLoginService(this.secureStorage, this.authService) : super(LoginInitial());

  final FlutterSecureStorage secureStorage;
  final AuthService authService;

  final Logger logger = getLogger();

  bool _isLoggedIn = true;
  String? _accessToken;
  AuthResult? _authResult;

  get isLoggedIn => _isLoggedIn;

  void checkLoginStatus() async {
    _accessToken = await getAccessToken();

    if (_accessToken != null) {
      _authResult = await authService.accessTokenToResult(_accessToken!);
      emit(LoggedIn());
    } else {
      emit(NotLoggedIn());
    }
  }

  void login() async {
    try {
      emit(LoginLoading());
      _authResult = await authService.connectAuth();
      _accessToken = _authResult?.accessToken;
      storeAccessToken(_accessToken!);
      _isLoggedIn = true;
      emit(LoggedIn());
    } catch (e) {
      logger.e(e.toString());
      emit(LoginError(e.toString()));
    }
  }

  void logout() async {
    try {
      emit(LoginLoading());
      await deleteAccessToken();
      _authResult = null;
      _accessToken = null;
      _isLoggedIn = false;
      emit(NotLoggedIn());
    } catch (e) {
      logger.e(e.toString());
      emit(LoginError(e.toString()));
    }
  }

  Future<String?> getAccessToken() async {
    final accessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);
    return accessToken;
  }

  Future<void> storeAccessToken(String accessTokenValue) async {
    await secureStorage.write(key: ACCESS_TOKEN_KEY, value: accessTokenValue);
  }

  Future<void> deleteAccessToken() async {
    await secureStorage.delete(key: ACCESS_TOKEN_KEY);
  }

  static const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN_KEY';
}

@immutable
abstract class GlobalLoginState {}

class LoginInitial extends GlobalLoginState {}

class LoginLoading extends GlobalLoginState {}

class LoggedIn extends GlobalLoginState {}

class NotLoggedIn extends GlobalLoginState {}

class LoginError extends GlobalLoginState {
  final String message;

  LoginError(this.message);
}
