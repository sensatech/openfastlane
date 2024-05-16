import 'package:frontend/domain/login/auth_result_model.dart';

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

  get name => '$firstName $lastName';
  static User fromAuthResult(AuthResult result) {
    return User(
      username: result.username,
      firstName: result.firstName,
      lastName: result.lastName,
      roles: result.roles,
    );
  }
}
