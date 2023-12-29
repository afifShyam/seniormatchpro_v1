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
                      return firebaseUIButton(context, "Sign In", () async {
                        context.read<SignupAuthenticationBloc>().add(
                              SignInUser(
                                email: _emailTextController.text,
                                password: _passwordTextController.text,
                              ),
                            );

                        if (state.signupStatus == SignupStatus.completed) {
                          try {
                            String role = await getUserRoleSomehow();
                            String userId = await getUserIdSomehow();

                            if (role == 'Elders') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AcceptedRequestsPage(userId: userId),
                                ),
                              );
                            } else if (role == 'Caregiver') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CgDashboard(),
                                ),
                              );
                            } else {
                              // Handle unexpected role or navigate to a default screen
                            }
                          } catch (e) {
                            log(state.error);
                            // Handle errors
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

  Future<String> getUserRoleSomehow() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final DatabaseReference _databaseReference =
            FirebaseDatabase.instance.ref().child('user');
        DataSnapshot dataSnapshot = await _databaseReference.get();

        if (dataSnapshot.value != null) {
          Map<String, dynamic> userData =
              (dataSnapshot.value! as Map<dynamic, dynamic>)
                  .cast<String, dynamic>();
          String role = userData['role'].toString();
          return role;
        } else {
          throw Exception('User data not found'); // Handle missing data
        }
      } else {
        throw Exception(
            'User not authenticated'); // Handle unauthenticated case
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      // Consider logging or displaying appropriate error messages
      rethrow; // Rethrow the exception to allow higher-level handling
    }
  }

  Future<String> getUserIdSomehow() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child('Users')
            .child(firebaseUser.uid);

        // Retrieve user data using `get()` instead of `once()`
        DataSnapshot snapshot = await databaseReference.get();

        if (snapshot.value != null) {
          Map<String, dynamic> userData =
              (snapshot.value! as Map<dynamic, dynamic>)
                  .cast<String, dynamic>();
          String userId = userData['id'].toString();
          return userId;
        } else {
          throw Exception('User data not found'); // Handle missing data
        }
      } else {
        throw Exception(
            'User not authenticated'); // Handle unauthenticated case
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      // Consider logging or displaying appropriate error messages
      rethrow; // Rethrow the exception to allow higher-level handling
    }
  }
}
