import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable{
  const PasswordResetState();
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}


// State: Khởi tạo ban đầu (chưa làm gì)
class PasswordResetInitial extends PasswordResetState {}
// State: Đang yêu cầu gửi mã OTP (loading)
class PasswordResetOtpSending extends PasswordResetState {}
// State: Gửi mã OTP thất bại
class PasswordResetOtpSendFailure extends PasswordResetState {
  final String error;
  const PasswordResetOtpSendFailure({required this.error});
  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
// State: Yêu cầu người dùng nhập mã OTP (đã gửi mail thành công)
class PasswordResetCodeEntryRequired extends PasswordResetState {
  final String email;
  const PasswordResetCodeEntryRequired({required this.email});
  @override
  // TODO: implement props
  List<Object?> get props => [email];
}
// State: Đang xác thực mã OTP (loading)
class PasswordResetCodeVerifying extends PasswordResetState {}
// State: Xác thực mã OTP thất bại
class PasswordResetCodeFailure extends PasswordResetState {
  final String error;
  final String email;
  const PasswordResetCodeFailure({required this.error, required this.email});
  @override
  // TODO: implement props
  List<Object?> get props => [error,email];
}
// State: Yêu cầu nhập mật khẩu mới (xác thực OTP thành công)
class PasswordResetNewPasswordRequired extends PasswordResetState {
  final String email;
  const PasswordResetNewPasswordRequired({required this.email});
  @override
  // TODO: implement props
  List<Object?> get props => [email];
}
// State: Đang gửi mật khẩu mới (loading)
class PasswordResetSubmitting extends PasswordResetState {
  final String email;
  const PasswordResetSubmitting({required this.email});
  @override
  // TODO: implement props
  List<Object?> get props => [email];
}
// State: Đặt mật khẩu mới thất bại
class PasswordResetSetPasswordFailure extends PasswordResetState {
  final String error;
  final String email;
  const PasswordResetSetPasswordFailure({required this.error, required this.email});
  @override
  // TODO: implement props
  List<Object?> get props => [error,email];
}
// State: Thành công cuối cùng
class PasswordResetSuccess extends PasswordResetState {}