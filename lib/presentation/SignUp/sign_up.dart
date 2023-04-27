import 'dart:io';

import 'package:bloc_auth/bloc/bloc/auth_bloc.dart';
import 'package:bloc_auth/presentation/Dashboard/dashboard.dart';
import 'package:bloc_auth/presentation/SignIn/sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../profile/create_profile.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration hnologies "),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigating to the dashboard screen if the user is authenticated
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
          if (state is AuthError) {
            // Displaying the error message if the user is not authenticated
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            // Displaying the loading indicator while the user is signing up
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UnAuthenticated) {
            // Displaying the sign up form if the user is not authenticated
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "SignUpPage",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .color,
                                //key: const Key('passwordField'),
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.text,
                                obscureText: false,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  fillColor: Colors.white,
                                  labelText: 'Email',
                                  hintText: 'Enter Email',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.black38),
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                controller: _emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  return value != null &&
                                          !EmailValidator.validate(value)
                                      ? 'Enter a valid email'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                // key: const Key('PhoneField'),
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .color,
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.password,
                                    size: 28,
                                  ),
                                  fillColor: Colors.white,
                                  hintText: 'Enter Password',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.black38),
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'password is required.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _createAccountWithEmailAndPassword(context);
                                  },
                                  child: const Text('Sign Up'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Text("Already have an account?"),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignIn()),
                          );
                        },
                        child: const Text("Sign In"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  void _createAccountWithEmailAndPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
          SignUpRequested(_emailController.text, _passwordController.text));
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }
}
