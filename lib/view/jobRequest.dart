import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seniormatchpro_v1/view/signin_screen.dart';

class JobRequestsPage extends StatefulWidget {
  final String id;
  final String roleName;

  const JobRequestsPage({super.key, required this.id, required this.roleName});

  @override
  State<JobRequestsPage> createState() => _JobRequestsPageState();
}

class _JobRequestsPageState extends State<JobRequestsPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');
  final DatabaseReference _databaseReferenceUser =
      FirebaseDatabase.instance.ref().child('user');

  List<Map<String, dynamic>> jobRequests = [];
  Timer? _timer;
  Map<String, dynamic> userDetail = {};

  @override
  void initState() {
    _loadJobRequests();
    userDetails();
    _startCountdownTimer();
    log('nama dia lah: ${widget.id}, ${widget.roleName}');
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadJobRequests() {
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> requests = [];
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value.containsKey('id') &&
              value['id'].toString() == widget.id &&
              (value['status'] == 'pending')) {
            requests.add({
              'key': key,
              ...value,
              'uername': value['username'],
              'remainingTimeSeconds':
                  _calculateRemainingTime(value['createdAt']),
            });
          }
        });

        requests.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

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
            };
            log('nama dia lah 1${user}');
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
    if (newStatus == 'accepted') {
      bool canAccept = true;

      // Fetch the job to be accepted
      DatabaseReference jobToAcceptRef = _databaseReference.child(key);
      DatabaseEvent snapshot = await jobToAcceptRef.once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> jobToAcceptData =
            snapshot.snapshot.value as Map<dynamic, dynamic>;

        // Extract performing date and duration of the job to be accepted
        DateTime jobToAcceptPerformingDate =
            DateTime.parse(jobToAcceptData['performingDate']);
        int jobToAcceptDuration = int.parse(jobToAcceptData['duration']);

        // Check if accepting this job will cause timing conflict with any existing accepted job
        for (var request in jobRequests) {
          if (request['status'] == 'accepted') {
            DateTime existingJobPerformingDate =
                DateTime.parse(request['performingDate']);
            int existingJobDuration = int.parse(request['duration']);

            if (existingJobPerformingDate.isBefore(jobToAcceptPerformingDate) &&
                existingJobPerformingDate
                    .add(Duration(hours: existingJobDuration))
                    .isAfter(jobToAcceptPerformingDate)) {
              // Conflicting timing found, cannot accept the job
              canAccept = false;
              break;
            } else if (jobToAcceptPerformingDate
                    .isBefore(existingJobPerformingDate) &&
                jobToAcceptPerformingDate
                    .add(Duration(hours: jobToAcceptDuration))
                    .isAfter(existingJobPerformingDate)) {
              // Conflicting timing found, cannot accept the job
              canAccept = false;
              break;
            }
          }
        }

        if (canAccept) {
          await jobToAcceptRef.update({'status': newStatus});
          setState(() {
            jobRequests.removeWhere((request) => request['key'] == key);
          });
          _timer?.cancel();
        } else {
          // Show error message or alert to the user indicating the timing conflict
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Timing Conflict'),
                content: Text(
                    'You cannot accept this job due to timing conflict with another accepted job.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } else if (newStatus == 'rejected') {
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
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Text.rich(
              //     TextSpan(
              //       text: 'Hi, ',
              //       style: const TextStyle(fontSize: 17, color: Colors.black),
              //       children: [
              //         TextSpan(
              //           text: '${userDetail['age']}',
              //           style: const TextStyle(
              //             color: Colors.purple,
              //             fontSize: 20,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateStatus(request['key'], 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(request['key'], 'rejected'),
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
