import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_event.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  LoginBloc() : super(LoginState.initial) {
    on<LoginRequested>(_onLoginRequested);}

  FutureOr<void> _onLoginRequested(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginState.loading);
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(LoginState.success);
      } else {
        emit(LoginState.failure);
      }
    } catch (e) {
      print('Login failed: $e'); // Log lỗi
      emit(LoginState.failure);
    }
  }
}