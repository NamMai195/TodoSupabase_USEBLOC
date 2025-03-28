import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/authScreenBloc/authScreen_event.dart';
import 'package:supabase_flutter_app/bloc/authScreenBloc/authScreen_state.dart';

class  AuthScreenBloc extends Bloc<AuthScreenEvent, AuthscreenState>{
  AuthScreenBloc() :super(AuthscreenState.initial){
    on<AuthSign>(_onAuthSign);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
  }

  FutureOr<void> _onAuthSign(AuthSign event, Emitter<AuthscreenState> emit) async{
    emit(AuthscreenState.loading);
    final email = event.email;
    final password = event.password;
    final sb=Supabase.instance.client;
    try{
       final response = await sb.auth.signInWithPassword(
        email: email,
        password: password,
      );
       if(response.user != null){
         emit(AuthscreenState.success);
       }
       else{
         emit(AuthscreenState.failure);
       }
    }
    catch (e){
      emit(AuthscreenState.failure);
    }

  }
  FutureOr<void> _onAuthLogin(AuthLogin event, Emitter<AuthscreenState> emit) async{
    emit(AuthscreenState.loading);
    final email = event.email;
    final password = event.password;
    final sb=Supabase.instance.client;
    try{
      final response = await sb.auth.signUp(
        email: email,
        password: password,
      );
      if(response.user != null){
        emit(AuthscreenState.success);
      }
      else{
        emit(AuthscreenState.failure);
      }
    }
    catch (e){
      emit(AuthscreenState.failure);
    }

  }
  FutureOr<void> _onAuthLogout(AuthLogout event, Emitter<AuthscreenState> emit) {

  }

}