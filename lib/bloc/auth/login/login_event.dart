abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});

}
