import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/auth_page.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_event.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_state.dart';
import 'package:supabase_flutter_app/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionBloc()..add(SessionCheckRequested()),
      child: const AuthWrapperView(),
    );
  }
}

class AuthWrapperView extends StatelessWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        print('Current state: ${state.status}');
        if (state.status == SessionStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.isAuthenticated && state.status == SessionStatus.success) {
          return HomeScreen();
        } else if (state.status == SessionStatus.failure) {
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
        return const AuthScreen();
      },
    );
  }
}