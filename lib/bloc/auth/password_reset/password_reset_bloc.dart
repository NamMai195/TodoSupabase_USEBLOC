

import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_state.dart';

class PasswordResetBloc  extends Bloc<PasswordResetEvent, PasswordResetState>{
  final SupabaseClient _supabaseClient= Supabase.instance.client;

  PasswordResetBloc() :super(PasswordResetInitial()) {
    on<PasswordResetSendOtpRequested>(_onSendOtpRequested);
    on<PasswordResetCodeSubmitted>(_onOtpSubmitted);
    on<PasswordResetNewPasswordSubmitted>(_onNewPasswordSubmitted);
  }

  Future<void> _onSendOtpRequested(
      PasswordResetSendOtpRequested event,
      Emitter<PasswordResetState> emit,
      ) async {
    emit(PasswordResetOtpSending());
    try {
      await _supabaseClient.auth.signInWithOtp(
        email: event.email.trim(),
      );
      emit(PasswordResetCodeEntryRequired(email: event.email.trim()));
    } on AuthException catch (e) {
      emit(PasswordResetOtpSendFailure(error: e.message));
    } catch (e) {
      emit(PasswordResetOtpSendFailure(error: e.toString()));
    }
  }

  Future<void> _onOtpSubmitted (
      PasswordResetCodeSubmitted event,
      Emitter<PasswordResetState> emit
      ) async{
    emit(PasswordResetCodeVerifying());
    try{
      final AuthResponse resp = await _supabaseClient.auth.verifyOTP(
        email: event.email.trim(),
        token: event.otp.trim(),
        type: OtpType.email,
      );

      if(resp.user !=null || resp.session !=null) {
        emit(PasswordResetNewPasswordRequired(email: event.email.trim()));
      }
      else {
        // Ném lỗi nếu verify thành công nhưng không có user/session (bất thường)
        throw Exception('OTP verification succeeded but no user/session found.');
      }
    } on AuthException catch (e) {
      //loi tu supabase(sai code,het han....)
      emit(PasswordResetCodeFailure(error: e.message, email: event.email.trim()));
    } catch (e) {
      // loi khac
      emit(PasswordResetCodeFailure(error: e.toString(), email: event.email.trim()));
    }
  }

  Future<void> _onNewPasswordSubmitted(
      PasswordResetNewPasswordSubmitted event,
      Emitter<PasswordResetState> emit
      ) async{
    if (state is PasswordResetNewPasswordRequired || state is PasswordResetSetPasswordFailure){
      final currentStateEmail = (state is PasswordResetNewPasswordRequired)
          ? (state as PasswordResetNewPasswordRequired).email
          : (state as PasswordResetSetPasswordFailure).email;

      if(currentStateEmail !=event.email) {
        emit(PasswordResetSetPasswordFailure(error: 'Lỗi trạng thái không mong đợi: Email không khớp.', email: event.email));
        return;
      }

      emit(PasswordResetSubmitting(email: event.email));

      try{
        await _supabaseClient.auth.updateUser(
          UserAttributes(password: event.password),
        );
        emit(PasswordResetSuccess());
      } on AuthException catch (e) {
        emit(PasswordResetSetPasswordFailure(error: e.message, email: event.email));
      } catch (e) {
        emit(PasswordResetSetPasswordFailure(error: e.toString(), email: event.email));
      }
    } else {
      print("Lỗi: Gọi submit mật khẩu mới ở trạng thái không mong đợi: $state");
    }
  }
}