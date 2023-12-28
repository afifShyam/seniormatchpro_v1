import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:seniormatchpro_v1/view/index.dart';

class AcceptedJobListPage extends StatefulWidget {
  const AcceptedJobListPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _AcceptedJobListPageState createState() => _AcceptedJobListPageState();
}

class _AcceptedJobListPageState extends State<AcceptedJobListPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');

  List<Map<String, dynamic>> acceptedJobRequests = [];

  @override
  void initState() {
    super.initState();
    _loadAcceptedJobRequests();
  }

  void _loadAcceptedJobRequests() {
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> acceptedRequests = [];
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if ((value is Map<dynamic, dynamic>) &&
                  (value.containsKey('status') &&
                      value['status'] == 'done_task' &&
                      value['id'].toString() == widget.id) &&
                  value['id'].toString() == widget.id
              //         ||
              // (value['status'] == 'completed' &&
              //     value['id'].toString() == widget.id)
              ) {
            acceptedRequests.add({
              'key': key,
              'jobName': value['jobName'],
              'location': value['location'],
              'email': value['email'],
              'priceOffer': value['priceOffer'],
              'createdAt': value['createdAt'],
            });
          }
        });

        // Sort the accepted requests by createdAt in descending order
        acceptedRequests
            .sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        setState(() {
          acceptedJobRequests = acceptedRequests;
        });
      }
    });
  }

  void _makePayment(String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _amountController = TextEditingController();
        return AlertDialog(
          title: const Text('Make Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Amount'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Perform payment logic here
                  // For example, update the status to 'paid'
                  _updateStatus(key, 'completed');
                  Navigator.of(context).pop();
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(String key, String newStatus) {
    _databaseReference.child(key).update({'status': newStatus});
    // You can update other fields as needed
  }

  void _openReviewPage(String jobId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(jobId: jobId, userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Job List'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildAcceptedJobList(),
        ),
      ),
    );
  }

  Widget _buildAcceptedJobList() {
    return acceptedJobRequests.isEmpty
        ? const Center(
            child: Text('No accepted job requests available.'),
          )
        : ListView.builder(
            itemCount: acceptedJobRequests.length,
            itemBuilder: (context, index) {
              return _buildAcceptedJobCard(acceptedJobRequests[index]);
            },
          );
  }

  Widget _buildAcceptedJobCard(Map<String, dynamic> jobRequest) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${jobRequest['jobName']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${jobRequest['location']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text('Email: ${jobRequest['email']}'),
                const SizedBox(height: 8),
                Text(
                  'Price: RM ${jobRequest['priceOffer']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Move the button to the bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _makePayment(jobRequest['key']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Make Payment'),
                ),
                const Spacer(),
                if (jobRequest['status'] ==
                    'completed') // Show only for completed jobs
                  ElevatedButton(
                    onPressed: () =>
                        _openReviewPage(jobRequest['key'], widget.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Review'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
