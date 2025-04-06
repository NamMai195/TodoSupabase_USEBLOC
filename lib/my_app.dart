import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/auth_page.dart'; // Import AuthScreen
import 'package:supabase_flutter_app/auth_wrapper.dart';
import 'package:supabase_flutter_app/bloc/auth_bloc.dart'; // Import AuthBloc
import 'package:supabase_flutter_app/bloc/authScreenBloc/authScreen_bloc.dart';
import 'package:supabase_flutter_app/bloc/auth_event.dart'; // Import AuthScreenBloc


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheck()),
        ),
        BlocProvider<AuthScreenBloc>(
          create: (context) => AuthScreenBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'My App',
        home: const AuthWrapper(),
      ),
    );
  }
}