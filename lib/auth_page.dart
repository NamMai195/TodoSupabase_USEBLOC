import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/authScreenBloc/authScreen_bloc.dart';
import 'package:supabase_flutter_app/bloc/authScreenBloc/authScreen_state.dart';
import 'package:supabase_flutter_app/home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _supabase = Supabase.instance.client;
  //
  // bool _isLoading = false;
  //
  // Future<void> _signUp() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await _supabase.auth.signUp(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (response.user != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Sign up successful! Please check your email.')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error during sign up: $e')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  //
  // Future<void> _signIn() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await _supabase.auth.signInWithPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (response.user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomeScreen()),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error during sign in: $e')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _signOut() async {
  //   await _supabase.auth.signOut();
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => AuthScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthScreenBloc(),
      child: BlocConsumer(
        listener: (context, state) {
          if(state == AuthscreenState.success){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          else if(state == AuthscreenState.failure){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error during sign in: $state')),
            );
          }
        },
        builder:(context,state) {
          return  Scaffold(
            appBar: AppBar(
              title: Text('Supabase Auth'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                 if(state == AuthscreenState.loading)){
                const CircularProgressIndicator();
          } else{
                ElevatedButton(
                onPressed: , child: child)
          }
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _signUp,
                    child: Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
          );
        }

      ),
    );
  }
}
