import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/auth/signup/signup_event.dart';
import 'package:supabase_flutter_app/bloc/auth/signup/signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  SignupBloc() : super(SignupState.initial) {
    on<SignupRequested>(_onSignupRequested);
  }

  FutureOr<void> _onSignupRequested(SignupRequested event, Emitter<SignupState> emit) async {
    emit(SignupState.loading);
    try {
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
      );


      if (response.user != null) {
        emit(SignupState.success);
      } else {
        emit(SignupState.failure);
      }
    } catch (e) {
      print('Signup failed: $e');
      emit(SignupState.failure);
    }
  }
}