import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/auth_page.dart';
import 'package:supabase_flutter_app/bloc/auth_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth_event.dart';
import 'package:supabase_flutter_app/bloc/auth_state.dart';
import 'package:supabase_flutter_app/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheck()),
      child: const AuthWrapperView(),
    );
  }
}

class AuthWrapperView extends StatelessWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('Current state: ${state.status}');
        if (state.status == AuthStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.isAuthenticated && state.status == AuthStatus.success) {
          return HomeScreen();
        } else if (state.status == AuthStatus.failure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('ERROR'),
                content: Text('Failed to authenticate'),
              ),
            );
          }
          );
          return const AuthScreen();
        }
        // Thêm xử lý cho các trạng thái khác nếu cần thiết
        return const AuthScreen(); // Trả về AuthScreen khi không có lỗi hay loading hoặc success
      },
    );
  }
}