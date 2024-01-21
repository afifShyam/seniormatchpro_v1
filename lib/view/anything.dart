import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.id, required this.roleName});

  final String id;
  final String roleName;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isOnline = false;
  double userRating = 4.5; // Set the user's rating dynamically
  Map<String, dynamic> userDetail1 = {}; // Add this line to declare userDetail1
  final DatabaseReference _databaseReferenceUser =
      FirebaseDatabase.instance.ref().child('user');

  @override
  void initState() {
    super.initState();
    userDetails(); // Call userDetails when the state is initialized
  }

  void userDetails() {
    // Assuming you have a reference to your Firebase database (_databaseReferenceUser)
    _databaseReferenceUser.child(widget.roleName).onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          Map<String, dynamic> userDetail = {};
          Map<dynamic, dynamic> values =
              event.snapshot.value as Map<dynamic, dynamic>;

          values.forEach((key, value) {
            print('Key: $key, Value: $value');
            if (value is Map<dynamic, dynamic> &&
                value.containsKey('id') &&
                value['id'].toString() == widget.id) {
              userDetail = {
                'key': key,
                'username': value['username'],
                'jobName': value['jobName'],
                'location': value['location'],
                'email': value['email'],
                'status': value['status'],
                'createdAt': value['createdAt'],
                'priceOffer': value['priceOffer'],
                'id': value['id'],
                'jobId': value['jobId'],
              };

              // Process userDetail as needed (e.g., display in UI or perform some other action)
              print('User Details: $userDetail');
            }
          });

          // You may perform additional actions here if needed
          setState(() {
            userDetail1 = userDetail;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your existing build method goes here
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple, // Set the background color to dark purple
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display user face in a circular avatar at the top center
              const Center(
                child: CircleAvatar(
                  radius: 50, // Adjust the radius as needed
                  backgroundImage: AssetImage(
                      'assets/user_face_image.jpg'), // Replace with the actual image path
                ),
              ),
              const SizedBox(height: 20),
              // Container for user details with shadow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Set the container color to white
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
                          color: Colors.black), // Set text color to black
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Age: ${userDetail1['age'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Experience: ${userDetail1['experience'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${userDetail1['email'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Switch for online status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Online Status:',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (value) {
                      setState(() {
                        isOnline = value;
                      });
                    },
                    activeColor: Colors.purple,
                    inactiveThumbColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Fixed star rating for the user (read-only)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Star Rating: ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  RatingBar.builder(
                    itemSize: 20,
                    initialRating: userRating, // Use the dynamic rating here
                    allowHalfRating: true,
                    itemBuilder: (_, __) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (_) {
                      // Rating update is not allowed
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Container for user reviews with shadow
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the container color to white
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
                            color: Colors.black), // Set text color to black
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
                            // Add more ListTile widgets as needed
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
