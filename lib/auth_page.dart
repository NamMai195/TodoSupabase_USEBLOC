import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_event.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_state.dart';
import 'package:supabase_flutter_app/home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
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
                const SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại.')),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state == LoginState.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Đăng nhập / Đăng ký'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading, // Disable khi loading
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    obscureText: true,
                    enabled: !isLoading, // Disable khi loading
                  ),
                  const SizedBox(height: 20),

                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            if (email.isNotEmpty && password.isNotEmpty) {
                              context.read<LoginBloc>().add(
                                LoginRequested(
                                  email: email,
                                  password: password,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
                                const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu')),
                              );
                            }
                          },
                          child: const Text('Đăng nhập'),
                        ),
                        const SizedBox(height: 10),
                        // Nút Đăng ký -> Dispatch AuthLogin
                        // TextButton(
                        //   onPressed: () {
                        //     final email = _emailController.text.trim();
                        //     final password = _passwordController.text.trim();
                        //     if (email.isNotEmpty && password.isNotEmpty) {
                        //       context.read<AuthScreenBloc>().add(
                        //         AuthLogin(
                        //           email: email,
                        //           password: password,
                        //         ),
                        //       );
                        //     } else {
                        //       ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
                        //         const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu')),
                        //       );
                        //     }
                        //   },
                        //   child: const Text('Chưa có tài khoản? Đăng ký'),
                        // ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}