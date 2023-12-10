import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:seniormatchpro_v1/index.dart';

class CgDashboard extends StatefulWidget {
  const CgDashboard({Key? key}) : super(key: key);

  @override
  State<CgDashboard> createState() => _CgDashboardState();
}

class _CgDashboardState extends State<CgDashboard> {
  final dataUser = FirebaseDatabase.instance.ref().child('user');
  final databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DataSnapshot dataSnapshot = await dataUser.get();
      if (dataSnapshot.value != null) {
        final Map<dynamic, dynamic>? values =
            dataSnapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          values.forEach((key, value) {
            // Ensure 'value' is a Map and contains 'username' key
            if (value is Map<dynamic, dynamic> &&
                value.containsKey('username')) {
              userData.add({
                'userId': key,
                'username': value['username'],
                'status': value['status'] ?? 'No Status',
              });
            } else {
              print('Invalid data structure for key: $key');
            }
          });
        }
      }

      setState(() {});
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Job Offer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: ListView.builder(
          itemCount: userData.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HirePage(),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData[index]['username'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData[index]['status'] ?? 'No Status',
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.quick_contacts_mail_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}
