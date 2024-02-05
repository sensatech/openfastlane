import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalLoginService extends Cubit<GlobalLoginState> {
  GlobalLoginService() : super(LoginInitial());

  bool _isLoggedIn = true;

  get isLoggedIn => _isLoggedIn;

  void checkLoginStatus() {
    if (_isLoggedIn) {
      emit(LoggedIn());
    } else {
      emit(NotLoggedIn());
    }
  }

  void login() async {
    if (!_isLoggedIn) {
      emit(LoginLoading());
      await Future.delayed(const Duration(seconds: 3));
      _isLoggedIn = true;
      emit(LoggedIn());
    } else {
      emit(LoggedIn());
    }
  }

  void logout() async {
    emit(LoginLoading());
    await Future.delayed(const Duration(seconds: 3));
    if (_isLoggedIn) {
      _isLoggedIn = false;
      emit(NotLoggedIn());
    } else {
      emit(NotLoggedIn());
    }
  }
}

@immutable
abstract class GlobalLoginState {}

class LoginInitial extends GlobalLoginState {}

class LoginLoading extends GlobalLoginState {}

class LoggedIn extends GlobalLoginState {}

class NotLoggedIn extends GlobalLoginState {}
