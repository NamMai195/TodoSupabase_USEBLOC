import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import các Event, State, Bloc cần thiết
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_state.dart';
import '../../bloc/auth/password_reset/password_reset_bloc.dart'; // Đảm bảo đúng đường dẫn
import 'reset_password_page.dart'; // Đảm bảo đúng đường dẫn

class VerificationCodePage extends StatefulWidget {
  // Nhận email từ trang trước qua constructor
  final String email;

  const VerificationCodePage({
    super.key,
    required this.email, // Email là bắt buộc
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  // Chỉ cần controller cho OTP
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key cho Form validation OTP

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Hàm gọi khi nhấn nút "Xác thực Mã OTP"
  void _submitOtp() {
    // Validate chỉ ô OTP
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Validator sẽ hiển thị lỗi
    }
    final code = _otpController.text.trim();

    // Gửi event xác thực OTP vào BLoC, sử dụng email từ widget
    context.read<PasswordResetBloc>().add(
      PasswordResetCodeSubmitted(email: widget.email, otp: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        // Đổi tiêu đề cho phù hợp hơn
        title: const Text("Nhập Mã Xác Thực"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // BlocListener xử lý các hiệu ứng phụ (lỗi, điều hướng)
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          // Bỏ listener cho OtpSendFailure (vì gửi OTP ở trang trước)

          // Xử lý lỗi khi xác thực OTP
          if (state is PasswordResetCodeFailure) {
            // Xóa snackbar cũ (nếu có) và hiển thị dialog lỗi
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Lỗi Xác thực'),
                content: Text(state.error),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          // Xử lý khi xác thực OTP thành công -> Điều hướng
          else if (state is PasswordResetNewPasswordRequired) {
            // Đảm bảo email trong state khớp với email đang dùng (thường là vậy)
            if (state.email == widget.email) {
              Navigator.pushReplacement( // Dùng pushReplacement để không quay lại trang OTP được
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<PasswordResetBloc>(context),
                    // Truyền email đã xác thực thành công
                    child: ResetPasswordPage(email: state.email),
                  ),
                ),
              );
            } else {
              // Trường hợp hiếm gặp: email trong state khác email của trang này
              print("Email mismatch in state vs widget: ${state.email} != ${widget.email}");
              // Có thể hiển thị lỗi hoặc xử lý khác
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
              );
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // BlocBuilder để cập nhật UI dựa trên state
          child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
            builder: (context, state) {
              // Xác định trạng thái loading khi xác thực OTP
              final isVerifyingCode = state is PasswordResetCodeVerifying;

              // Ô OTP và nút Submit chỉ bị disable khi đang xác thực
              final isInputDisabled = isVerifyingCode;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị email đã nhận (chỉ đọc) để người dùng biết
                    Text(
                      'Mã xác thực đã được gửi tới:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email, // Hiển thị email nhận được
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30), // Khoảng cách

                    // --- Phần Nhập Mã OTP ---
                    Text(
                      'Nhập mã OTP',
                      style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _otpController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mã OTP gồm 6 chữ số',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.password, color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                        counterText: "", // Ẩn bộ đếm ký tự mặc định
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !isInputDisabled, // Disable khi đang xác thực
                      autofocus: true, // Tự động focus vào ô OTP khi mở trang
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mã OTP';
                        }
                        if (value.length != 6) {
                          return 'Mã OTP phải có 6 chữ số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),

                    // --- Nút Xác thực Mã OTP ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInputDisabled ? null : _submitOtp, // Disable khi đang xác thực
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isVerifyingCode
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Xác thực Mã OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}