import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seniormatchpro_v1/index.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  String dropdownValue = 'Elders';
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
      body: BlocProvider(
        create: (context) => SignupAuthenticationBloc(),
        child:
            BlocListener<SignupAuthenticationBloc, SignupAuthenticationState>(
          listener: (context, state) {
            if (state.signupStatus == SignupStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error,
                  ),
                ),
              );
              log(state.error);
            } else if (state.signupStatus == SignupStatus.completed) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CgDashboard()),
              );
            }
          },
          child: bodyContent(context),
        ),
      ),
    );
  }

  Widget bodyContent(BuildContext context) {
    return Container(
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
                alignment: AlignmentDirectional.center,
                value: dropdownValue,
                items: <String>[
                  'Elders',
                  'Caregiver',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      textAlign: TextAlign.center,
                      value,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                      ),
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
                  fillColor: Colors.white.withOpacity(0.3),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: imageFile != null
                          ? FileImage(imageFile!)
                          : const AssetImage(
                                  'assets/images/placeholder_image.png')
                              as ImageProvider<Object>,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              firebaseUIButton(
                context,
                "Sign Up",
                () {
                  _signUp(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void _signUp(BuildContext context) {
    final signupBloc = context.read<SignupAuthenticationBloc>();

    if (_validateInputs()) {
      signupBloc.add(
        SignUpRealtimeDatabaseUser(
          username: _userNameTextController.text,
          email: _emailTextController.text,
          password: _passwordTextController.text,
          role: dropdownValue,
          image: imageFile!.path,
        ),
      );

      signupBloc.add(
        SignUpAuthenticationUser(
          email: _emailTextController.text,
          password: _passwordTextController.text,
        ),
      );
    }
  }

  bool _validateInputs() {
    // Implement your validation logic here
    return true;
  }

  Widget reusableTextField(String hintText, IconData icon, bool obscureText,
      TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget firebaseUIButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
