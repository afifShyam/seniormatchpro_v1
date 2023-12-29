import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobRequestsPage extends StatefulWidget {
  final String id;

  const JobRequestsPage({Key? key, required this.id}) : super(key: key);

  @override
  _JobRequestsPageState createState() => _JobRequestsPageState();
}

class _JobRequestsPageState extends State<JobRequestsPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');

  List<Map<String, dynamic>> jobRequests = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
    _startCountdownTimer();
  }

  void _loadJobRequests() {
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> requests = [];
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          print('Key: $key, Value: $value');
          if (value is Map<dynamic, dynamic> &&
                  value.containsKey('id') &&
                  value['id'].toString() == widget.id &&
                  (value['status'] == 'accepted') ||
              value['status'] == 'pending') {
            requests.add({
              'key': key,
              'jobName': value['jobName'],
              'location': value['location'],
              'email': value['email'],
              'status': value['status'],
              'createdAt': value['createdAt'],
              'priceOffer': value['priceOffer'],
              'id': value['id'],
              'remainingTimeSeconds':
                  _calculateRemainingTime(value['createdAt']),
              'jobId': value['jobId'],
            });
          }
        });

        // Sort the requests by createdAt in descending order
        requests.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        setState(() {
          jobRequests = requests;
        });

        _startCountdownTimer();
      }
    });
  }

  int _calculateRemainingTime(dynamic createdAt) {
    if (createdAt is int) {
      DateTime createdDateTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
      Duration totalDuration = const Duration(days: 1);
      Duration elapsedDuration = DateTime.now().difference(createdDateTime);
      return totalDuration.inSeconds - elapsedDuration.inSeconds;
    } else if (createdAt is String) {
      DateTime createdDateTime = DateTime.parse(createdAt);
      Duration totalDuration = const Duration(days: 1);
      Duration elapsedDuration = DateTime.now().difference(createdDateTime);
      return totalDuration.inSeconds - elapsedDuration.inSeconds;
    }
    return 0;
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        jobRequests.forEach((request) {
          request['remainingTimeSeconds'] =
              _calculateRemainingTime(request['createdAt']);
        });
      });
    });
  }

  Future<void> _updateStatus(String key, String newStatus) async {
    if (newStatus == 'rejected') {
      // Only update the status to 'rejected' in the database
      await _databaseReference.child(key).update({'status': 'rejected'});
      setState(() {
        // Remove the request from the UI
        jobRequests.removeWhere((request) => request['key'] == key);
      });
    } else {
      await _databaseReference.child(key).update({'status': newStatus});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Requests'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildJobRequestsList(),
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
                  'Price: RM ${request['priceOffer']}',
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
                  onPressed: () {
                    _updateStatus(request['key'], 'accepted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateStatus(request['key'], 'rejected');
                  },
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

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }
}
