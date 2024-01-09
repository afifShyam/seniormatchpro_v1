import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:seniormatchpro_v1/index.dart';

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
  double rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Write a Review'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rating Bar
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Review Text Field
              TextField(
                onChanged: (text) {
                  setState(() {
                    reviewText = text;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter your review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton(
                onPressed: (reviewText.isNotEmpty || rating > 0)
                    ? () {
                        _submitReview();
                      }
                    : null,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReview() {
    DatabaseReference _reviewsReference =
        FirebaseDatabase.instance.ref().child('reviews');

    Review review = Review(
      jobId: widget.jobId,
      userId: widget.userId,
      reviewText: reviewText,
      rating: rating,
      status: 'reviewed',
    );

    _reviewsReference.push().set(review.toMap());

    // Navigate back to the previous screen
    Navigator.pop(context);
  }
}
