class AuthResult {
  final String accessToken;
  final String username;
  final String firstName;
  final String lastName;
  final List<String> roles;

  AuthResult(this.firstName, this.lastName, this.roles,
      {required this.accessToken, required this.username});
}
