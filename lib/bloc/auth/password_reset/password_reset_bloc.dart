import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  PasswordResetBloc() : super(PasswordResetInitial()) {
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
      await _supabaseClient.auth.resetPasswordForEmail(
        event.email.trim(),
      );
      emit(PasswordResetCodeEntryRequired(email: event.email.trim()));
    } on AuthException catch (e) {
      emit(PasswordResetOtpSendFailure(error: e.message));
    } catch (e) {
      emit(PasswordResetOtpSendFailure(error: e.toString()));
    }
  }

  Future<void> _onOtpSubmitted(
      PasswordResetCodeSubmitted event, Emitter<PasswordResetState> emit) async {
    if (state is PasswordResetCodeEntryRequired || state is PasswordResetCodeFailure) {
      final currentStateEmail = (state is PasswordResetCodeEntryRequired)
          ? (state as PasswordResetCodeEntryRequired).email
          : (state as PasswordResetCodeFailure).email;

      if(currentStateEmail != event.email.trim()){
        emit(PasswordResetCodeFailure(error: 'Lỗi trạng thái: Email không khớp.', email: event.email.trim()));
        return;
      }

      emit(PasswordResetCodeVerifying());
      try {
        await _supabaseClient.auth.verifyOTP(
          email: event.email.trim(),
          token: event.otp.trim(),
          type: OtpType.recovery,
        );

        emit(PasswordResetNewPasswordRequired(email: event.email.trim()));

      } on AuthException catch (e) {
        emit(PasswordResetCodeFailure(error: e.message, email: event.email.trim()));
      } catch (e) {
        emit(PasswordResetCodeFailure(error: e.toString(), email: event.email.trim()));
      }
    } else {
      print("Lỗi: Gọi submit OTP ở trạng thái không mong đợi: $state");
    }
  }

  Future<void> _onNewPasswordSubmitted(
      PasswordResetNewPasswordSubmitted event,
      Emitter<PasswordResetState> emit) async {
    if (state is PasswordResetNewPasswordRequired || state is PasswordResetSetPasswordFailure) {
      final currentStateEmail = (state is PasswordResetNewPasswordRequired)
          ? (state as PasswordResetNewPasswordRequired).email
          : (state as PasswordResetSetPasswordFailure).email;

      if (currentStateEmail != event.email) {
        emit(PasswordResetSetPasswordFailure(
            error: 'Lỗi trạng thái không mong đợi: Email không khớp.',
            email: event.email));
        return;
      }

      emit(PasswordResetSubmitting(email: event.email));

      try {
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