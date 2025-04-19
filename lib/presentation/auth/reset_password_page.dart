import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart'; // Thêm import Lottie
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_state.dart';
import '../../bloc/auth/password_reset/password_reset_bloc.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    Supabase.instance.client.auth.signOut();
    super.dispose();
  }

  void _onSubmitNewPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _passwordController.text;
      context.read<PasswordResetBloc>().add(
        PasswordResetNewPasswordSubmitted(email: widget.email, password: newPassword),
      );
    }
  }

  void _handleSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Mật khẩu của bạn đã được đặt lại thành công.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Đăng nhập'),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleFailure(String error) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi đặt lại mật khẩu: $error'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu mới'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          if (state is PasswordResetSetPasswordFailure) {
            _handleFailure(state.error);
          } else if (state is PasswordResetSuccess) {
            _handleSuccess();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/animations/reset_pass.json',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Nhập mật khẩu mới cho tài khoản:',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    _buildPasswordField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu mới',
                      obscureText: _obscurePassword,
                      toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                        if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: 'Xác nhận mật khẩu mới',
                      obscureText: _obscureConfirmPassword,
                      toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                        if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    BlocBuilder<PasswordResetBloc, PasswordResetState>(
                      builder: (context, state) {
                        final isLoading = state is PasswordResetSubmitting;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          onPressed: isLoading ? null : _onSubmitNewPassword,
                          child: isLoading
                              ? SizedBox(
                            height: 24,
                            child: Lottie.asset(
                              'assets/animations/loading.json',
                            ),
                          )
                              : const Text('Lưu mật khẩu mới'),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: 'Nhập tại đây...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[400],
          ),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}