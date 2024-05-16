import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/login/auth_result_model.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class GlobalLoginService extends Cubit<GlobalLoginState> {
  GlobalLoginService(this.authService, this.secureStorageService) : super(LoginInitial());

  final AuthService authService;
  final SecureStorageService secureStorageService;

  final Logger logger = getLogger();

  String? _accessToken;
  User? _user;

  String? get accessToken => _accessToken;

  User? get currentUser => _user;

  AuthResult? _authResult;

  void checkLoginStatus() async {
    try {
      logger.i('Global: checking login status');
      final String? refreshToken = await secureStorageService.getRefreshToken();
      _accessToken = await blockingGetAccessToken();
      logger.i('checking login status: refreshToken: $refreshToken, _accessToken: $_accessToken');

      if (_accessToken != null && refreshToken != null) {
        AuthResult authResult = await AuthResult.accessTokenToResult(
          refreshToken: refreshToken,
          accessToken: _accessToken!,
        );
        logger.i('checking login status: refreshToken and _accessToken exist');
        logger.i('Global: checkLoginStatus AppLoggedIn');
        _user = User.fromAuthResult(authResult);
        if (_accessToken != null) {
          _authResult = authResult;
        }
        emit(LoggedIn(authResult));
      } else {
        logger.w('Global: AppNotLoggedIn');
        // emit(NotLoggedIn());
      }
    } catch (e) {
      logger.e(e.toString());
      emit(LoginError(e.toString()));
    }
  }

  Future<void> login() async {
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
    _accessToken = null;
    AuthResult authResult = await authService.login();

    logger.i('checking login status: $authResult');
    _accessToken = authResult.accessToken;
    final refreshToken = authResult.refreshToken;
    _user = User.fromAuthResult(authResult);
    await secureStorageService.storeRefreshToken(refreshToken);
    await secureStorageService.storeAccessToken(_accessToken!);
    await secureStorageService.storeAccessTokenExpiresAt(authResult.expiresAtSeconds!);
    logger.i('Global: _doLogin AppLoggedIn');
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
    _accessToken = await secureStorageService.getAccessToken();

    if (_accessToken == null) {
      logger.e('Global: blockingGetAccessToken -> no accessToken');
      emit(NotLoggedIn());
      return null;
    }

    final accessTokenExpiresAt = await secureStorageService.getAccessTokenExpiresAt();
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    if (accessTokenExpiresAt == null || accessTokenExpiresAt < now) {
      logger.e('Global: new login necessary!');
      emit(LoggedInExpired(_authResult));

      // if (_reloadLock) {
      //   logger.w('Global: _reloadLock is active');
      //   await Future.delayed(const Duration(seconds: 15));
      //   return null;
      // }
      // _reloadLock = true;
      return null;
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

class LoggedInExpired extends GlobalLoginState {
  final AuthResult? authResult;

  LoggedInExpired(this.authResult);
}

class NotLoggedIn extends GlobalLoginState {}

class LoginError extends GlobalLoginState {
  final String message;

  LoginError(this.message);
}
