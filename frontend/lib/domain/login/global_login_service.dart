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

  bool _reloadLock = false;

  void checkLoginStatus({bool duringLogin = false}) async {
    try {
      logger.i('Global: checking login status');
      final String? refreshToken = await secureStorageService.getRefreshToken();
      _accessToken = await blockingGetAccessToken(duringLogin: duringLogin);
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
        logger.w('Global: AppNotLoggedIn checkLoginStatus');
        emit(NotLoggedIn());
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
    logger.i('Global: AppLoggedIn');
    _reloadLock = false;
    return authResult;
  }

  void logout() async {
    try {
      emit(LoginLoading());
      await authService.logout();
      await secureStorageService.deleteAccessToken();
      await secureStorageService.deleteRefreshToken();
      _accessToken = null;
      logger.i('Global: AppNotLoggedIn logout');
      emit(NotLoggedIn());
    } catch (e) {
      logger.e(e.toString());
      logger.e('Global: AppError');
      emit(LoginError(e.toString()));
    }
  }

  Future<String?> blockingGetAccessToken({bool duringLogin = false}) async {
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

      if (duringLogin) {
        logger.e('Global: blockingGetAccessToken during login -> start login, emit NotLoggedIn, block.');
        emit(NotLoggedIn());
      } else {
        if (_reloadLock) {
          logger.w('Global: _reloadLock is active');
          await Future.delayed(const Duration(seconds: 30));
          emit(LoggedInExpired(_authResult));
        }
      }

      _reloadLock = true;
      logger.i('Global: _doLogin start');
      AuthResult authResult = await _doLogin();
      _reloadLock = false;
      logger.i('Global: _doLogin done');
      emit(LoggedIn(authResult));
      return authResult.accessToken;
    } else {
      _reloadLock = false;
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
