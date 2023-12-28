import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final String jobId;
  final String userId;

  const ReviewPage({
    Key? key,
    required this.jobId,
    required this.userId,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String reviewText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (text) {
                setState(() {
                  reviewText = text;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your review',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: reviewText.isNotEmpty
                  ? () {
                      _submitReview();
                    }
                  : null,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() {
    // Save the review in the database
    // You can use the Review model and update the job_requests model
    // Set the review status in job_requests to 'completed'
    // Optionally, mark the review as 'completed' in a separate reviews collection

    // For simplicity, let's assume you have a DatabaseReference for reviews
    // and you can use a Map to store review data
    // Adapt this part based on your database structure

    // Example:
    // DatabaseReference _reviewsReference =
    //     FirebaseDatabase.instance.ref().child('reviews');
    //
    // Review review = Review(
    //   jobId: widget.jobId,
    //   userId: widget.userId,
    //   reviewText: reviewText,
    // );
    //
    // _reviewsReference.push().set(review.toMap());

    // Update the job_requests model
    // _databaseReference.child(widget.jobId).update({'reviewStatus': 'completed'});

    // Navigate back to the previous screen
    Navigator.pop(context);
  }
}
