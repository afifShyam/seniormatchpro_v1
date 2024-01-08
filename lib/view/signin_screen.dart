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
  String roleEnter = '';

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
                            String userId1 = await userIdCaregiver(
                                _emailTextController.text);
                            log('id dia sekarang $userId1');

                            if (userId1 == 'Elders') {
                              String roleElders =
                                  await userIdElders(_emailTextController.text);
                              String role = await getUserIdSomehow(roleElders);
                              setState(() {
                                roleEnter = role;
                              });
                            } else {
                              String role = await getUserIdSomehow(userId1);
                              setState(() {
                                roleEnter = role;
                              });
                            }

                            if (roleEnter == 'Elders' && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AcceptedRequestsPage(userId: roleEnter),
                                ),
                              );
                              // } else if (role == 'Caregiver' && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CgDashboard(),
                                ),
                              );
                            } else {
                              // Handle unexpected role or navigate to a default screen
                            }
                          } catch (e) {
                            log('error :${state.error}');
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

  // Future<String> getUserRoleSomehow() async {
  //   try {
  //     User? firebaseUser = FirebaseAuth.instance.currentUser;

  //     if (firebaseUser != null) {
  //       final DatabaseReference databaseReference =
  //           FirebaseDatabase.instance.ref().child('user').child('1');
  //       DataSnapshot dataSnapshot = await databaseReference.get();

  //       if (dataSnapshot.value != null) {
  //         Map<String, dynamic> userData =
  //             (dataSnapshot.value! as Map<dynamic, dynamic>)
  //                 .cast<String, dynamic>();
  //         String role = userData['role'].toString();
  //         return role;
  //       } else {
  //         throw Exception('User data not found'); // Handle missing data
  //       }
  //     } else {
  //       throw Exception(
  //           'User not authenticated'); // Handle unauthenticated case
  //     }
  //   } catch (e) {
  //     // Handle any errors that may occur during the process
  //     // Consider logging or displaying appropriate error messages
  //     rethrow; // Rethrow the exception to allow higher-level handling
  //   }
  // }

  Future<String> getUserIdSomehow(String role) async {
    Completer<String> completer = Completer<String>();

    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        DatabaseReference databaseReference =
            FirebaseDatabase.instance.ref().child('user').child(role);
        // .child('3');
        log('${firebaseUser.uid}');

        databaseReference.once().then((event) {
          DataSnapshot snapshot = event.snapshot;
          if (snapshot.value != null) {
            Map<String, dynamic> userData =
                (snapshot.value! as Map<dynamic, dynamic>)
                    .cast<String, dynamic>();
            String userId = userData['id'].toString();
            log('id-----${userId}');
            completer.complete(userId);
          } else {
            completer.completeError(Exception('User data not found'));
          }
        });
      } else {
        completer.completeError(Exception('User not authenticated'));
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<String> userIdCaregiver(
    String email,
  ) async {
    String id = 'Elders';

    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('user').child('Caregiver');

      final DatabaseEvent snapshot = await reference
          .orderByChild('email')
          .equalTo(email)
          .once(); // Use 'once' to retrieve the result
      log('message : ${snapshot.snapshot.value != null}');

      if (snapshot.snapshot.value != null) {
        // Username already exists, extract role and ID
        final Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String data = userMap.keys.first;
        String userRole = userMap[data]['role'];
        int userRole1 = userMap[data]['id'];

        // Now you can use userId and userRole as needed
        log('message : ${userRole}');

        setState(() => id = userRole);

        // return userRole;
      }
    } catch (error) {
      // Handle the error appropriately
      log('Error checking username existence: $error');
      // Consider showing an error message to the user
    }

    return id;
  }

  Future<String> userIdElders(
    String email,
  ) async {
    String id = 'Elders';

    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('user').child(id);

      final DatabaseEvent snapshot = await reference
          .orderByChild('email')
          .equalTo(email)
          .once(); // Use 'once' to retrieve the result
      log('message : ${snapshot.snapshot.value != null}');

      if (snapshot.snapshot.value != null) {
        // Username already exists, extract role and ID
        final Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String data = userMap.keys.first;
        String userRole = userMap[data]['role'];
        int userRole1 = userMap[data]['id'];

        // Now you can use userId and userRole as needed
        log('message : ${userRole}');

        setState(() => id = userRole);

        // return userRole;
      }
    } catch (error) {
      // Handle the error appropriately
      log('Error checking username existence: $error');
      // Consider showing an error message to the user
    }
    return id;
  }
}
