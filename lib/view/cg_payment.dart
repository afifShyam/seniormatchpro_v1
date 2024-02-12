import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seniormatchpro_v1/view/index.dart';

class AcceptedJobListPage extends StatefulWidget {
  const AcceptedJobListPage({super.key, required this.id});

  final String id;

  @override
  State<AcceptedJobListPage> createState() => _AcceptedJobListPageState();
}

class _AcceptedJobListPageState extends State<AcceptedJobListPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');
  final DatabaseReference _reviewDB =
      FirebaseDatabase.instance.ref().child('reviews');

  List<Map<String, dynamic>> acceptedJobRequests = [];
  Map<String, dynamic> reviewLoadData = {};

  @override
  void initState() {
    super.initState();
    _loadAcceptedJobRequests();
    reviewData();
  }

  @override
  void dispose() {
    _databaseReference.onValue.drain(); // release resources
    super.dispose();
  }

  Future<void> _loadAcceptedJobRequests() async {
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<Map<String, dynamic>> acceptedRequests = [];
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value['jobId'].toString() == widget.id &&
              (value['status'] == 'done_task' ||
                  value['status'] == 'completed')) {
            acceptedRequests.add({
              'key': key,
              'jobName': value['jobName'],
              'location': value['location'],
              'email': value['email'],
              'totalPrice': value['totalPrice'],
              'createdAt': value['createdAt'],
              'jobId': value['jobId'],
              'status': value['status'],
              'reviewStatus': value['reviewStatus'] ?? '',
              'id': value['id'],
            });
          }
        });

        acceptedRequests
            .sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

        setState(() {
          acceptedJobRequests = acceptedRequests;
        });
      }
    });
  }

  Future<void> reviewData() async {
    _reviewDB.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> dataOfReview = {};
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value['userId'].toString() == widget.id) {
            dataOfReview = {
              'key': key,
              'jobId': value['jobId'],
              'status': value['status'],
            };
            setState(() {
              reviewLoadData = dataOfReview;
            });
          }
        });
      }
    });
  }

  void _makePayment(String key, String offerPrice) {
    TextEditingController tipsController = TextEditingController();
    bool addTips = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool disposed = false; // Track if dialog is disposed

            // Dismiss dialog if state is disposed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (disposed) {
                Navigator.of(context).pop();
              }
            });

            return PopScope(
              onPopInvoked: (b) {
                b = true;
                disposed = b; // Mark dialog as disposed
              },
              child: AlertDialog(
                title: const Text(
                  'Make Payment',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Payment: RM $offerPrice'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: addTips,
                          onChanged: (value) {
                            setState(() {
                              addTips = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: tipsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}$'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Enter tip amount',
                            ),
                            enabled: addTips,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Skip'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            double tips =
                                double.tryParse(tipsController.text) ?? 0;

                            double offerPriceCasting =
                                double.tryParse(offerPrice) ?? 0;

                            if (tips >= 0 && tips <= offerPriceCasting) {
                              double totalAmount = offerPriceCasting + tips;
                              _updateStatus(
                                  key, 'completed', totalAmount.toString());
                              Navigator.of(context).pop();
                              _showSuccessDialog(totalAmount);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tip amount must be between 0 and the offer price',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text('Pay Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(double totalAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Payment Successful',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                    'You have successfully paid RM $totalAmount to this caregiver.'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(String key, String newStatus, String paid) {
    _databaseReference
        .child(key)
        .update({'status': newStatus, 'paid': double.parse(paid).toString()});
    // You can update other fields as needed
  }

  void _openReviewPage(String jobId, String userId, int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          jobId: jobId,
          userId: userId,
          customerId: acceptedJobRequests[i]['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Job List'),
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
              return _buildAcceptedJobCard(acceptedJobRequests[index], index);
            },
          );
  }

  Widget _buildAcceptedJobCard(Map<String, dynamic> jobRequest, int i) {
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
                  'Price: RM ${jobRequest['totalPrice']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: jobRequest['status'] == 'done_task'
                      ? () {
                          _makePayment(
                              jobRequest['key'], jobRequest['totalPrice']);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(jobRequest['status'] == 'done_task'
                      ? 'Make Payment'
                      : 'Paid'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: reviewLoadData['status'] == 'reviewed'
                      ? null
                      : () =>
                          _openReviewPage(jobRequest['jobId'], widget.id, i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    reviewLoadData['status'] == 'reviewed'
                        ? 'Reviewed'
                        : 'Review',
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
