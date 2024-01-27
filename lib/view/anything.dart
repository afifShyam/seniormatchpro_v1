import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:seniormatchpro_v1/index.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.id, required this.roleName});

  final String id;
  final String roleName;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isOnline = false;
  double userRating = 4.5;
  Map<String, dynamic> userDetail1 = {};
  final DatabaseReference _databaseReferenceUser =
      FirebaseDatabase.instance.ref().child('user');

  @override
  void initState() {
    super.initState();
    userDetails();
  }

  void userDetails() {
    _databaseReferenceUser.child(widget.roleName).onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          Map<String, dynamic> userDetail = {};
          Map<dynamic, dynamic> values =
              event.snapshot.value as Map<dynamic, dynamic>;

          values.forEach((key, value) {
            if (value is Map<dynamic, dynamic> &&
                value.containsKey('id') &&
                value['id'].toString() == widget.id) {
              userDetail = {
                'key': key,
                'username': value['username'],
                'age': value['age'],
                'location': value['location'],
                'email': value['email'],
                'experience': value['experience'],
                'createdAt': value['createdAt'],
                'image': value['image'],
                'id': value['id'],
                'phoneNumber': value['phoneNumber'],
                'role': value['role'],
              };

              setState(() {
                userDetail1 = userDetail;
                isOnline = value['online'] ?? false;
              });
            }
          });
        }
      },
    );
  }

  void updateOnlineStatus(bool online) {
    _databaseReferenceUser
        .child(widget.roleName)
        .child(userDetail1['key'])
        .update({'online': online});
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const SizedBox(),
        title: const Text('User Profile'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage(userDetail1['image'].toString()),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.purple,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username: ${userDetail1['username'] ?? 'no'}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Age: ${userDetail1['age'] ?? ''} years old',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Visibility(
                      visible: widget.roleName != 'Elders',
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Experience: ${userDetail1['experience'] ?? ''} years',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${userDetail1['email'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Role: ${userDetail1['role'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone Number: ${userDetail1['phoneNumber'] ?? '-'}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: widget.roleName != 'Elders',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Online Status:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Visibility(
                      visible: widget.roleName != 'Elders',
                      child: Switch(
                        value: isOnline,
                        onChanged: (value) {
                          setState(() {
                            isOnline = value;
                          });
                          updateOnlineStatus(value);
                        },
                        activeColor: Colors.purple,
                        inactiveThumbColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: widget.roleName != 'Elders',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Star Rating: ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    RatingBar.builder(
                      itemSize: 20,
                      initialRating: userRating,
                      allowHalfRating: true,
                      itemBuilder: (_, __) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (_) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: widget.roleName != 'Elders',
                child: Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.purple,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Reviews from Users:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: const [
                              ListTile(
                                title: Text('User1: Great service!'),
                                subtitle: Text('Rating: 5.0',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              ListTile(
                                title: Text('User2: Excellent work!'),
                                subtitle: Text('Rating: 4.0',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Set the button color to red
                ),
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
