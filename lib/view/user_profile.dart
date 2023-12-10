import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.name, required this.email}) : super(key: key);

  final String name;
  final String email;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.name),
              background: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.jpg'),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Name: ${widget.name}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email: ${widget.email}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text('Phone: 123-456-7890'),
                      Text('Address: 123 Main St, City'),
                      Text('Experience: 5 years'),
                      Text('Age: 30'),
                      Text('Gender: Female'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add any action you want to perform when the button is pressed
          print('Edit Profile Pressed');
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserProfile(name: 'John Doe', email: 'john.doe@example.com'),
  ));
}