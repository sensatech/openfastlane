import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';

class GlobalUserService extends Cubit<GlobalUserState> {
  User? _currentUser;
  Campaign? _currentCampaign;

  GlobalUserService() : super(UserInitial());

  void setCurrentUser(String username) {
    _currentUser = User(username);
  }

  void setCurrentCampaign(Campaign campaign) {
    _currentCampaign = campaign;
  }

  void clearAll() {
    _currentUser = null;
    _currentCampaign = null;
  }

  User? get currentUser => _currentUser;

  Campaign? get currentCampaign => _currentCampaign;
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
  User(this.username);
  final String username;
}
