import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/auth_wrapper.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth/session/session_event.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>(
          create: (context) => SessionBloc()..add(SessionCheckRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'My App',
        home: const AuthWrapper(),
      ),
    );
  }
}