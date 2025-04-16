import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_state.dart';
import '../../bloc/auth/password_reset/password_reset_bloc.dart';
import 'reset_password_page.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;

  const VerificationCodePage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //timer resend
  bool _canResendOtp = false;
  int _resendCooldownSeconds = 60;
  Timer? _resendCooldownTimer;

  @override
  void dispose() {
    _otpController.dispose();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _submitOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final code = _otpController.text.trim();

    context.read<PasswordResetBloc>().add(
      PasswordResetCodeSubmitted(email: widget.email, otp: code),
    );
  }

  void _startResendCooldown() {
    _canResendOtp = false;
    _resendCooldownTimer?.cancel();
    // Đặt lại thời gian đếm ngược
    _resendCooldownTimer=Timer.periodic(const Duration(seconds: 1), (timer){
      if(mounted) {
        setState(() {
          if (_resendCooldownSeconds > 0) {
            _resendCooldownSeconds--;
          }
          else {
            _canResendOtp = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Nhập Mã Xác Thực"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {

          if (state is PasswordResetCodeFailure) {
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
          else if (state is PasswordResetNewPasswordRequired) {
            if (state.email == widget.email) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<PasswordResetBloc>(context),
                    child: ResetPasswordPage(email: state.email),
                  ),
                ),
              );
            } else {
              print("Email mismatch in state vs widget: ${state.email} != ${widget.email}");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
              );
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
            builder: (context, state) {
              final isVerifyingCode = state is PasswordResetCodeVerifying;

              final isInputDisabled = isVerifyingCode;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã xác thực đã được gửi tới:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

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
                        counterText: "",
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !isInputDisabled,
                      autofocus: true,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        // **** ĐẶT onPressed LÀ null ĐỂ VÔ HIỆU HÓA ****
                        onPressed: null, // <--- THAY ĐỔI QUAN TRỌNG Ở ĐÂY
                        child: Text(
                          // Vẫn hiển thị text động dựa trên state
                          _canResendOtp
                              ? 'Gửi lại mã OTP'
                              : 'Gửi lại sau (${_resendCooldownSeconds}s)',
                          style: TextStyle(
                            // Vẫn đổi màu dựa trên state để thấy hiệu ứng disable
                            color: _canResendOtp ? Colors.blueAccent.withOpacity(0.5) : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    // --- Nút Xác thực Mã OTP ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInputDisabled ? null : _submitOtp,
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