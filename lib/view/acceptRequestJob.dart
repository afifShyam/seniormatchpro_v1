// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptedRequestsPage extends StatefulWidget {
  final String userId;

  const AcceptedRequestsPage({
    super.key,
    required this.userId,
  });

  @override
  State<AcceptedRequestsPage> createState() => _AcceptedRequestsPageState();
}

class _AcceptedRequestsPageState extends State<AcceptedRequestsPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');

  List<Map<String, dynamic>> acceptedRequests = [];
  Timer? _timer;
  bool jobCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadAcceptedRequests();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  void _loadAcceptedRequests() {
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> accepted = [];
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
                  value.containsKey('id') &&
                  value['id'].toString() == widget.userId &&
                  value['status'] == 'accepted' ||
              value['status'] == 'processing') {
            accepted.add({
              'key': key,
              'jobName': value['jobName'],
              'location': value['location'],
              'email': value['email'],
              'status': value['status'],
              'createdAt': value['createdAt'],
              'priceOffer': value['priceOffer'],
              'performingDate': value['performingDate'],
              'showArrivedButton': true, // Initialize the flag
            });
          }
        });

        // Sort the accepted requests by createdAt in descending order
        accepted.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        setState(() {
          acceptedRequests = accepted;
        });
      }
    });
  }

  void _completeJob(String key) {
    _databaseReference.child(key).update({'status': 'done_task'});
    // You can update other fields as needed

    // Job is completed for the specific job, set the flag
    setState(() {
      acceptedRequests = acceptedRequests.map((request) {
        if (request['key'] == key) {
          return {
            ...request,
            'jobCompleted': true,
          };
        }
        return request;
      }).toList();
    });
  }

  void _arrived(String key) {
    _databaseReference.child(key).update({'status': 'processing'});

    // Disable the 'Arrived' button
    setState(() {
      acceptedRequests = acceptedRequests.map((request) {
        if (request['key'] == key) {
          return {
            ...request,
            'status': 'processing',
          };
        }
        return request;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('Accepted Requests'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildAcceptedRequestsList(),
        ),
      ),
      // bottomNavigationBar: BottomNavbarCaregivers(id: widget.userId),
    );
  }

  Widget _buildAcceptedRequestsList() {
    return acceptedRequests.isEmpty
        ? const Center(
            child: Text('No accepted requests available.'),
          )
        : ListView.builder(
            itemCount: acceptedRequests.length,
            itemBuilder: (context, index) {
              return _buildAcceptedRequestCard(acceptedRequests[index]);
            },
          );
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        acceptedRequests.forEach((request) {
          if (request['performingDate'] != null &&
              !(request['jobCompleted'] as bool? ?? false)) {
            int remainingTimeSeconds = (request['performingDate'] as int) -
                DateTime.now().millisecondsSinceEpoch;
            request['remainingTimeSeconds'] = remainingTimeSeconds ~/ 1000;

            if (remainingTimeSeconds <= 0) {
              // Job completed, set the flag for the specific job
              setState(() {
                acceptedRequests = acceptedRequests.map((map) {
                  if (map['key'] == request['key']) {
                    return {
                      ...map,
                      'jobCompleted': true,
                    };
                  }
                  return map;
                }).toList();
              });
            }
          }
        });
      });
    });
  }

  Widget _buildAcceptedRequestCard(Map<String, dynamic> request) {
    DateTime? performingDate =
        DateTime.fromMillisecondsSinceEpoch(request['performingDate'] ?? 0);
    String formattedPerformingDate = performingDate != null
        ? DateFormat('dd-MM-yyyy hh:mm a').format(performingDate)
        : 'N/A';

    int remainingTimeSeconds =
        request['remainingTimeSeconds'] as int? ?? 0; // Default to 0 if null
    String remainingTimeFormatted =
        Duration(seconds: remainingTimeSeconds).toString().split('.').first;

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
                    _completeJob(request['key']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Complete'),
                ),
                ElevatedButton(
                  onPressed: request['status'] == 'accepted'
                      ? () => _arrived(request['key'])
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Arrived'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
