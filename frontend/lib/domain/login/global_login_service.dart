import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/login/auth_result_model.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class GlobalLoginService extends Cubit<GlobalLoginState> {
  GlobalLoginService(this.authService, this.secureStorageService) : super(LoginInitial());

  final AuthService authService;
  final SecureStorageService secureStorageService;

  final Logger logger = getLogger();

  String? _accessToken;
  String? get accessToken => _accessToken;

  AuthResult? _authResult;

  void checkLoginStatus() async {
    try {
      logger.i('checking login status');
      _accessToken = await blockingGetAccessToken();
      final String? refreshToken = await secureStorageService.getRefreshToken();
      logger.i('checking login status: $_accessToken');

      if (_accessToken != null && refreshToken != null) {
        AuthResult authResult = await AuthResult.accessTokenToResult(
          refreshToken: refreshToken,
          accessToken: _accessToken!,
        );
        logger.i('checking login status: $authResult');
        logger.i('Global: AppLoggedIn');
        emit(LoggedIn(authResult));
      } else {
        logger.w('Global: AppNotLoggedIn');
        emit(NotLoggedIn());
      }
    } catch (e) {
      logger.e(e.toString());
      emit(LoginError(e.toString()));
    }
  }

  void login() async {
    try {
      emit(LoginLoading());
      _authResult = await _doLogin();
      logger.i('Global: LoggedIn');
      emit(LoggedIn(_authResult!));
    } catch (e) {
      logger.e(e.toString());
      emit(LoginError(e.toString()));
    }
  }

  Future<AuthResult> _doLogin() async {
    AuthResult authResult = await authService.login();
    logger.i('checking login status: $authResult');
    _accessToken = authResult.accessToken;
    final refreshToken = authResult.refreshToken;
    await secureStorageService.storeRefreshToken(refreshToken);
    await secureStorageService.storeAccessToken(_accessToken!);
    await secureStorageService.storeAccessTokenExpiresAt(authResult.expiresAtSeconds!);
    logger.i('Global: AppLoggedIn');
    return authResult;
  }

  void logout() async {
    try {
      emit(LoginLoading());
      await secureStorageService.deleteAccessToken();
      await secureStorageService.deleteRefreshToken();
      _accessToken = null;
      logger.i('Global: AppNotLoggedIn');
      emit(NotLoggedIn());
    } catch (e) {
      logger.e(e.toString());
      logger.e('Global: AppError');
      emit(LoginError(e.toString()));
    }
  }

  Future<String?> blockingGetAccessToken() async {
    logger.i('Global: blockingGetAccessToken');
    _accessToken = await secureStorageService.getAccessToken();
    final accessTokenExpiresAt = await secureStorageService.getAccessTokenExpiresAt();

    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    if (accessTokenExpiresAt == null || accessTokenExpiresAt < now) {
      logger.e('Global: new login necessary!');
      AuthResult authResult = await _doLogin();
      emit(LoggedIn(authResult));
      return authResult.accessToken;
    } else {
      return _accessToken;
    }
  }
}

@immutable
abstract class GlobalLoginState {}

class LoginInitial extends GlobalLoginState {}

class LoginLoading extends GlobalLoginState {}

class LoggedIn extends GlobalLoginState {
  final AuthResult authResult;

  LoggedIn(this.authResult);
}

class NotLoggedIn extends GlobalLoginState {}

class LoginError extends GlobalLoginState {
  final String message;

  LoginError(this.message);
}
