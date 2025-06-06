import 'package:equatable/equatable.dart';

//dung Equatable
abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
  @override List<Object?> get props => throw UnimplementedError();
}

// Event: Yêu cầu gửi mã OTP tới email
class PasswordResetSendOtpRequested extends PasswordResetEvent {
  final String email;
  const PasswordResetSendOtpRequested({required this.email});
  @override List<Object?> get props => [email];
}
// Event: Người dùng đã nhập và gửi mã OTP
class PasswordResetCodeSubmitted extends PasswordResetEvent {
  final String email;
  final String otp;
  const PasswordResetCodeSubmitted({required this.email, required this.otp});
  @override List<Object?> get props => [email, otp];
}
// Event: Người dùng đã nhập và gửi mật khẩu mới
class PasswordResetNewPasswordSubmitted extends PasswordResetEvent {
  final String email;
  final String password;
  const PasswordResetNewPasswordSubmitted({required this.email, required this.password});
  @override List<Object?> get props => [email, password];
}