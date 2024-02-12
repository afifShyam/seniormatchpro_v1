class Review {
  final String jobId;
  final String userId;
  final String reviewText;
  final String status;
  final double rating;
  final String customerId;

  Review(
      {required this.jobId,
      required this.userId,
      required this.reviewText,
      required this.status,
      required this.rating,
      required this.customerId});

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'reviewText': reviewText,
      'status': status,
      'rating': rating,
      'customerId': customerId
    };
  }

  @override
  String toString() {
    return 'Review{jobId: $jobId, userId: $userId, reviewText: $reviewText, status: $status, rating: $rating, customerId: $customerId}';
  }
}
