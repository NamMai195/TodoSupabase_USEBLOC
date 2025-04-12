import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_event.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_state.dart';
// Import PasswordReset Bloc, Event, State
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/password_reset/password_reset_event.dart';
// Import các Pages
import 'package:supabase_flutter_app/presentation/auth/verification_code_page.dart';
import 'package:supabase_flutter_app/presentation/home/home_page.dart';
import 'package:supabase_flutter_app/presentation/auth/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  // Controller riêng cho dialog quên mật khẩu
  final _emailResetController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailResetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => PasswordResetBloc()),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state == LoginState.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state == LoginState.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                    content:
                    Text('Đăng nhập thất bại. Vui lòng kiểm tra lại.')),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state == LoginState.loading;

          return Scaffold(
            backgroundColor: Colors.grey[900],
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: _loginForm(isLoading, context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitLogin(BuildContext context, bool isLoading) {
    if (isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      context.read<LoginBloc>().add(
        LoginRequested(
          email: email,
          password: password,
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
              content: Text('Vui lòng kiểm tra lại thông tin nhập.')),
        );
    }
  }

  Form _loginForm(bool isLoading, BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: FlutterLogo(size: 80),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập địa chỉ email của bạn',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Vui lòng nhập Email';
                if (!value.contains('@')) return 'Email không hợp lệ';
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordObscured
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
              ),
              obscureText: _isPasswordObscured,
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Vui lòng nhập Mật khẩu';
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (_) => _submitLogin(context, isLoading),
            ),
            const SizedBox(height: 24.0),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => _submitLogin(context, isLoading),
                    child:
                    const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const SignupPage()),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Đăng ký'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _emailResetController.clear();
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Quên Mật Khẩu'),
                                  content: TextField(
                                    controller: _emailResetController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập email của bạn',
                                      labelText: 'Email',
                                    ),
                                    autofocus: true,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Hủy'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Gửi'),
                                      onPressed: () {
                                        final email = _emailResetController.text.trim();
                                        if (email.isNotEmpty && email.contains('@')) {
                                          Navigator.of(dialogContext).pop();
                                          context.read<PasswordResetBloc>().add(
                                              PasswordResetSendOtpRequested(email: email)
                                          );

                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Đang gửi yêu cầu tới $email...'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider.value(
                                                value: BlocProvider.of<PasswordResetBloc>(context),
                                                child: VerificationCodePage(email: email),
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(dialogContext)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
                                            );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Quên mật khẩu?'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}