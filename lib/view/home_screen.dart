import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:seniormatchpro_v1/index.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: ElevatedButton(
          child: const Text("Logout"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              if (kDebugMode) {
                print("Signed Out");
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()));
            });
          },
        ),
        backgroundColor: Colors.yellowAccent,
        title: const Text(
          'Dashborad',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          ),
        ],
      ),
    );
  }
}
