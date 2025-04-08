import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_event.dart';
import 'package:supabase_flutter_app/bloc/auth/login/login_state.dart';
import 'package:supabase_flutter_app/presentation/home/home_page.dart';
// import 'package:supabase_flutter_app/presentation/auth/signup_page.dart'; // Import trang signup khi có

// 1. Đổi tên class thành LoginPage
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // 2. Đổi tên State tương ứng
  _LoginPageState createState() => _LoginPageState();
}

// 3. Đổi tên State và kế thừa từ State<LoginPage>
class _LoginPageState extends State<LoginPage> {
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
    // Cung cấp LoginBloc cục bộ cho màn hình này
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
                const SnackBar(content: Text('Đăng nhập thất bại. Vui lòng kiểm tra lại.')),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state == LoginState.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Đăng nhập'), // Giữ nguyên title
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
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : () {
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
                        // Nút điều hướng sang trang Đăng ký
                        TextButton(
                          onPressed: isLoading ? null : () {
                            // TODO: Thêm logic điều hướng đến trang Đăng ký (SignupPage)
                            // Ví dụ: Navigator.pushNamed(context, '/signup');
                            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
                              const SnackBar(content: Text('Điều hướng sang trang Đăng ký...')),
                            ); // Tạm thời thông báo
                          },
                          child: const Text('Chưa có tài khoản? Đăng ký'),
                        ),
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