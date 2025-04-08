enum SessionStatus {
  initial,
  loading,
  success,
  failure,
}

class SessionState {
  final bool isAuthenticated;
  final SessionStatus status;

  SessionState({
    required this.isAuthenticated,
    required this.status,
  });

  SessionState copyWith({
    bool? isAuthenticated,
    SessionStatus? status,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      status: status ?? this.status,
    );
  }
}