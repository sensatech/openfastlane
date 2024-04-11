import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/login/auth_result_model.dart';

class GlobalUserService extends Cubit<GlobalUserState> {
  Campaign? _currentCampaign;

  GlobalUserService() : super(UserInitial());

  // FIXME: always make sure that info is a) deducible via URL or b) stored in the user's session
  Campaign? get currentCampaign => _currentCampaign;

  void setCurrentCampaign(Campaign campaign) {
    _currentCampaign = campaign;
  }
}

class GlobalUserState {}

class UserInitial extends GlobalUserState {}

class UserLoading extends GlobalUserState {}

class UserLoaded extends GlobalUserState {
  UserLoaded(this.user);

  final User user;
}

class UserError extends GlobalUserState {
  UserError(this.error);

  final String error;
}

class User {
  User({
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.roles = const [],
  });

  final String username;
  final String firstName;
  final String lastName;
  final List<String> roles;

  static User fromAuthResult(AuthResult result) {
    return User(
      username: result.username,
      firstName: result.firstName,
      lastName: result.lastName,
      roles: result.roles,
    );
  }
}
