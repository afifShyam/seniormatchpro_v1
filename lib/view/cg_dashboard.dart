import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:seniormatchpro_v1/index.dart';

class CgDashboard extends StatefulWidget {
  const CgDashboard({super.key, required this.id});

  final String id;

  @override
  State<CgDashboard> createState() => _CgDashboardState();
}

class _CgDashboardState extends State<CgDashboard> {
  final dataUser = FirebaseDatabase.instance.ref().child('user/Caregiver');
  final databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> userData = [];
  late Timer timer;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    // Set up a periodic timer to refresh data every 60 seconds
    timer = Timer.periodic(const Duration(seconds: 60), (Timer t) {
      fetchData();
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      dataUser.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final Map<dynamic, dynamic>? values =
              event.snapshot.value as Map<dynamic, dynamic>?;

          if (values != null) {
            setState(() {
              userData.clear();
              values.forEach((key, value) {
                if (value is Map<dynamic, dynamic> &&
                    value.containsKey('username')) {
                  userData.add({
                    'userId': key,
                    'username': value['username'],
                    'online': value['online'] ?? 'No Online',
                    'email': value['email'] ?? 'No Email',
                    'image': value['image'] ?? 'No Image',
                    'role': value['role'] ?? 'No Role',
                    'id': value['id'] ?? 'No Id',
                  });
                } else {
                  print('Invalid data structure for key: $key');
                }
              });
            });
          }
        }
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _searchUser(String query) {
    if (query.isEmpty) {
      // If the search query is empty, reset userData to display all users
      fetchData();
    } else {
      setState(() {
        userData = userData.where((user) {
          final username = user['username'].toLowerCase();
          final email = user['email'].toLowerCase();
          final searchLower = query.toLowerCase();

          return username.contains(searchLower) || email.contains(searchLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  // labelText: 'Search by name or email',
                  // labelStyle: TextStyle(
                  //   color: Colors.grey.shade500,
                  //   fontWeight: FontWeight.w500,
                  // ),
                  prefixIcon: const Icon(Icons.search, color: Colors.purple),
                  suffixIcon: searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            searchController.clear();
                            FocusScope.of(context).unfocus();
                            fetchData();
                          },
                          child: const Icon(Icons.close_outlined,
                              color: Colors.red),
                        )
                      : null,

                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.grey.shade100,
                  hintText: 'Enter Username',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 12.0),
                ),
                onChanged: _searchUser,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: userData[index]['online']
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HirePage(
                                    jobIdUser: widget.id,
                                    id: userData[index]['id'].toString(),
                                    name:
                                        userData[index]['username'].toString(),
                                  ),
                                ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${userData[index]['username']} is currently Offway'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                      child: Card(
                        elevation: 5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  log('id dashboard P:${userData[index]['id'].toString()}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfilePage(
                                        id: userData[index]['id'].toString(),
                                        roleName:
                                            'Caregiver', // Replace with the appropriate role
                                        userId: widget.id,
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      userData[index]['image'].toString()),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData[index]['username'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: userData[index]['online'] == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    child: Text(
                                      userData[index]['online'] == true
                                          ? 'Available'
                                          : 'Offway',
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.quick_contacts_mail_outlined),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
