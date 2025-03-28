import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/bloc/auth_event.dart';
import 'package:supabase_flutter_app/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  bool _isFirstCheck = true; // Add a flag to track the first check

  AuthBloc() : super(AuthState(isAuthenticated: false, status: AuthStatus.initial)) {
    on<AuthCheck>(_onAuthCheck);
  }

  void _onAuthCheck(AuthCheck event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.loading));
    final supabase = sb.Supabase.instance.client;
    final user = supabase.auth.currentSession?.user;

    if (user != null) {
      emit(state.copyWith(
        isAuthenticated: true,
        status: AuthStatus.success,
      ));
    } else {
      if (_isFirstCheck) {
        emit(state.copyWith(
          isAuthenticated: false,
          status: AuthStatus.one,
        ));
        _isFirstCheck = false; // Set flag to false after the first check.
      } else {
        emit(state.copyWith(
          isAuthenticated: false,
          status: AuthStatus.failure,
        ));
      }
    }
  }
}