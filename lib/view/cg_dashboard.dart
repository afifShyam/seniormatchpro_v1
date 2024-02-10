import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 60), (Timer t) {
      fetchData();
    });

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((position) {
      setState(() {
        userPosition = position;
      });
    });
  }

  @override
  void dispose() {
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
                    value.containsKey('username') &&
                    value.containsKey('latitude') &&
                    value.containsKey('longitude')) {
                  double caregiverLatitude = value['latitude'];
                  double caregiverLongitude = value['longitude'];

                  double distanceInMeters = userPosition != null
                      ? Geolocator.distanceBetween(
                          userPosition!.latitude,
                          userPosition!.longitude,
                          caregiverLatitude,
                          caregiverLongitude,
                        )
                      : 0;

                  userData.add({
                    'userId': key,
                    'username': value['username'],
                    'online': value['online'] ?? 'No Online',
                    'email': value['email'] ?? 'No Email',
                    'image': value['image'] ?? 'No Image',
                    'role': value['role'] ?? 'No Role',
                    'id': value['id'] ?? 'No Id',
                    'position': value['position'] ?? 'Noposition',
                    'latitude': caregiverLatitude,
                    'longitude': caregiverLongitude,
                    'distance': distanceInMeters,
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
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView.builder(
          itemCount: userData.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HirePage(
                      jobIdUser: widget.id,
                      id: userData[index]['id'].toString(),
                      name: userData[index]['username'].toString(),
                    ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(
                                id: userData[index]['id'].toString(),
                                roleName: 'Caregiver', 
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage(userData[index]['image'].toString()),
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
                          Text(
                            'Distance: ${(userData[index]['distance'] ?? 0) / 1000} km',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
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
    );
  }
}
