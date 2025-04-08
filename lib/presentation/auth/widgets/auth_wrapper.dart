import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/presentation/auth/login_page.dart';
import 'package:supabase_flutter_app/presentation/home/home_page.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_state.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthWrapperView();
  }
}

class AuthWrapperView extends StatelessWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        print('Current Session state: ${state.status}');
        if (state.status == SessionStatus.loading || state.status == SessionStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == SessionStatus.success) {
          return HomeScreen();
        }

        if (state.status == SessionStatus.failure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(context.mounted) {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Lỗi Phiên làm việc'),
                  content: Text('Không thể xác thực phiên làm việc.'),
                ),
              );
            }
          });
          return const LoginPage();
        }

        if (state.status == SessionStatus.success) {
          return const LoginPage();
        }

        return const LoginPage();
      },
    );
  }
}