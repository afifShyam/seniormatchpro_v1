import 'dart:async';
import 'dart:developer';
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Add geolocator package
import 'package:intl/intl.dart';
//import 'package:location/location.dart';
import 'package:seniormatchpro_v1/view/signin_screen.dart';

class JobRequestsPage extends StatefulWidget {
  final String id;
  final String roleName;
  final String userId;
  final double latitude;
  final double longitude;

  const JobRequestsPage({Key? key,
         required this.id,
         required this.roleName,
         required this.userId,
         required this.latitude,
         required this.longitude})
      : super(key: key);

  @override
  State<JobRequestsPage> createState() => _JobRequestsPageState();
}

class _JobRequestsPageState extends State<JobRequestsPage> {

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');

  final DatabaseReference _databaseReferenceUser =
      FirebaseDatabase.instance.ref().child('user');

  final DatabaseReference _databaseReferenceLocation =
      FirebaseDatabase.instance.ref().child('Location');

  List<Map<String, dynamic>> jobRequests = [];
  Timer? _timer;
  Map<String, dynamic> userDetail = {};
  Position? caregiverPosition;

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
    userDetails();
    _startCountdownTimer();
    log('nama dia lah: ${widget.id}, ${widget.roleName}');
    _getLocation();
    _storelocation();
  }


  void _storelocation() {
    DatabaseReference _databaseReferenceLocation =
        FirebaseDatabase.instance.ref().child('locations');

    Location location = Location(
      userId: widget.userId,
      latitude: widget.latitude,
      longitude: widget.longitude,
    

    );

    _databaseReferenceLocation.push().set(location.toMap());


  }


  Future<void> _getLocation() async {
  try {
    caregiverPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    _databaseReferenceUser.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> requests = [];
        Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;

        for (var entry in values.entries) {
          if (entry.value is Map<dynamic, dynamic> &&
              entry.value.containsKey('id') &&
              entry.value['id'].toString() == widget.id &&
              entry.value['status'] == 'pending') {
            // Fetch the caregiver's position (latitude and longitude)
            requests.add({
              'key': entry.key,
              ...entry.value,
              'latitude': caregiverPosition!.latitude,  // Store latitude
              'longitude': caregiverPosition!.longitude,  // Store longitude
            });
          }
        }
      }
    });
  } catch (e) {
    print("Error getting location: $e");
  }
}



  void _loadJobRequests() {
  _databaseReference.onValue.listen((event) async {
    if (event.snapshot.value != null) {
      List<Map<String, dynamic>> requests = [];
      Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;

      for (var entry in values.entries) {
        if (entry.value is Map<dynamic, dynamic> &&
            entry.value.containsKey('id') &&
            entry.value['id'].toString() == widget.id &&
            entry.value['status'] == 'pending') {
          

          requests.add({
            'key': entry.key,
            ...entry.value,
            'username': entry.value['username'],
            'remainingTimeSeconds': _calculateRemainingTime(entry.value['createdAt']),
          });
        }
      }
      setState(() {
        jobRequests = requests;
      });

      _startCountdownTimer();
    }
  });
}


  void userDetails() {
    _databaseReferenceUser.child('Caregiver').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> user = {};
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value.containsKey('id') && value['id'].toString() == widget.id) {
            user = {
              'key': key,
              'age': value['age'],
              'remainingTimeSeconds':
                  _calculateRemainingTime(value['createdAt']),
              'latitude': value['latitude'] ?? 0.0,
              'longitude': value['longitude'] ?? 0.0,
              
            };
          }
        });
        setState(() {
          userDetail = user;
        });
      }
    });
  }

  bool _isMatchingUser(Map<dynamic, dynamic> value) {
    return value.containsKey('id') && value['id'].toString() == widget.id;
  }

  int _calculateRemainingTime(dynamic createdAt) {
    DateTime createdDateTime = createdAt is int
        ? DateTime.fromMillisecondsSinceEpoch(createdAt)
        : DateTime.parse(createdAt);

    Duration totalDuration = const Duration(days: 1);
    Duration elapsedDuration = DateTime.now().difference(createdDateTime);
    return totalDuration.inSeconds - elapsedDuration.inSeconds;
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (var request in jobRequests) {
          request['remainingTimeSeconds'] =
              _calculateRemainingTime(request['createdAt']);
        }
      });
    });
  }

  Future<void> _updateStatus(String key, String newStatus) async {
    if (newStatus == 'rejected' || newStatus == 'accepted') {
      await _databaseReference.child(key).update({'status': newStatus});

      setState(() {
        jobRequests.removeWhere((request) => request['key'] == key);
      });

      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('Job Requests'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
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
      body: Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: _buildJobRequestsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobRequestsList() {
    return jobRequests.isEmpty
        ? const Center(
            child: Text('No job requests available.'),
          )
        : ListView.builder(
            itemCount: jobRequests.length,
            itemBuilder: (context, index) {
              return _buildJobRequestCard(jobRequests[index]);
            },
          );
  }

  Widget _buildJobRequestCard(Map<String, dynamic> request) {
    int remainingTimeSeconds = request['remainingTimeSeconds'];

    String remainingTimeFormatted = Duration(seconds: remainingTimeSeconds)
        .toString()
        .split('.')
        .first
        .padLeft(8, '0');

    DateTime performingDate =
        DateTime.fromMillisecondsSinceEpoch(request['createdAt']);
    String formattedPerformingDate =
        DateFormat('dd-MM-yyyy hh:mm a').format(performingDate);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '${request['jobName']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${request['location']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text('Email: ${request['email']}'),
                const SizedBox(height: 8),
                Text(
                  'Performing Date and Time: $formattedPerformingDate',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining Time: $remainingTimeFormatted',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: RM ${request['pricePerHour']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${request['latitude']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Longitude: ${request['longitude']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _updateStatus(request['key'], 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _updateStatus(request['key'], 'rejected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
