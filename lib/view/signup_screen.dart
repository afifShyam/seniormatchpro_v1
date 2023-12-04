import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seniormatchpro_v1/index.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  String dropdownValue = 'Worker';
  File? imageFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _userNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: bodyContent(context),
    );
  }

  Widget bodyContent(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupAuthenticationBloc(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter UserName",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: dropdownValue,
                  items: <String>[
                    'Worker',
                    'Hirer',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontSize: 20), // Adjust the font size
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors
                        .transparent, // Set the background color to transparent
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () async {
                //     final pickedFile = await ImagePicker()
                //         .pickImage(source: ImageSource.gallery);
                //     if (pickedFile != null) {
                //       setState(() {
                //         imageFile = File(pickedFile.path);
                //         log(imageFile.toString());
                //       });
                //     }
                //   },
                //   child: Text("Pick Image"),
                // ),
                // const SizedBox(height: 20),
                BlocBuilder<SignupAuthenticationBloc,
                    SignupAuthenticationState>(
                  builder: (context, state) {
                    return firebaseUIButton(
                      context,
                      "Sign Up",
                      () {
                        context
                            .read<SignupAuthenticationBloc>()
                            .add(SignUpRealtimeDatabaseUser(
                              username: _userNameTextController.text,
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                              role: dropdownValue,
                              // image: imageFile!,
                            ));

                        context.read<SignupAuthenticationBloc>().add(
                            SignUpAuthenticationUser(
                                email: _emailTextController.text,
                                password: _passwordTextController.text));

                        if (state.signupStatus == SignupStatus.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.error,
                              ),
                            ),
                          );
                          log(state.error);
                        }
                        if (state.signupStatus == SignupStatus.completed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CgDashboard()),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
