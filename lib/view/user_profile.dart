import 'package:flutter/material.dart';

// User model class (replace this with your actual user model)
class UserProfile extends StatefulWidget{

  const UserProfile({Key? key, required this.name, required this.email}) : super(key: key);
  

  final String name;
  final String email;

  

  

   @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Hard-coded user data (replace this with your actual user data)
final UserProfile user = UserProfile(name: 'John Doe', email: 'john.doe@example.com');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              // You can replace this with an image from the network or device
              backgroundImage: AssetImage('assets/profile_image.jpg'),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${user.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add any action you want to perform when the button is pressed
                print('Edit Profile Pressed');
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}


