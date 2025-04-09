import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/bloc/auth/session/session_event.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  bool _isFirstCheck = true;

  SessionBloc() : super(SessionState(isAuthenticated: false, status: SessionStatus.initial)) {
    on<SessionCheckRequested>(_onSessionCheckRequested);
  }

  void _onSessionCheckRequested(SessionCheckRequested event, Emitter<SessionState> emit) {
    emit(state.copyWith(status: SessionStatus.loading));
    final supabase = sb.Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session != null && session.user != null) {
      emit(state.copyWith(
        isAuthenticated: true,
        status: SessionStatus.success,
      ));
    } else {
      if (_isFirstCheck) {
        emit(state.copyWith(
          isAuthenticated: false,
          status: SessionStatus.one,
        ));
        _isFirstCheck = false;
      } else {
        emit(state.copyWith(
          isAuthenticated: false,
          status: SessionStatus.failure,
        ));
      }
    }
  }
}