import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seniormatchpro_v1/index.dart';
import 'package:firebase_database/firebase_database.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String userRole = '';

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
                const SizedBox(height: 30),
                reusableTextField(
                  "Enter Email",
                  Icons.person_outline,
                  false,
                  _emailController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordController,
                ),
                const SizedBox(height: 5),
                forgetPassword(context),
                BlocProvider(
                  create: (context) => SignupAuthenticationBloc(),
                  child: BlocBuilder<SignupAuthenticationBloc,
                      SignupAuthenticationState>(
                    builder: (context, state) {
                      return firebaseUIButton(context, "Sign In", () async {
                        context.read<SignupAuthenticationBloc>().add(
                              SignInUser(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );

                        if (state.signupStatus == SignupStatus.completed) {
                          try {
                            String userId =
                                await _getUserIdByEmail(_emailController.text);

                            if (userId == 'Elders') {
                              String roleElders =
                                  await _getUserIdElders(_emailController.text);

                              userRole = await _getUserRole(
                                  userId, _emailController.text);
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavbar(id: userRole),
                                  ),
                                );
                              }
                            } else {
                              userRole = await _getUserRole(
                                  userId, _emailController.text);
                              log('tahi kamu:$userRole');

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavbarCaregivers(id: userRole),
                                  ),
                                );
                              }
                            }
                            log(userId);
                          } catch (e) {
                            log('error :${state.error}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        if (state.signupStatus == SignupStatus.error &&
                            context.mounted) {
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
                signUpOption(),
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
        const Text("Don't have an account?",
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

  Future<String> _getUserIdByEmail(String email) async {
    String userId = 'Elders';

    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('user').child('Caregiver');

      final DatabaseEvent snapshot =
          await reference.orderByChild('email').equalTo(email).once();

      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String data = userMap.keys.first;
        userId = userMap[data]['role'];
        // setState(() => userId = userMap[data]['id'].toString());
      }
    } catch (error) {
      log('Error getting user ID: $error');
    }

    return userId;
  }

  Future<String> _getUserIdElders(String email) async {
    String userId = 'Elders';

    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('user').child(userId);

      final DatabaseEvent snapshot =
          await reference.orderByChild('email').equalTo(email).once();

      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String data = userMap.keys.first;
        userId = userMap[data]['role'];
        // setState(() => userId = userMap[data]['id'].toString());
      }
    } catch (error) {
      log('Error getting user ID: $error');
    }

    return userId;
  }

  Future<String> _getUserRole(String userId, String email) async {
    String userRole = '';

    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('user').child(userId);

      final DatabaseEvent snapshot =
          await reference.orderByChild('email').equalTo(email).once();

      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String data = userMap.keys.first;
        userRole = userMap[data]['id'].toString();
      }
    } catch (error) {
      log('Error getting user role: $error');
    }

    return userRole;
  }
}
