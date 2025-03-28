enum AuthStatus {
  initial, loading,success,failure,one
}
class AuthState{
  final bool isAuthenticated;
  final AuthStatus status;

  // AuthState(this.isAuthenticated, this.status);

  AuthState({
    required this.isAuthenticated,
    required this.status
});

  AuthState copyWith({
    bool? isAuthenticated,
    AuthStatus ? status
}){
    return AuthState(
        isAuthenticated : isAuthenticated ?? this.isAuthenticated,
        status : status ?? this.status);
  }
}