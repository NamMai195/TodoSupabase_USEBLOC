abstract class AuthScreenEvent {}

class AuthSign extends AuthScreenEvent {
  final String email;
  final String password;
  AuthSign({required this.email, required this.password});

}

class AuthLogin extends AuthScreenEvent {
  final String email;
  final String password;
  AuthLogin({required this.email, required this.password});
}

class AuthLogout extends AuthScreenEvent {}