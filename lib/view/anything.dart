import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseReference = FirebaseDatabase.instance.reference();

  TextEditingController emailController = TextEditingController();
  String userData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Data Retrieval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Enter Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchData();
              },
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 20),
            Text('User Data: $userData'),
          ],
        ),
      ),
    );
  }

  void fetchData() async {
    String email = emailController.text.trim();

    // Assuming your database structure is like: user/{id}/{data}
    // Replace 'email' with the field name in your database
    DatabaseEvent dataSnapshot = await databaseReference
        .child('user')
        .orderByChild('email')
        .equalTo(email)
        .once();

    if (dataSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> userMap =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      userMap.forEach((key, value) {
        setState(() {
          userData = value.toString();
        });
      });
    } else {
      setState(() {
        userData = 'No user found with this email';
      });
    }
  }
}
