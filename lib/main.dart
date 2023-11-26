import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seniormatchpro_v1/firebase_options.dart';
import 'package:seniormatchpro_v1/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    // Handle Firebase initialization exceptions here.
    debugPrint("Firebase Initialization Error: ${e.toString()}");
  }

  runApp(BlocProvider(
    create: (context) => SignupAuthenticationBloc(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
        // Set other theme properties as needed.
      ),
      home: const SignInScreen(),
    );
  }
}
