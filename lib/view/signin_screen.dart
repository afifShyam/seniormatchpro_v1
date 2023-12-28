import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seniormatchpro_v1/index.dart';
import 'package:firebase_database/firebase_database.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField(
                  "Enter Email",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(
                  height: 5,
                ),
                forgetPassword(context),
                BlocProvider(
                  create: (context) => SignupAuthenticationBloc(),
                  child: BlocBuilder<SignupAuthenticationBloc,
                      SignupAuthenticationState>(
                    builder: (context, state) {
                      return firebaseUIButton(context, "Sign In", () {
                        context.read<SignupAuthenticationBloc>().add(
                              SignInUser(
                                email: _emailTextController.text,
                                password: _passwordTextController.text,
                              ),
                            );
                        if (state.signupStatus == SignupStatus.completed) {
                          log('${state.databaseReference.child('Users').child('id')}');

                          if (state.databaseReference.path
                              .contains('Elders')) {}
                          Users user =
                              getUserSomehow(); // Replace with your logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CgDashboard(),
                              // JobRequestsPage(user: user),
                            ),
                          );
                        }
                        if (state.signupStatus == SignupStatus.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.error,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResetPassword(),
          ),
        ),
      ),
    );
  }

  Users getUserSomehow() {
    // Replace this with the actual logic to retrieve the authenticated user
    // Example: If you are using Firebase Authentication
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // You may need to map FirebaseUser properties to your User model
      return Users(
        id: 0,
        username: firebaseUser.displayName ?? 'No Username',
        email: firebaseUser.email ?? 'No Email',
        role: 'Elders', // You may need additional logic to determine the role
      );
    } else {
      // Handle the case where the user is not authenticated
      // You may navigate to the sign-in screen or take appropriate action
      throw Exception('User not authenticated');
    }
  }
}
